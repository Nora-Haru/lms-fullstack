import 'package:flutter/material.dart';

class AppColors {
  // Flag global yang dikendalikan oleh ThemeProvider
  static bool isDarkMode = false;

  static Color get background => isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F7FF);
  static Color get surface => isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  static Color get primary => const Color(0xFF2563EB); // Biru tetap sama
  static Color get primaryLight => isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFEEF2FF);
  static Color get textPrimary => isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
  static Color get textSecondary => isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get textMuted => isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
  static Color get border => isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get chipBorder => isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
  static Color get progressBg => isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get badgeBg => isDarkMode ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
  static Color get badgeText => isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
  static Color get progressFilter => isDarkMode ? const Color(0xFFEA580C) : const Color(0xFFEF6C00);
  static Color get gradeChip => isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  static Color get gradeChipText => isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
  static Color get primaryText => isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
}