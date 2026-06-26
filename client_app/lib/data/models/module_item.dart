import 'package:flutter/material.dart';

// Model ini sekarang merepresentasikan "Mata Pelajaran"
class ModuleItem {
  final String category;
  final String title;
  final String description;
  final String grade;
  final int completed;
  final int total;
  final double progress;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<dynamic> modulesList; // <--- 1. TAMBAHKAN INI

  const ModuleItem({
    required this.category,
    required this.title,
    required this.description,
    required this.grade,
    required this.completed,
    required this.total,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.modulesList, // <--- 2. TAMBAHKAN INI
  });
}