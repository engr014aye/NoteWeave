import 'package:flutter/material.dart';

class AppStyles {
  static const String fontPrimary = 'Poppins';
  static const String fontSecondary = 'Inter';

  static TextStyle titleLarge(Color color) => TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle titleMedium(Color color) => TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle titleSmall(Color color) => TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: color,
      );

  static TextStyle bodyLarge(Color color, {double scaleFactor = 1.0}) => TextStyle(
        fontFamily: fontSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 16 * scaleFactor,
        height: 1.55,
        color: color,
      );

  static TextStyle bodyMedium(Color color, {double scaleFactor = 1.0}) => TextStyle(
        fontFamily: fontSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 14 * scaleFactor,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySmall(Color color) => TextStyle(
        fontFamily: fontSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: color,
      );

  static TextStyle labelBold(Color color) => TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.2,
        color: color,
      );
}
