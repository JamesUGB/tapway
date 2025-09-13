import 'dart:async'; // Added for Completer
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logging/logging.dart'; // Added for proper logging

class VoiceCommandService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final Logger _logger = Logger('VoiceCommandService');
  bool _isListening = false;
  bool _isInitialized = false;

  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => _isListening = status == 'listening',
        onError: (error) => _onError(error.errorMsg),
      );
      
      if (_isInitialized) {
        await _configureTts();
      }
      return _isInitialized;
    } catch (e) {
      _logger.severe('Initialization error', e);
      return false;
    }
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setErrorHandler((msg) => _onError(msg));
  }

  Future<String?> listen({Duration timeout = const Duration(seconds: 10)}) async {
    if (!_isInitialized && !await initialize()) return null;

    String? recognizedText;
    final completer = Completer<String?>();
    final options = stt.SpeechListenOptions(
      cancelOnError: true,
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
    );

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          recognizedText = result.recognizedWords;
          completer.complete(recognizedText);
        }
      },
      listenFor: timeout,
      listenOptions: options, // Using modern options approach
    );

    return completer.future;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
    } catch (e) {
      _logger.severe('Speech error', e);
    }
  }

  Future<void> stop() async {
    if (_isListening) {
      await _speech.stop();
    }
    await _tts.stop();
  }

  void _onError(String errorMsg) {
    _logger.warning('Voice command error: $errorMsg');
    stop();
  }

  void dispose() {
    stop();
    _speech.cancel();
  }
}