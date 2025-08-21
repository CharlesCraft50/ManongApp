import 'package:flutter/material.dart';
import 'package:manong_application/providers/bottom_nav_provider.dart';
import 'package:manong_application/screens/home/home_screen.dart';
import 'package:manong_application/screens/profile/profile_screen.dart';
import 'package:manong_application/screens/service_requests/service_requests_screen.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/widgets/auth_footer.dart';
import 'package:manong_application/widgets/bottom_nav_swipe.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? _token;

  final AuthService _authService = AuthService();
  late final PageController _pageController = PageController();
  bool isLoading = true;

  final List<Widget> _pages = const [
    HomeScreen(),
    ServiceRequestsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<BottomNavProvider>(
      context,
      listen: false,
    ).setController(_pageController);
    _loadToken();
  }

  Future<void> _loadToken() async {
    setState(() {
      isLoading = true;
    });

    final token = await _authService.getLaravelToken();

    setState(() {
      isLoading = false;
    });

    if (token == null) {
      return;
    }

    setState(() {
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: false,
      body: _token != null
          ? BottomNavSwipe(
              pages: _pages,
              pageController: _pageController,
              currentIndex: navProvider.selectedindex,
              onPageChanged: (index) =>
                  setState(() => navProvider.setIndex(index)),
              onItemTapped: (index) {
                setState(() => navProvider.changeIndex(index));
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          : Stack(
              children: [
                // Main content
                const Positioned.fill(
                  child: HomeScreen(), // or any widget you want behind
                ),

                // Footer pinned at bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: isLoading
                      ? const SizedBox(
                          height: 10,
                          child: CircularProgressIndicator(
                            color: AppColorScheme.royalBlue,
                          ),
                        )
                      : const AuthFooter(),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
