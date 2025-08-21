import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/screens/home/home_screen.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/hint_phone_numbers.dart';
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
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      
      if (phone == null || phone!.number.isEmpty) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Phone number cannot be empty')),
        );

        return;
      }

      authService.verifyPhoneNumber(
        phoneNumber: phone!.completeNumber,
        onAutoVerified:(credential) async {
          setState(() {
            _isLoading = false;
          });
        
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
            if (value.user != null) {
              ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                SnackBar(content: Text('User signed in automatically!')),
              );
              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HomeScreen()
                ), 
                (route) => false
              );
            }
          });
          
        }, 
        onFailed:(error) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed $error')),
          );
        }, 
        onCodeSent:(verificationId) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code Sent! Check your messages.')),
          );

          Navigator.pushNamed(
            context, 
            '/verify', 
            arguments: {
              'verificationId': verificationId,
              'authService': authService,
              'phoneNumber': phone!.completeNumber,
            }
          );
        },
      );
    } else {
      SnackBar(content: Text('Please enter a valid phone number'));
    }
  }

  @override
  Widget build(BuildContext context) {
    
    String exampleNumber = getExampleNumber(selectedCountry);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: myAppBar(
        title: 'Register'
      ),
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
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
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
                  validator:(phone) {
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
                        TextSpan(
                          text: "Send me a verification code through "
                        ),
                        TextSpan(
                          text: "SMS", 
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
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
                              "Next", style: TextStyle(
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