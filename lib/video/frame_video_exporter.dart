// lib/video/frame_video_exporter.dart

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:cinematic/video/video_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FrameVideoExporter {
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  late html.CanvasElement _recordCanvas;
  late html.CanvasRenderingContext2D _ctx;

  html.MediaRecorder? _mediaRecorder;

  final List<html.Blob> _chunks = [];

  Future<void> startRecording({
    required GlobalKey repaintKey,
    int fps = 12,
    int durationSeconds = 5,
  }) async {
    if (_isRecording) {
      debugPrint('Already recording');
      return;
    }

    _isRecording = true;

    _chunks.clear();

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final context = repaintKey.currentContext;

    if (context == null) {
      throw Exception(
        'RepaintBoundary context is null',
      );
    }

    final boundary =
        context.findRenderObject()
            as RenderRepaintBoundary?;

    if (boundary == null) {
      throw Exception(
        'RenderRepaintBoundary not found',
      );
    }

    final size = boundary.size;

    const scale = 1;

    _recordCanvas = html.CanvasElement(
      width: (size.width * scale).toInt(),
      height: (size.height * scale).toInt(),
    );

    _ctx = _recordCanvas.context2D;

    _ctx.scale(
      scale.toDouble(),
      scale.toDouble(),
    );

    final stream =
        _recordCanvas.captureStream(fps);

    String mimeType =
        'video/webm;codecs=vp9';

    if (html.MediaRecorder.isTypeSupported(
      'video/webm;codecs=vp9,opus',
    )) {
      mimeType =
          'video/webm;codecs=vp9,opus';
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

        if (blob != null &&
            blob.size > 0) {
          _chunks.add(blob);
        }
      },
    );

    _mediaRecorder!.start();

    debugPrint('🎬 Recording Started');

    final totalFrames =
        fps * durationSeconds;

    for (int i = 0;
        i < totalFrames;
        i++) {
      if (!_isRecording) break;

      await Future.delayed(
        Duration(
          milliseconds:
              (1000 / fps).round(),
        ),
      );

      try {
        final image =
            await boundary.toImage(
          pixelRatio: 1.0,
        );

        final byteData =
            await image.toByteData(
          format:
              ui.ImageByteFormat.png,
        );

        image.dispose();

        if (byteData == null) {
          continue;
        }

        final bytes =
            byteData.buffer.asUint8List();

        final blob = html.Blob(
          [bytes],
          'image/png',
        );

        final url =
            html.Url
                .createObjectUrlFromBlob(
          blob,
        );

        final img =
            html.ImageElement();

        final completer =
            Completer<void>();

        img.src = url;

        img.onLoad.listen((_) {
          _ctx.drawImageScaled(
            img,
            0,
            0,
            size.width,
            size.height,
          );

          completer.complete();
        });

        // await completer.future;
await Future.delayed(
  const Duration(milliseconds: 30),
);

        html.Url.revokeObjectUrl(
          url,
        );

        debugPrint(
          '✅ Frame ${i + 1}/$totalFrames',
        );
      } catch (e) {
        debugPrint(
          '❌ Frame error: $e',
        );
      }
    }


await Future.delayed(
  const Duration(milliseconds: 500),
);

    await stopRecording();
  }

  Future<void> stopRecording() async {
    if (!_isRecording) {
      return;
    }

    _isRecording = false;

    final completer =
        Completer<void>();

    _mediaRecorder!.addEventListener(
      'stop',
//  (_) async {
//   if (_chunks.isEmpty) {
//     debugPrint('❌ No video chunks');
//     completer.complete();
//     return;
//   }

//   final blob = html.Blob(
//     _chunks,
//     'video/webm',
//   );

//   final reader = html.FileReader();

//   reader.readAsArrayBuffer(blob);

//   await reader.onLoad.first;

//   final webmBytes =
//       reader.result as Uint8List;

//   await VideoConverter.convertWebmToMp4(
//     webmBytes,
//   );

//   completer.complete();
// },
      (_) async {
        if (_chunks.isEmpty) {
          debugPrint(
            '❌ No video chunks',
          );
          completer.complete();
          return;
        }

        final blob = html.Blob(
          _chunks,
          'video/webm',
        );

        final url =
            html.Url
                .createObjectUrlFromBlob(
          blob,
        );

        html.AnchorElement(
          href: url,
        )
          ..download =
              'cinematic_movie.webm'
          ..click();

        html.Url.revokeObjectUrl(
          url,
        );

        debugPrint(
          '🎉 Video Downloaded',
        );

        completer.complete();
      },
 
 
    );

    _mediaRecorder!.stop();

    await completer.future;
  }
}
