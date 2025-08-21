import 'package:flutter/material.dart';
import 'package:manong_application/theme/colors.dart';

class GradientHeaderContainer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final List<Widget> children;
  final BorderRadiusGeometry? borderRadius;
  final double? height;
  final double? width;

  const GradientHeaderContainer({
    super.key,
    this.padding,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.borderRadius,
    required this.children,
    this.height,
    this.width,
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
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(248, 79, 119, 184),
                AppColorScheme.royalBlue,
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