import 'package:flutter/material.dart';
import 'package:manong_application/theme/colors.dart';

PreferredSizeWidget myAppBar({required String title, Widget? trailing}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight + 4),
    child: AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      backgroundColor: AppColorScheme.royalBlueMedium,
      actions: trailing != null
          ? [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Row(children: [trailing]),
              ),
            ]
          : null,
    ),
  );
}
