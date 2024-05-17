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
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => SpeechProvider()),
      ChangeNotifierProvider(create: (_) => ListeningProvider()),
      ChangeNotifierProvider(create: (_) => CardsListProvider()),
    ], child: const MaterialApp(home: IntroScreen()));
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hear Learn'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<ListeningProvider>().setLocale(newLocale: 'te-IN');
                context
                    .read<CardsListProvider>()
                    .loadData(dbFilePath: 'telugu.txt');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageListScreen(),
                  ),
                );
              },
              child: const Text('Telugu'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ListeningProvider>().setLocale(newLocale: 'en_US');
                context
                    .read<CardsListProvider>()
                    .loadData(dbFilePath: 'english.txt');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageListScreen(),
                  ),
                );
              },
              child: const Text('English'),
            ),
          ],
        ),
      ),
    );
  }
}
