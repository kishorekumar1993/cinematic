// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, uri_does_not_exist
import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'dart:web_audio' as web_audio;
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class VoiceManager {
  static final VoiceManager _instance = VoiceManager._internal();
  factory VoiceManager() => _instance;
  VoiceManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  web_audio.AudioContext? _audioContext;
  web_audio.MediaStreamAudioDestinationNode? _destination;
  html.AudioElement? _currentAudioElement;

  html.MediaStream? get audioStream => _destination?.stream;

  void initWebAudio() {
    if (!kIsWeb) return;
    if (_audioContext == null) {
      _audioContext = web_audio.AudioContext();
      _destination = _audioContext!.createMediaStreamDestination() as web_audio.MediaStreamAudioDestinationNode;
    }
  }

  // Point to the local Python Flask server running edge-tts
  // Use 10.0.2.2 if testing on Android Emulator, otherwise localhost/127.0.0.1
  final String _serverUrl = 'http://127.0.0.1:5000/generate';

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// Speaks the provided text using the local TTS server
  Future<void> speak(String text, {String? voiceTone}) async {
    if (text.trim().isEmpty) return;
    
    // Map voiceTone from SceneConfig to actual Edge-TTS voice names
    // Examples of Edge-TTS voices:
    // en-US-ChristopherNeural (Deep male, great for tutorials)
    // en-US-AriaNeural (Clear female)
    // en-US-GuyNeural (Standard male)
    String edgeVoice = 'en-US-ChristopherNeural'; 
    if (voiceTone != null && voiceTone.toLowerCase().contains('female')) {
      edgeVoice = 'en-US-AriaNeural';
    }

    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'voice': edgeVoice,
        }),
      );

      if (response.statusCode == 200) {
        if (kIsWeb) {
          initWebAudio();
          final blob = html.Blob([response.bodyBytes], 'audio/mp3');
          final url = html.Url.createObjectUrlFromBlob(blob);
          
          _currentAudioElement?.pause();
          _currentAudioElement = html.AudioElement(url);
          _currentAudioElement!.crossOrigin = 'anonymous';
          
          final source = _audioContext!.createMediaElementSource(_currentAudioElement!);
          source.connectNode(_destination!);
          source.connectNode(_audioContext!.destination!);
          
          _currentAudioElement!.onEnded.listen((_) {
            _isPlaying = false;
            html.Url.revokeObjectUrl(url);
          });
          
          _isPlaying = true;
          await _currentAudioElement!.play();
        } else {
          // Save the audio file temporarily
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/speech_${DateTime.now().millisecondsSinceEpoch}.mp3');
          await file.writeAsBytes(response.bodyBytes);
          
          // Play the audio
          await _audioPlayer.play(DeviceFileSource(file.path));
          _isPlaying = true;
          
          _audioPlayer.onPlayerComplete.listen((event) {
            _isPlaying = false;
          });
        }
      } else {
        if (kDebugMode) {
          print('Voice Server Error: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to Voice Server: $e. Make sure the Python server is running.');
      }
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    if (kIsWeb) {
      _currentAudioElement?.pause();
      _isPlaying = false;
    } else {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }
}
