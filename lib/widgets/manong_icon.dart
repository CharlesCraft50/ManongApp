import 'package:flutter/material.dart';
import 'package:manong_application/theme/colors.dart';

class ManongIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}