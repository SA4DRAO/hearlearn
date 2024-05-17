import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hearlearn/providers/slider_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FlashCardsDetailsScreen extends StatefulWidget {
  final String imgPath;
  final String description;
  final String locale;

  const FlashCardsDetailsScreen({
    Key? key,
    required this.imgPath,
    required this.description,
    required this.locale,
  }) : super(key: key);

  @override
  _FlashCardsDetailsScreenState createState() =>
      _FlashCardsDetailsScreenState();
}

class _FlashCardsDetailsScreenState extends State<FlashCardsDetailsScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  late bool _isListening;
  late Color _microphoneColor;
  String _text = '';
  Color _textColor = Colors.black;

  FlutterTts flutterTts = FlutterTts();
  final double _speed = 0.7;
  double _pitch = 1.0;

  late String _description;
  late bool _isMounted;
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _isListening = false;
    _microphoneColor = Colors.blue;
    flutterTts.setLanguage(widget.locale);
    _description = widget.description;
    checkMicrophonePermission();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    _speech.stop();
    super.dispose();
  }

  Future<void> _speakDescription() async {
    try {
      await flutterTts.setSpeechRate(_speed);
      await flutterTts.setPitch(_pitch);
      await flutterTts.speak(_description);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  void _setProperties({required double speed, required double pitch}) {
    setState(() {
      context.read<SliderProvider>().changeSpeed(newSliderSpeed: speed);
      _pitch = pitch;
      flutterTts.setSpeechRate(speed);
      flutterTts.setPitch(pitch);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _speakDescription,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/img/${widget.imgPath}',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/hand.png',
                      height: 20,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.description,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            Text(
              'Speed: ${context.watch<SliderProvider>().sliderSpeed.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: context.read<SliderProvider>().sliderSpeed,
              min: 0.05,
              max: 2.0,
              onChanged: (value) => _setProperties(speed: value, pitch: _pitch),
            ),
            Text(
              'Pitch: ${_pitch.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: _pitch,
              min: 0.05,
              max: 2.0,
              onChanged: (value) => _setProperties(speed: _speed, pitch: value),
            ),
            InkWell(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _microphoneColor,
                ),
                child: const Icon(
                  Icons.mic,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: TextField(
                maxLines: null,
                controller: TextEditingController(text: _text),
                style: TextStyle(fontSize: 32, color: _textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSmileyFaceDialog(BuildContext context) {
    if (!_isDialogShown) {
      _isDialogShown = true;
      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevents dialog from being dismissed by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Correct Word Detected'),
            content: Icon(
              Icons.sentiment_satisfied,
              size: 50,
              color: Colors.green,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isDialogShown =
                        false; // Reset _isDialogShown when dialog is closed
                  });
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _toggleListening() async {
    setState(() {
      _textColor = Colors.red;
    });
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == stt.SpeechToText.listeningStatus && _isMounted) {
            setState(() {
              _isListening = true;
              _microphoneColor = Colors.red;
            });
          }
        },
        onError: (error) => print('error: $error'),
      );
      if (available) {
        _speech.listen(
          localeId: widget.locale,
          onResult: (result) {
            if (_isMounted) {
              setState(() {
                _text = result.recognizedWords;
                List<String> words = _text.toLowerCase().split(' ');
                if (words.contains(widget.description.toLowerCase())) {
                  _speech.stop(); // Stop speech recognition
                  _textColor = Colors.green;
                  if (!_isDialogShown) {
                    // Check if dialog is not already shown
                    _isDialogShown = true;
                    _showSmileyFaceDialog(context); // Show smiley face dialog
                  }
                }
              });

              // Check if any recognized word matches the target word
              List<String> words = _text.toLowerCase().split(' ');
              if (words.contains(widget.description.toLowerCase())) {
                _speech.stop(); // Stop speech recognition
                _microphoneColor = Colors.blue;
              }
            }
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available'),
          ),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }

  void checkMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;

    if (!status.isGranted) {
      await Permission.microphone.request();
      if (!await Permission.microphone.request().isGranted) {
        print('No Mic Permission :(');
      }
    }
  }
}
