import 'package:flutter/material.dart';
import 'package:hearlearn/providers/listening_provider.dart';
import 'package:hearlearn/providers/speech_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class FlashCardScreen extends StatelessWidget {
  FlashCardScreen({
    super.key,
    required this.imgPath,
    required this.description,
  });

  final String imgPath;
  final String description;

  Future<bool> checkMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;
    return status.isGranted;
  }

  bool wasTextColorGreen = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool value) {
        context.read<ListeningProvider>().reset();
      },
      child: FutureBuilder(
        future: checkMicrophonePermission(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final textColor = context.watch<ListeningProvider>().textColor;
            final isGreen = textColor == Colors.green;

            if (isGreen && !wasTextColorGreen) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Center(child: Text('Good Job!')),
                          content: const Center(
                            child: Text(
                              '😊', // Smiley face emoji
                              style: TextStyle(
                                  fontSize: 50), // Adjust font size as needed
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                wasTextColorGreen = true;
                              },
                              child: const Center(child: Text('Close')),
                            ),
                          ],
                        ));
              });
            }

            if (!isGreen) {
              wasTextColorGreen = false;
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Card'),
                centerTitle: true,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isTablet = constraints.maxWidth > 600;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.asset(
                              'assets/img/$imgPath',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<SpeechProvider>().speak(
                                    text: description,
                                    locale: context
                                        .read<ListeningProvider>()
                                        .locale,
                                  );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play Description'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            description,
                            style: TextStyle(
                                fontSize: isTablet ? 24 : 20, color: textColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Speed: ${context.watch<SpeechProvider>().speed.toStringAsFixed(1)}',
                                style: TextStyle(fontSize: isTablet ? 18 : 16),
                              ),
                              Slider(
                                value: context.watch<SpeechProvider>().speed,
                                min: 0.05,
                                max: 2.0,
                                onChanged: (value) => context
                                    .read<SpeechProvider>()
                                    .setSpeechRate(newSpeed: value),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pitch: ${context.watch<SpeechProvider>().pitch.toStringAsFixed(1)}',
                                style: TextStyle(fontSize: isTablet ? 18 : 16),
                              ),
                              Slider(
                                value: context.watch<SpeechProvider>().pitch,
                                min: 0.05,
                                max: 2.0,
                                onChanged: (value) => context
                                    .read<SpeechProvider>()
                                    .setPitch(newPitch: value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context
                                  .watch<ListeningProvider>()
                                  .microphoneColor,
                            ),
                            child: InkWell(
                              onTap: () => context
                                  .read<ListeningProvider>()
                                  .startListening(description: description),
                              child: const Icon(
                                Icons.mic,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                maxLines: null,
                                controller: TextEditingController(
                                  text: context.watch<ListeningProvider>().text,
                                ),
                                style: TextStyle(
                                  fontSize: isTablet ? 24 : 20,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'Press the Microphone Icon',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
