import 'package:flutter/material.dart';
import 'package:manong_application/theme/colors.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
        
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.royalBlueLight,
                      padding: EdgeInsets.symmetric(horizontal: 52, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Sign Up', style: TextStyle(fontSize: 16, color: AppColorScheme.royalBlueDark),),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.royalBlue,
                      padding: EdgeInsets.symmetric(horizontal: 52, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Login', style: TextStyle(fontSize: 16, color: Colors.white),),
                  ),
                ],
              ),
              SizedBox(height: 18),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      style: TextStyle(color: Colors.black),
                      text: 'Need help? '
                    ),
                    TextSpan(
                      style: TextStyle(color: Colors.blue),
                      text: 'Visit our Help Centre.'
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
      ),
    );
  }
}