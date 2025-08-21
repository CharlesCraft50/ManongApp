import 'package:flutter/material.dart';

class BottomNavProvider with ChangeNotifier {
  int _selectedIndex = 0;
  PageController? _controller;

  void setController(PageController controller) {
    _controller = controller;
  }

  int get selectedindex => _selectedIndex;
  PageController? get controller => _controller;

  void changeIndex(int newIndex) {
    _selectedIndex = newIndex;
    _controller?.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void setIndex(int newIndex) {
    _selectedIndex = newIndex;
    notifyListeners();
  }
}
