import 'package:flutter/material.dart';
import 'package:manong_application/theme/colors.dart';

PreferredSizeWidget myAppBar({
  required String title,
}) {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.white),
    title: Text(
      'Register', 
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    backgroundColor: AppColorScheme.royalBlue,
  );
}