import 'package:flutter/material.dart';
import 'package:hearlearn/pages/image_list_screen.dart';
import 'package:hearlearn/providers/cards_list_provider.dart';
import 'package:hearlearn/providers/listening_provider.dart';
import 'package:hearlearn/providers/speech_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
        ChangeNotifierProvider(create: (_) => ListeningProvider()),
        ChangeNotifierProvider(create: (_) => CardsListProvider()),
      ],
      child: const MaterialApp(home: IntroScreen()),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showEnglish = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _showEnglish = !_showEnglish;
          });
          _controller.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Amma'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;
          double imageHeight = isSmallScreen ? 200 : 400;
          double fontSize = isSmallScreen ? 16 : 24;
          double buttonPaddingHorizontal = isSmallScreen ? 20 : 40;
          double buttonPaddingVertical = isSmallScreen ? 10 : 20;
          double buttonFontSize = isSmallScreen ? 16 : 20;
          double spacing = isSmallScreen ? 20 : 40;

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/teach.png',
                      height: imageHeight,
                    ),
                    SizedBox(height: spacing),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _showEnglish
                              ? 1.0 - _animation.value
                              : _animation.value,
                          child: Text(
                            _showEnglish
                                ? 'Press a button to start'
                                : 'ప్రారంభించడానికి బటన్ నొక్కండి',
                            style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: spacing),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ListeningProvider>()
                            .setLocale(newLocale: 'te-IN');
                        context
                            .read<CardsListProvider>()
                            .loadData(jsonFilename: 'telugu.json');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImageListScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                            horizontal: buttonPaddingHorizontal,
                            vertical: buttonPaddingVertical),
                        textStyle: TextStyle(fontSize: buttonFontSize),
                      ),
                      child: const Text('తెలుగు'),
                    ),
                    SizedBox(height: spacing / 2),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ListeningProvider>()
                            .setLocale(newLocale: 'en_US');
                        context
                            .read<CardsListProvider>()
                            .loadData(jsonFilename: 'english.json');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImageListScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                            horizontal: buttonPaddingHorizontal,
                            vertical: buttonPaddingVertical),
                        textStyle: TextStyle(fontSize: buttonFontSize),
                      ),
                      child: const Text('English'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
