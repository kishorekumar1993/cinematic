// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'video_export_service.dart';

class WebVideoExportService implements VideoExportService {
  html.MediaRecorder? _recorder;
  final List<html.Blob> _chunks = [];
  bool _isRecording = false;

  @override
  Future<void> startRecording({
    required html.CanvasElement canvas,
    required String narration,
    int fps = 30,
  }) async {
    if (_isRecording) await stopRecording();

    _chunks.clear();

    final stream = canvas.captureStream(fps);
    if (stream.getVideoTracks().isEmpty) {
      throw Exception('No video track – canvas capture not supported');
    }

    String mimeType = 'video/webm';
    if (html.MediaRecorder.isTypeSupported('video/webm;codecs=vp9')) {
      mimeType = 'video/webm;codecs=vp9';
    } else if (html.MediaRecorder.isTypeSupported('video/webm;codecs=vp8')) {
      mimeType = 'video/webm;codecs=vp8';
    }

    _recorder = html.MediaRecorder(stream, {'mimeType': mimeType});

    _recorder!.addEventListener('dataavailable', (event) {
      final data = (event as dynamic).data;
      if (data != null && data.size > 0) {
        _chunks.add(data);
      }
    });

    _recorder!.start(1000);
    _isRecording = true;

    print('✅ Recording started – real canvas: ${canvas.width}×${canvas.height}');
  }

  @override
  Future<html.Blob?> stopRecording() async {
    if (!_isRecording || _recorder == null) return null;

    final completer = Completer<html.Blob?>();

    _recorder!.addEventListener('stop', (_) {
      if (_chunks.isEmpty) {
        completer.complete(null);
      } else {
        final blob = html.Blob(_chunks, 'video/webm');
        completer.complete(blob);
      }
      _isRecording = false;
      _recorder = null;
    });

    await Future.delayed(const Duration(milliseconds: 200));
    _recorder!.stop();

    return completer.future;
  }
}

VideoExportService createVideoExporter() => WebVideoExportService();