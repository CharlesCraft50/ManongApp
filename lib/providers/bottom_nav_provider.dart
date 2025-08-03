import 'package:flutter/material.dart';

class BottomNavProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedindex => _selectedIndex;

  void changeIndex(int newIndex) {
    _selectedIndex = newIndex;
    notifyListeners();
  }
}