import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  // Light Palette
  static const Color lightBackground = Color(0xFFF8F9FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE6E8EC);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightIndigoAccent = Color(0xFF3B5BFD);
  static const Color lightInputBg = Color(0xFFF1F3F7);

  // Dark Palette
  static const Color darkBackground = Color(0xFF0D1017);
  static const Color darkCard = Color(0xFF161B26);
  static const Color darkBorder = Color(0xFF252C3D);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkIndigoAccent = Color(0xFF5C7CFA);
  static const Color darkInputBg = Color(0xFF1C2230);

  // Semantic category colors
  static const Color workColor = Color(0xFF3B5BFD);
  static const Color studyColor = Color(0xFF10B981);
  static const Color ideasColor = Color(0xFFF59E0B);
  static const Color journalColor = Color(0xFF8B5CF6);
  static const Color personalColor = Color(0xFFEC4899);
  static const Color projectColor = Color(0xFF06B6D4);

  // Helper palette list for custom category creation
  static const List<Color> categoryPalette = [
    Color(0xFF3B5BFD), // Royal Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Crimson
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
  ];

  static Color getBackground(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color getCard(bool isDark) => isDark ? darkCard : lightCard;
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getTextTertiary(bool isDark) => isDark ? darkTextTertiary : lightTextTertiary;
  static Color getAccent(bool isDark) => isDark ? darkIndigoAccent : lightIndigoAccent;
  static Color getInputBg(bool isDark) => isDark ? darkInputBg : lightInputBg;
}
