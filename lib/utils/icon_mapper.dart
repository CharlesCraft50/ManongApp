import 'package:flutter/material.dart';

IconData getIconFromName(String iconName) {
  switch (iconName) {
    case 'plumbing':
      return Icons.plumbing;
    case 'electrical_services':
      return Icons.electrical_services;
    case 'construction':
      return Icons.construction;
    case 'format_paint':
      return Icons.format_paint;
    case 'build':
      return Icons.build;
    case 'security':
      return Icons.security;
    default:
      return Icons.miscellaneous_services; // fallback icon
  }
}
