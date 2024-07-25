import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

class TTSService {
  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;

  TTSService() {
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setLanguage('en-US');

    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
    });

    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
    });

    _flutterTts.setErrorHandler((msg) {
      _ttsState = TtsState.stopped;
    });
  }

  Future<void> speak(String text) async {
    if (_ttsState == TtsState.stopped) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    if (_ttsState == TtsState.playing) {
      await _flutterTts.stop();
    }
  }
}
