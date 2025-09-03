import 'package:flutter/material.dart';
import 'package:manong_application/utils/icon_mapper.dart';

Widget iconCard({required Color iconColor, required String iconName}) {
  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: iconColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(getIconFromName(iconName), color: Colors.white, size: 24),
  );
}
