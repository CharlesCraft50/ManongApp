import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/screens/home/home_screen.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/hint_phone_numbers.dart';
import 'package:manong_application/utils/snackbar_utils.dart';
import 'package:manong_application/widgets/my_app_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  PhoneNumber? phone;
  String selectedCountry = 'PH';
  bool _isLoading = false;

  void _submitRegisterPhone() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      if (_formKey.currentState!.validate()) {
        if (phone == null || phone!.number.isEmpty) {
          setState(() {
            _isLoading = false;
          });

          SnackBarUtils.showWarning(context, 'Phone number cannot be empty');
          return;
        }
      }

      authService.verifyPhoneNumber(
        phoneNumber: phone!.completeNumber,
        onAutoVerified: (credential) async {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          try {
            final result = await FirebaseAuth.instance.signInWithCredential(
              credential,
            );
            if (result.user != null) {
              SnackBarUtils.showSuccess(
                navigatorKey.currentContext!,
                'User signed in automatically!',
              );

              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false,
                );
              }
            }
          } catch (e) {
            SnackBarUtils.showError(
              navigatorKey.currentContext!,
              'Auto sign-in failed: $e',
            );
          }
        },
        onFailed: (error) {
          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;

          SnackBarUtils.showError(
            context,
            'Verification failed: ${error.message}',
          );
        },
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;

          SnackBarUtils.showSuccess(context, 'Code Sent! Check your messages.');

          Navigator.pushNamed(
            navigatorKey.currentContext!,
            '/verify',
            arguments: {
              'verificationId': verificationId,
              'authService': authService,
              'phoneNumber': phone!.completeNumber,
            },
          );
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      SnackBarUtils.showWarning(context, 'Please enter a valid phone number');
    }
  }

  @override
  Widget build(BuildContext context) {
    String exampleNumber = getExampleNumber(selectedCountry);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: myAppBar(title: 'Register'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text("Mobile"),
              SizedBox(height: 20),
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: exampleNumber,
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                ),
                initialCountryCode: 'PH',
                onChanged: (phone) {
                  this.phone = phone;
                },
                onCountryChanged: (country) {
                  setState(() {
                    selectedCountry = country.code;
                  });
                },
                validator: (phone) {
                  if (phone == null || phone.number.isEmpty) {
                    return 'Please enter your phone number';
                  } else {
                    return null;
                  }
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: "Send me a verification code through "),
                    TextSpan(
                      text: "SMS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorScheme.royalBlue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isLoading ? null : _submitRegisterPhone,
                      child: _isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
