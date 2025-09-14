import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTService {
  stt.SpeechToText _speech = stt.SpeechToText();

  void startListening() {
    _speech.listen(onResult: (result) {
      print("음성 인식 결과: ${result.recognizedWords}");
    });
  }
}
