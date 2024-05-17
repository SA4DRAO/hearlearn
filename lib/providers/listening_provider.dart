import 'package:flutter/material.dart';

class ListeningProvider with ChangeNotifier {
  bool _isListening = false;
  Color _microphoneColor = Colors.blue;

  bool get isListening => _isListening;
  Color get microphoneColor => _microphoneColor;

  void startListening() {
    _isListening = true;
    _microphoneColor = Colors.red;
    notifyListeners();
  }

  void stopListening() {
    _isListening = false;
    _microphoneColor = Colors.blue;
    notifyListeners();
  }
}
