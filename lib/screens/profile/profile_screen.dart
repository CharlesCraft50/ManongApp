import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/app_user.dart';
import 'package:manong_application/providers/bottom_nav_provider.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

final Logger logger = Logger('profile_screen');

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  bool isLoading = true;
  AppUser? profile;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await authService.getMyProfile();

      if (mounted) {
        setState(() {
          profile = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load profile. Please try again.';
        });
      }
      logger.severe('Error loading profile: $e');
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorScheme.royalBlue,
            AppColorScheme.royalBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Welcome Text
          Text(
            'Welcome,',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),

          // Phone Number
          Text(
            profile!.phone,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Name and Email if available
          if (profile!.name != null) ...[
            const SizedBox(height: 8),
            Text(
              profile!.name!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],

          if (profile!.email != null) ...[
            const SizedBox(height: 4),
            Text(
              profile!.email!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncompleteProfileCard() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset('assets/icon/manong_setup_acc_icon.png', height: 100),
          const SizedBox(height: 20),
          Text(
            'Complete Your Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColorScheme.royalBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t set up your profile yet. Complete your information for a better experience.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile').then((_) {
                _getProfile();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete Profile',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile').then((_) {
                _getProfile();
              });
            },
          ),
          // const SizedBox(height: 12),
          // _buildActionTile(
          //   icon: Icons.security,
          //   title: 'Security Settings',
          //   subtitle: 'Manage your account security',
          //   onTap: () {
          //     // Navigate to security settings
          //   },
          // ),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Configure your preferences',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Navigate to help
            },
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            onTap: () {
              _showLogoutDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : AppColorScheme.royalBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColorScheme.royalBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColorScheme.backgroundGrey,
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: AppColorScheme.royalBlue),
        );
      },
    );

    try {
      await authService.logout();

      Provider.of<BottomNavProvider>(
        navigatorKey.currentContext!,
        listen: false,
      ).changeIndex(0);

      if (mounted) {
        // Close loading dialog
        Navigator.of(navigatorKey.currentContext!).pop();

        Navigator.of(
          navigatorKey.currentContext!,
        ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      logger.severe('Logout error: $e');
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Something went wrong',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _getProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.royalBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(title: 'Account'),
      backgroundColor: AppColorScheme.backgroundGrey,
      body: RefreshIndicator(
        onRefresh: _getProfile,
        color: AppColorScheme.royalBlue,
        backgroundColor: AppColorScheme.backgroundGrey,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? SizedBox(
                  height:
                      MediaQuery.of(navigatorKey.currentContext!).size.height *
                      0.6,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColorScheme.royalBlue,
                    ),
                  ),
                )
              : errorMessage != null
              ? SizedBox(
                  height:
                      MediaQuery.of(navigatorKey.currentContext!).size.height *
                      0.6,
                  child: _buildErrorState(),
                )
              : profile == null
              ? SizedBox(
                  height:
                      MediaQuery.of(navigatorKey.currentContext!).size.height *
                      0.6,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColorScheme.royalBlue,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileHeader(),
                    if (profile!.name == null || profile!.email == null)
                      _buildIncompleteProfileCard(),
                    _buildProfileActions(),
                    const SizedBox(height: 32),
                  ],
                ),
        ),
      ),
    );
  }
}
