import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/app_user.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/my_app_bar.dart';

final Logger logger = Logger('edit_profile');

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  AuthService? authService = AuthService();
  bool isLoading = true;
  AppUser? profile;
  String? errorMessage;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _getProfile();
    nameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
  }

  Future<void> _getProfile() async {
    try {
      setState(() {
        isLoading = false;
        errorMessage = null;
      });

      final response = await authService!.getMyProfile();

      if (mounted) {
        setState(() {
          profile = response;
          nameController.text = profile!.name ?? '';
          emailController.text = profile!.email ?? '';
          isLoading = false;
        });

        logger.info('Fetched profile email: ${profile!.email}');
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

  bool hasChanges() {
    if (profile == null) return false; // no profile to compare

    final currentName = nameController.text.trim();
    final currentEmail = emailController.text.trim();

    final originalName = profile!.name?.trim() ?? '';
    final originalEmail = profile!.email?.trim() ?? '';

    return currentName != originalName || currentEmail != originalEmail;
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? "Something went wrong",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.royalBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: _getProfile,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
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
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            profile!.phone,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 26,
            ),
          ),
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
        ],
      ),
    );
  }

  Widget _buildProfileEdit() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFields(title: 'Name', controller: nameController),
          _buildTextFields(title: 'Email', controller: emailController),
        ],
      ),
    );
  }

  Widget _buildTextFields({
    required String title,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.black, fontSize: 14)),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColorScheme.royalBlue),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColorScheme.deepNavyBlue),
              ),
              hintText: controller.text == "" ? "Not Set" : controller.text,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.backgroundGrey,
      appBar: myAppBar(
        title: 'Edit Profile',
        trailing: hasChanges()
            ? GestureDetector(
                onTap: isSaving
                    ? null
                    : () async {
                        if (emailController.text.trim().isNotEmpty &&
                            !RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(emailController.text.trim())) {
                          ScaffoldMessenger.of(
                            navigatorKey.currentContext!,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please enter a valid email address',
                              ),
                            ),
                          );

                          return;
                        }

                        setState(() {
                          isSaving = true;
                        });

                        final result = await authService?.updateProfile(
                          nameController.text,
                          emailController.text,
                        );

                        setState(() {
                          isSaving = false;
                        });

                        if (result != null && result['success'] == true) {
                          ScaffoldMessenger.of(
                            navigatorKey.currentContext!,
                          ).showSnackBar(
                            SnackBar(
                              content: Text('Profile Updated Successfully'),
                            ),
                          );

                          await _getProfile();
                        } else {
                          ScaffoldMessenger.of(
                            navigatorKey.currentContext!,
                          ).showSnackBar(
                            SnackBar(content: Text('Failed to update profile')),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Save', style: TextStyle(color: Colors.white)),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _getProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? SizedBox(
                  height:
                      MediaQuery.of(navigatorKey.currentContext!).size.height *
                      0.8,
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
                  children: [_buildProfileHeader(), _buildProfileEdit()],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
