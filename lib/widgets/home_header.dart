import 'package:flutter/material.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/gradient_text.dart';

class HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorScheme.royalBlue,
            AppColorScheme.deepNavyBlue,
          ],
        ),
      ),

      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColorScheme.gold.withOpacity(0.4),
                    ),
                    child: Icon(
                      Icons.plumbing_rounded,
                      color: AppColorScheme.goldLight,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 4),
                  GradientText(
                    text: 'Manong App',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    gradient: LinearGradient(
                      colors: [
                      AppColorScheme.goldLight,
                      AppColorScheme.gold,
                      AppColorScheme.goldDeep,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Your trusted on-demand service platform.\nConnect with skilled professionals for all your home needs!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[100],
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Available in Metro Manila',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 24),
                  Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                  SizedBox(width: 4),
                  Text(
                    '24/7 Service',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}