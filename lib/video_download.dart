import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class VideoExporter {
  static Future<String> exportVideo({
    required GlobalKey repaintKey,
    required int totalSeconds,
    int fps = 30,
  }) async {
    final tempDir = await getTemporaryDirectory();

    final framesDir = Directory("${tempDir.path}/frames");

    if (await framesDir.exists()) {
      await framesDir.delete(recursive: true);
    }

    await framesDir.create(recursive: true);

    final totalFrames = totalSeconds * fps;

    for (int i = 0; i < totalFrames; i++) {
      await _captureFrame(
        repaintKey,
        "${framesDir.path}/frame_${i.toString().padLeft(5, '0')}.png",
      );

      await Future.delayed(
        Duration(milliseconds: 1000 ~/ fps),
      );
    }

    final outputPath =
        "${tempDir.path}/cinematic_${DateTime.now().millisecondsSinceEpoch}.mp4";

    final command = """
    -y
    -framerate $fps
    -i ${framesDir.path}/frame_%05d.png
    -c:v libx264
    -pix_fmt yuv420p
    $outputPath
    """;

    await FFmpegKit.execute(command);

    return outputPath;
  }

  static Future<void> _captureFrame(
    GlobalKey repaintKey,
    String path,
  ) async {
    final boundary = repaintKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(
      pixelRatio: 1.5,
    );

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final Uint8List pngBytes =
        byteData!.buffer.asUint8List();

    final file = File(path);

    await file.writeAsBytes(pngBytes);
  }
}