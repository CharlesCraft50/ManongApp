import 'package:flutter/material.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/providers/bottom_nav_provider.dart';
import 'package:manong_application/screens/favorites/favorite_screen.dart';
import 'package:manong_application/screens/home/home_screen.dart';
import 'package:manong_application/screens/profile/profile_screen.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/widgets/auth_footer.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _token;

  AuthService _authService = AuthService();
  
  final List<Widget> _pages = [
    HomeScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _authService.getToken();

    if (token == null) {
      return;
    }

    setState(() {
      _token = token;
    });

  }
  
  @override
  Widget build(BuildContext context) {

    final navProvider = Provider.of<BottomNavProvider>(navigatorKey.currentContext!);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: false,
      body: IndexedStack(
        index: navProvider.selectedindex,
        children: _pages,
      ),
      bottomNavigationBar: _token != null
        ? BottomNavigationBar(
          currentIndex: navProvider.selectedindex,
          backgroundColor: AppColorScheme.backgroundGrey,
          selectedItemColor: AppColorScheme.deepNavyBlue,
          unselectedItemColor: Colors.grey,
          onTap: navProvider.changeIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favorites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
      )

      : AuthFooter(),
      
    );
  }
}