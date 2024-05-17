import 'package:flutter/material.dart';
import 'package:hearlearn/pages/flashcard_view.dart';
import 'package:hearlearn/providers/cards_list_provider.dart';
import 'package:hearlearn/providers/listening_provider.dart';
import 'package:provider/provider.dart';

class ImageListScreen extends StatelessWidget {
  const ImageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool value) {
        context.read<CardsListProvider>().reset();
        context.read<ListeningProvider>().reset();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Flashcards"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: context.watch<CardsListProvider>().itemList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Set the number of columns
              crossAxisSpacing: 10, // Spacing between columns
              mainAxisSpacing: 10, // Spacing between rows
              childAspectRatio: 0.8, // Aspect ratio for the items
            ),
            itemBuilder: (context, index) {
              final item = context.watch<CardsListProvider>().itemList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashCardScreen(
                        key: UniqueKey(),
                        imgPath: item['image']!.trim(),
                        description: item['text']!,
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
      ),
    );
  }
}
