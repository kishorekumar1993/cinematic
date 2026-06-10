// lib/video/frame_video_exporter.dart

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:cinematic/services/voice_manager.dart';

class FrameVideoExporter {
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  late html.CanvasElement _recordCanvas;
  late html.CanvasRenderingContext2D _ctx;

  html.MediaRecorder? _mediaRecorder;
  final List<html.Blob> _chunks = [];
  Completer<void>? _stopCompleter;

  Future<void> startRecording({
    required GlobalKey repaintKey,
    int fps = 30,
    int durationSeconds = 5,
  }) async {
    if (_isRecording) {
      debugPrint('Already recording');
      return;
    }

    _isRecording = true;
    _chunks.clear();
    _stopCompleter = Completer<void>();

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final context = repaintKey.currentContext;
    if (context == null) {
      _isRecording = false;
      throw Exception('RepaintBoundary context is null');
    }

    final boundary = context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      _isRecording = false;
      throw Exception('RenderRepaintBoundary not found');
    }

    final size = boundary.size;
    const scale = 1.0;

    _recordCanvas = html.CanvasElement(
      width: (size.width * scale).toInt(),
      height: (size.height * scale).toInt(),
    );

    _ctx = _recordCanvas.context2D;
    _ctx.scale(scale, scale);

    final stream = _recordCanvas.captureStream(fps);

    // VoiceManager().initWebAudio();
    // final audioStream = VoiceManager().audioStream;
    // if (audioStream != null) {
    //   final audioTracks = audioStream.getAudioTracks();
    //   if (audioTracks.isNotEmpty) {
    //     // stream.addTrack(audioTracks.first); // This is likely causing the WebM corruption if the track is empty!
    //   }
    // }

    String mimeType = 'video/webm';
    String ext = 'webm';
    
    if (html.MediaRecorder.isTypeSupported('video/mp4')) {
      mimeType = 'video/mp4';
      ext = 'mp4';
    } else if (html.MediaRecorder.isTypeSupported('video/webm;codecs=vp8,opus')) {
      mimeType = 'video/webm;codecs=vp8,opus';
    }

    _mediaRecorder = html.MediaRecorder(
      stream,
      {
        'mimeType': mimeType,
        'videoBitsPerSecond': 8000000,
      },
    );

    _mediaRecorder!.addEventListener(
      'dataavailable',
      (event) {
        final blob = (event as dynamic).data;
        if (blob != null && blob.size > 0) {
          _chunks.add(blob);
        }
      },
    );

    _mediaRecorder!.addEventListener(
      'stop',
      (_) async {
        try {
          if (_chunks.isEmpty) {
            debugPrint('❌ No video chunks');
            return;
          }

          final blob = html.Blob(
            _chunks,
            mimeType,
          );

          final url = html.Url.createObjectUrlFromBlob(blob);

          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', 'cinematic_movie.$ext')
            ..style.display = 'none';
            
          html.document.body?.append(anchor);
          anchor.click();
          anchor.remove();

          html.Url.revokeObjectUrl(
            url,
          );

          debugPrint('🎉 Video Downloaded');
        } catch (e) {
          debugPrint('Error handling recording stop and download: $e');
        } finally {
          if (_stopCompleter != null && !_stopCompleter!.isCompleted) {
            _stopCompleter!.complete();
          }
        }
      },
    );

    _mediaRecorder!.start();
    debugPrint('🎬 Recording Started');

    final totalDurationMs = durationSeconds * 1000;
    final stopwatch = Stopwatch()..start();
    int frameCount = 0;

    while (stopwatch.elapsedMilliseconds < totalDurationMs) {
      if (!_isRecording) break;

      final startIteration = stopwatch.elapsedMilliseconds;

      try {
        final image = await boundary.toImage(
          pixelRatio: 1.0,
        );

        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        image.dispose();

        if (byteData == null) {
          continue;
        }

        final bytes = byteData.buffer.asUint8List();

        final blob = html.Blob(
          [bytes],
          'image/png',
        );

        final url = html.Url.createObjectUrlFromBlob(blob);
        final img = html.ImageElement();
        final completer = Completer<void>();

        img.src = url;

        final subLoad = img.onLoad.listen((_) {
          _ctx.drawImageScaled(
            img,
            0,
            0,
            size.width,
            size.height,
          );
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        final subError = img.onError.listen((e) {
          debugPrint('Error loading frame image: $e');
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        // Await frame loading or 100ms safe timeout
        await completer.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () {
            debugPrint('Frame image load timed out');
          },
        );

        subLoad.cancel();
        subError.cancel();

        html.Url.revokeObjectUrl(
          url,
        );
        
        frameCount++;
        debugPrint('✅ Frame $frameCount recorded');
      } catch (e) {
        debugPrint('❌ Frame error: $e');
      }

      final endIteration = stopwatch.elapsedMilliseconds;
      final timeTaken = endIteration - startIteration;
      final targetFrameTime = 1000 ~/ fps;
      final waitTime = targetFrameTime - timeTaken;

      if (waitTime > 0) {
        await Future.delayed(Duration(milliseconds: waitTime));
      } else {
        // Yield to event loop to allow Flutter to render the next frame
        await Future.delayed(Duration.zero);
      }
    }

    // Auto-stop recording if the loop finishes and we are still recording
    if (_isRecording) {
      await stopRecording();
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) {
      return;
    }

    _isRecording = false;

    if (_mediaRecorder != null && _mediaRecorder!.state != 'inactive') {
      _mediaRecorder!.stop();
    }

    if (_stopCompleter != null) {
      await _stopCompleter!.future;
    }
  }
}
