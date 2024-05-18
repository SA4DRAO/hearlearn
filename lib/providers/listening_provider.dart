import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ListeningProvider extends ChangeNotifier {
  final stt.SpeechToText _speechToText;
  bool _isListening;
  Color _microphoneColor;
  String _text;
  String _locale;
  Color _textColor;

  ListeningProvider({
    stt.SpeechToText? speechToText,
    bool isListening = false,
    Color microphoneColor = Colors.blue,
    String text = '',
    String locale = 'en_US',
    Color textColor = Colors.red,
  })  : _speechToText = speechToText ?? stt.SpeechToText(),
        _isListening = isListening,
        _microphoneColor = microphoneColor,
        _text = text,
        _locale = locale,
        _textColor = textColor;

  bool get isListening => _isListening;
  Color get microphoneColor => _microphoneColor;
  String get text => _text;
  String get locale => _locale;
  Color get textColor => _textColor;

  void startListening({required String description}) async {
    if (_isListening) {
      stopListening();
      return;
    }
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == stt.SpeechToText.listeningStatus) {
          _isListening = true;
          _microphoneColor = Colors.red;
          _textColor = Colors.red;
          notifyListeners();
        }
      },
      onError: (error) {
        stopListening();
      },
    );
    if (available) {
      _speechToText.listen(
        localeId: _locale,
        onResult: (result) {
          _text = result.recognizedWords;
          List<String> words = _text.toLowerCase().split(' ');
          if (words.contains(description.toLowerCase())) {
            _textColor = Colors.green;
            stopListening();
          }
          _microphoneColor = Colors.blue;
          notifyListeners();
        },
      );
    } else {
      stopListening();
    }
  }

  void stopListening() {
    _speechToText.stop();
    _isListening = false;
    _microphoneColor = Colors.blue;
    notifyListeners();
  }

  void setLocale({required String newLocale}) {
    _locale = newLocale;
    notifyListeners();
  }

  void reset() {
    stopListening();
    _isListening = false;
    _microphoneColor = Colors.blue;
    _textColor = Colors.red;
    _text = '';
    notifyListeners();
  }
}
