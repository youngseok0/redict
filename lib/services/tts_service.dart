import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts _tts = FlutterTts();

  void speak(String text) {
    _tts.speak(text);
  }
}
