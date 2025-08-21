import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manong_application/theme/colors.dart';

class ImageDialog extends StatelessWidget {
  final File image;

  const ImageDialog({required this.image, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColorScheme.backgroundGrey,
      insetPadding: EdgeInsets.all(8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(image),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
