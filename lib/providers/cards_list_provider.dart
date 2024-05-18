import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CardsListProvider extends ChangeNotifier {
  late Map<String, List<Map<String, String>>> itemList;

  CardsListProvider({Map<String, List<Map<String, String>>>? itemList})
      : itemList = itemList ?? {};

  Future<void> loadData({required String jsonFilename}) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/$jsonFilename');
      final Map<String, dynamic> data = json.decode(jsonString);

      // Clear the existing itemList
      itemList.clear();

      // Iterate over each category
      data['categories']?.forEach((category, items) {
        if (items is List) {
          itemList[category] = [];
          for (final item in items) {
            if (item is Map<String, dynamic> &&
                item.containsKey('name') &&
                item.containsKey('filename')) {
              itemList[category]!.add({
                'text': item['name'] ?? '',
                'image': item['filename'] ?? '',
              });
            }
          }
        }
      });

      notifyListeners();
    } catch (e) {
      // Handle errors, such as file not found or JSON parsing errors
      print('Error loading data: $e');
    }
  }

  void reset() {
    itemList.clear();
    notifyListeners();
  }
}
