import 'dart:html' as html;

// Correct conditional import (not export)
import 'video_export_stub.dart'
    if (dart.library.html) 'video_export_web.dart';

abstract class VideoExportService {
  Future<void> startRecording({
    required html.CanvasElement canvas,
    required String narration,
    int fps = 30,
  });

  Future<html.Blob?> stopRecording();
}

VideoExportService getVideoExporter() => createVideoExporter();