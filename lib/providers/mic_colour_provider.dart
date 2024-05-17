import 'package:flutter/material.dart';

class MicrophoneColorProvider extends ChangeNotifier {
  Color _color = Colors.blue;

  Color get color => _color;

  void setColor(Color newColor) {
    _color = newColor;
    notifyListeners();
  }
}
