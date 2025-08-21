import 'package:flutter/material.dart';
import 'package:manong_application/screens/bookmarks/bookmarks_screen.dart';
import 'package:manong_application/screens/home/home_screen.dart';
import 'package:manong_application/screens/profile/profile_screen.dart';
import 'package:manong_application/theme/colors.dart';

class BottomNavSwipe extends StatelessWidget {
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onItemTapped;
  final List<Widget> pages;

  const BottomNavSwipe({
    super.key,
    required this.pages,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: pages,
          ),
        ),
        BottomNavigationBar(
          backgroundColor: AppColorScheme.backgroundGrey,
          selectedItemColor: AppColorScheme.deepNavyBlue,
          unselectedItemColor: Colors.grey,
          currentIndex: currentIndex,
          onTap: onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'My Requests',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ],
    );
  }
}
