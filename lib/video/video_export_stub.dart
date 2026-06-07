import 'dart:html' as html;
import 'video_export_service.dart';

class StubVideoExportService implements VideoExportService {
  @override
  Future<void> startRecording({
    required html.CanvasElement canvas,
    required String narration,
    int fps = 30,
  }) async {
    throw UnsupportedError('Video recording is only supported on web.');
  }

  @override
  Future<html.Blob?> stopRecording() async => null;
}

VideoExportService createVideoExporter() => StubVideoExportService();