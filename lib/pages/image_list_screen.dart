import 'package:flutter/material.dart';
import 'package:hearlearn/pages/flashcard_view.dart';
import 'package:hearlearn/providers/cards_list_provider.dart';
import 'package:hearlearn/providers/listening_provider.dart';
import 'package:provider/provider.dart';

class ImageListScreen extends StatefulWidget {
  const ImageListScreen({Key? key}) : super(key: key);

  @override
  _ImageListScreenState createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Delay the initialization to fetch data from provider
    Future.microtask(() {
      final cardsListProvider = context.read<CardsListProvider>();
      if (cardsListProvider.itemList.isNotEmpty) {
        setState(() {
          _selectedCategory = cardsListProvider.itemList.keys.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool value) async {
        context.read<CardsListProvider>().reset();
        context.read<ListeningProvider>().reset();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Cards'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<CardsListProvider>(
                builder: (context, cardsListProvider, _) {
                  if (_selectedCategory == null &&
                      cardsListProvider.itemList.isNotEmpty) {
                    _selectedCategory = cardsListProvider.itemList.keys.first;
                  }
                  return DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: cardsListProvider.itemList.keys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 8,
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      color: Colors.blueAccent,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<CardsListProvider>(
                builder: (context, cardsListProvider, _) {
                  List<Map<String, String>> itemsToShow =
                      _selectedCategory != null
                          ? cardsListProvider.itemList[_selectedCategory] ?? []
                          : cardsListProvider.itemList.values
                              .expand((e) => e)
                              .toList();
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: itemsToShow.length,
                    itemBuilder: (context, index) {
                      Map<String, String> item = itemsToShow[index];
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
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  'assets/img/${item['image']}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  item['text']!,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
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
          ],
        ),
      ),
    );
  }
}
