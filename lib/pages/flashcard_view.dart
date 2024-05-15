import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FlashCardsDetailsScreen extends StatefulWidget {
  final String imgPath;
  final String description;
  final String locale;
  const FlashCardsDetailsScreen(
      {super.key,
      required this.imgPath,
      required this.description,
      required this.locale});

  @override
  _FlashCardsDetailsScreenState createState() =>
      _FlashCardsDetailsScreenState();
}

class _FlashCardsDetailsScreenState extends State<FlashCardsDetailsScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  Color _textColor = Colors.black;

  FlutterTts flutterTts = FlutterTts();
  double _speed = 1.0;
  double _pitch = 1.0;

  late String _description;
  late bool _isMounted;
  @override
  void initState() {
    super.initState();
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
    await flutterTts.setSpeechRate(_speed);
    await flutterTts.setPitch(_pitch);
    await flutterTts.speak(_description);
  }

  void _setSpeed(double value) {
    setState(() {
      _speed = value;
      flutterTts.setSpeechRate(_speed);
    });
  }

  void _setPitch(double value) {
    setState(() {
      _pitch = value;
      flutterTts.setPitch(_pitch);
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
              onTap: () {
                _speakDescription();
              },
              child: Stack(
                children: [
                  Image.asset(
                    height: 300,
                    'assets/img/${widget.imgPath}',
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/hand.png',
                      height: 20,
                      color: Colors
                          .transparent, // Set the color to transparent to make the background invisible
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
              'Speed: ${_speed.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: _speed,
              min: 0.05,
              max: 2.0,
              onChanged: _setSpeed,
            ),
            Text(
              'Pitch: ${_pitch.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: _pitch,
              min: 0.05,
              max: 2.0,
              onChanged: _setPitch,
            ),
            InkWell(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.blue,
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

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('status: $status');
          if (status == stt.SpeechToText.listeningStatus && _isMounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) => print('error: $error'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          localeId: widget.locale,
          onResult: (result) {
            if (_isMounted) {
              setState(() {
                _text = result.recognizedWords;
                _textColor =
                    _text.toLowerCase() == widget.description.toLowerCase()
                        ? Colors.green
                        : Colors.red;
              });
            }
          },
        );
      } else {
        setState(() {
          _isListening = false;
        });
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
}

Future<void> checkMicrophonePermission() async {
  PermissionStatus status = await Permission.microphone.status;

  if (!status.isGranted) {
    await Permission.microphone.request();

    if (!await Permission.microphone.status.isGranted) {
      print('No Mic Permission :(');
    }
  }
}
