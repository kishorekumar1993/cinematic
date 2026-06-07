// lib/screens/recorder_screen.dart

import 'package:flutter/material.dart';
import '../video/frame_video_exporter.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  // This key MUST be attached to a RepaintBoundary
  final GlobalKey _previewKey = GlobalKey();
  final FrameVideoExporter _exporter = FrameVideoExporter();

  bool _isRecording = false;
  String _statusMessage = 'Ready';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frame Video Exporter')),
      body: Column(
        children: [
          // The widget you want to record – wrapped in RepaintBoundary
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RepaintBoundary(
                key: _previewKey,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FlutterLogo(size: 120),
                      const SizedBox(height: 20),
                      Text(
                        _statusMessage,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: _isRecording ? 200 : 100,
                        height: _isRecording ? 200 : 100,
                        color: Colors.blue,
                        child: const Center(
                          child: Text(
                            'Animated Widget',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start Recording button
                IconButton(
                  tooltip: 'Start Recording',
                  onPressed: _isRecording ? null : _startRecording,
                  icon: const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(width: 20),
                // Stop Recording button
                IconButton(
                  tooltip: 'Stop Recording',
                  onPressed: _isRecording ? _stopRecording : null,
                  icon: const Icon(Icons.stop, size: 48),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _statusMessage = 'Recording...';
    });

    try {
      // Small delay to ensure the widget is fully laid out
      await Future.delayed(const Duration(milliseconds: 100));

      await _exporter.startRecording(
        repaintKey: _previewKey,
        fps: 30,           // frames per second
        durationSeconds: 5, // change as needed
      );

      setState(() {
        _statusMessage = 'Recording finished!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isRecording = false;
      });
      debugPrint('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _statusMessage = 'Stopping & downloading...';
    });

    try {
      await _exporter.stopRecording();
      setState(() {
        _isRecording = false;
        _statusMessage = 'Ready';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Stop error: $e';
        _isRecording = false;
      });
    }
  }

  @override
  void dispose() {
    // _exporter.clearFrames();
    super.dispose();
  }
}