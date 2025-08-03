import 'package:flutter/material.dart';
import 'package:manong_application/theme/colors.dart';

class GradientHeaderContainer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final List<Widget> children;
  final BorderRadiusGeometry? borderRadius;

  GradientHeaderContainer({
    super.key,
    this.padding,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.borderRadius,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppColorScheme.backgroundGrey,
          height: double.infinity,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorScheme.royalBlue,
                AppColorScheme.deepNavyBlue,
              ],
            ),
            borderRadius: borderRadius ?? BorderRadius.zero,
          ),

          child: SafeArea(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
                crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }
}