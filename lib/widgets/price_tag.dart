import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  final int min;
  final int max;
  final String currency;
  final TextStyle? style;

  const PriceTag({
    super.key,
    required this.min,
    required this.max,
    this.currency = '₱', // default to PHP
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$currency$min–$max',
      style: style ??
          const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
    );
  }
}