import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearlearn/pages/flashcard_view.dart';
import 'package:hearlearn/providers/listening_provider.dart';
import 'package:hearlearn/providers/slider_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [ChangeNotifierProvider(create: (context) => SliderProvider()), ChangeNotifierProvider(create: (_) => ListeningProvider()),
], child: MaterialApp(home: IntroScreen()));
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageListScreen(
                      dbFilePath: 'telugu.txt',
                      locale: 'te-IN',
                    ),
                  ),
                );
              },
              child: const Text('Telugu'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageListScreen(
                      dbFilePath: 'english.txt',
                      locale: 'en_US',
                    ),
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

class ImageListScreen extends StatefulWidget {
  final String dbFilePath;
  final String locale;
  const ImageListScreen(
      {Key? key, required this.dbFilePath, required this.locale})
      : super(key: key);
  @override
  _ImageListScreenState createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  List<Map<String, String>> data = [];
  @override
  void initState() {
    super.initState();
    imageCache.clear();
    _loadData();
  }

  Future<void> _loadData() async {
    final String content =
        await rootBundle.loadString('assets/${widget.dbFilePath}');
    final List<String> lines = content.split('\n');

    final List<Map<String, String>> itemList = [];
    for (String line in lines) {
      if (line.isNotEmpty) {
        final List<String> parts = line.split('" "');
        if (parts.length == 2) {
          final String key = parts[0].replaceAll('"', '');
          final String value = parts[1].replaceAll('"', '');
          itemList.add({'text': key, 'image': value});
        }
      }
    }
    setState(() {
      data = itemList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: data.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Set the number of columns
            crossAxisSpacing: 10, // Spacing between columns
            mainAxisSpacing: 10, // Spacing between rows
            childAspectRatio: 0.8, // Aspect ratio for the items
          ),
          itemBuilder: (context, index) {
            final item = data[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashCardsDetailsScreen(
                      key: UniqueKey(),
                      imgPath: item['image']!.trim(),
                      description: item['text']!,
                      locale: widget.locale, // Your specified locale
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4, // Optional: adds shadow to the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/img/${item['image']!.trim()}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item['text'] ?? '',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
