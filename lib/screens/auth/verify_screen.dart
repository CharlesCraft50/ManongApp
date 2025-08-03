import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/my_app_bar.dart';

class VerifyScreen extends StatefulWidget {
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  GlobalKey _formKey = GlobalKey<FormState>();
  AuthService? _authService;
  String? _verificationId;
  bool _isError = false;
  bool _isSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _authService = args['authService'];
    _verificationId = args['verificationId'];
  }

  void _verifySmsCode(String smsCode) async {
    setState(() {
      _isError = false; // clear error before verifying
      _isSuccess = false; // clear success if retrying
    });

    try {
      await _authService!.signInWithCredential(_verificationId, smsCode);

      // Navigate or show success message
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Phone number verified successfully!')),
      );

      setState(() {
        _isError = false;
        _isSuccess = true;
      });

      Navigator.pushReplacementNamed(navigatorKey.currentContext!, '/'); // or wherever

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isError = true;
        _isSuccess = false;
      });

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.message}')),
      );
    } catch (e) {
      setState(() {
        _isError = true;
        _isSuccess = false;
      });
      
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: myAppBar(
        title: 'Verification OTP'
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter 6-digit code', style: TextStyle(fontSize: 20),),
              SizedBox(height: 20),
              PinCodeFields(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                length: 6,
                activeBackgroundColor: Colors.blue.shade50,
                activeBorderColor: _isSuccess
                    ? Colors.green
                    : _isError
                        ? Colors.red
                        : AppColorScheme.royalBlue,
                borderColor: _isSuccess
                    ? Colors.green
                    : _isError
                        ? Colors.red
                        : Colors.grey,
                fieldBorderStyle: FieldBorderStyle.square,
                borderRadius: BorderRadius.circular(8),
                borderWidth: 2.0,
                fieldHeight: 60,
                fieldWidth: 50,
                textStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                onChange: (value) {
                  if (value.length < 6) {
                    setState(() {
                      _isError = false;
                      _isSuccess = false;
                    });
                  }
                },
                onComplete: (value) {
                  _verifySmsCode(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}