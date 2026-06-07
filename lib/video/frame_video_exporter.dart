// lib/video/frame_video_exporter.dart

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

    String mimeType = 'video/webm;codecs=vp9';
    if (html.MediaRecorder.isTypeSupported('video/webm;codecs=vp9,opus')) {
      mimeType = 'video/webm;codecs=vp9,opus';
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
            'video/webm',
          );

          final url = html.Url.createObjectUrlFromBlob(blob);

          html.AnchorElement(
            href: url,
          )
            ..download = 'cinematic_movie.webm'
            ..click();

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

    final totalFrames = fps * durationSeconds;

    for (int i = 0; i < totalFrames; i++) {
      if (!_isRecording) break;

      await Future.delayed(
        Duration(
          milliseconds: (1000 / fps).round(),
        ),
      );

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

        debugPrint('✅ Frame ${i + 1}/$totalFrames');
      } catch (e) {
        debugPrint('❌ Frame error: $e');
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
