import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechProvider extends ChangeNotifier {
  FlutterTts flutterTts;
  double speed;
  double pitch;
  SpeechProvider({
    FlutterTts? flutterTts,
    this.speed = 0.7,
    this.pitch = 0.8,
  }) : flutterTts = flutterTts ?? FlutterTts();

  void speak({required String text, required String locale}) async {
    await flutterTts.setLanguage(locale);
    await flutterTts.setSpeechRate(speed);
    await flutterTts.setPitch(pitch);
    await flutterTts.speak(text);
    notifyListeners();
  }

  void setSpeechRate({required double newSpeed}) async {
    speed = newSpeed;
    notifyListeners();
  }

  void setPitch({required double newPitch}) async {
    pitch = newPitch;
    notifyListeners();
  }
}
