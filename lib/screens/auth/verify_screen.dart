import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/step_appbar.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  AuthService? _authService;
  String _verificationId = "";
  String _phoneNumber = "";
  bool _isError = false;
  bool _isSuccess = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _authService = args['authService'];
    _verificationId = args['verificationId'];
    _phoneNumber = args['phoneNumber'];
  }

  void _verifySmsCode(String smsCode) async {
    setState(() {
      _isError = false;
      _isSuccess = false;
      _isLoading = true;
    });

    try {
      final response = await _authService!.completePhoneAuth(
        _verificationId,
        smsCode,
      );

      // ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      //   SnackBar(
      //     content: Text('Phone number verified successfully!'),
      //     backgroundColor: Colors.green,
      //   ),
      // );

      setState(() {
        _isError = false;
        _isSuccess = true;
        _isLoading = false;
      });

      Navigator.pushNamedAndRemoveUntil(
        navigatorKey.currentContext!,
        '/',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isError = true;
        _isSuccess = false;
        _isLoading = false;
      });

      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid verification code. Please try again.';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Invalid verification ID. Please restart the process.';
          break;
        case 'session-expired':
          errorMessage =
              'Verification session expired. Please request a new code.';
          break;
        default:
          errorMessage = 'Verification failed: ${e.message}';
      }

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() {
        _isError = true;
        _isSuccess = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resendCode() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Navigate back to phone input screen or trigger resend
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please request a new verification code'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StepAppbar(
        title: 'Verification OTP',
        currentStep: 2,
        totalSteps: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter 6-digit code', style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),
              Text(
                'We sent a verification code to $_phoneNumber',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Stack(
                children: [
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
                      if (!_isLoading) {
                        _verifySmsCode(value);
                      }
                    },
                  ),

                  if (_isLoading) ...[
                    Positioned(
                      child: Container(
                        color: Colors.white.withOpacity(0.8),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColorScheme.royalBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _resendCode,
                  child: Text(
                    'Didn\'t receive the code? Resend',
                    style: TextStyle(
                      color: AppColorScheme.royalBlue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // Status messages
              if (_isSuccess) ...[
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Verification successful!',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ],

              if (_isError) ...[
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verification failed. Please check the code and try again.',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
