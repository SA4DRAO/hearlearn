import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ListeningProvider extends ChangeNotifier {
  stt.SpeechToText speechToText;
  bool isListening;
  Color microphoneColor;
  String text;
  String locale;
  Color textColor;
  ListeningProvider({
    stt.SpeechToText? speechToText,
    this.isListening = false,
    this.microphoneColor = Colors.blue,
    this.text = '',
    this.locale = 'en_US',
    this.textColor = Colors.red,
  }) : speechToText = speechToText ?? stt.SpeechToText();

  void startListening({required String description}) async {
    if (isListening) {
      stopListening();
      return;
    }
    bool available = await speechToText.initialize(onStatus: (status) {
      if (status == stt.SpeechToText.listeningStatus) {
        isListening = true;
        microphoneColor = Colors.red;
        textColor = Colors.red;
        notifyListeners();
      }
    });
    if (available) {
      speechToText.listen(
          localeId: locale,
          onResult: (result) {
            text = result.recognizedWords;
            List<String> words = text.toLowerCase().split(' ');
            if (words.contains(description.toLowerCase())) {
              textColor = Colors.green;
              stopListening();
            }
            notifyListeners();
          });
    }
  }

  void stopListening() {
    speechToText.stop();
    isListening = false;
    microphoneColor = Colors.blue;
    notifyListeners();
  }

  void setLocale({required String newLocale}) async {
    locale = newLocale;
    notifyListeners();
  }

  void reset() {
    stopListening();
    isListening = false;
    microphoneColor = Colors.blue;
    textColor = Colors.red;
    text = '';
    notifyListeners();
  }
}
