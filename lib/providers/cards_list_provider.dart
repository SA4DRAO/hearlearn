import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CardsListProvider extends ChangeNotifier {
  List<Map<String, String>> itemList;

  CardsListProvider({List<Map<String, String>>? itemList})
      : itemList = itemList ?? [];

  void loadData({required String dbFilePath}) async {
    final String content = await rootBundle.loadString('assets/$dbFilePath');
    final List<String> lines = content.split('\n');
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
    notifyListeners();
  }

  void reset() {
    itemList = [];
    notifyListeners();
  }
}
