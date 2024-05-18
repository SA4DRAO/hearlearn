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
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isTablet = constraints.maxWidth > 600;
              int crossAxisCount = isTablet ? 3 : 2;
              double childAspectRatio = isTablet ? 0.9 : 0.8;
              double spacing = isTablet ? 20 : 10;
              double fontSize = isTablet ? 18 : 16;

              return GridView.builder(
                itemCount: context.watch<CardsListProvider>().itemList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Number of columns
                  crossAxisSpacing: spacing, // Spacing between columns
                  mainAxisSpacing: spacing, // Spacing between rows
                  childAspectRatio:
                      childAspectRatio, // Aspect ratio for the items
                ),
                itemBuilder: (context, index) {
                  final item =
                      context.watch<CardsListProvider>().itemList[index];
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
                              style: TextStyle(fontSize: fontSize),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
