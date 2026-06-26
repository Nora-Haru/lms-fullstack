import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';
//import '../ui/screens/home_screen.dart'; // Untuk mengakses kelas ModuleItem
import '../data/models/module_item.dart';

class ModuleProvider with ChangeNotifier {
  List<ModuleItem> _modules = [];
  bool _isLoading = false;

  List<ModuleItem> get modules => _modules;
  bool get isLoading => _isLoading;

  Future<void> fetchModules(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AuthProvider.baseUrl}/student/modules'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        
        _modules = data.map((json) {
          // Sistem pemetaan warna dan ikon otomatis berdasarkan kategori API
          final category = json['category'] as String;
          IconData icon = Icons.menu_book_rounded;
          Color iconColor = const Color(0xFF2563EB); // Default Blue
          Color iconBg = const Color(0xFFEEF2FF);

          if (category.contains('KOMPUTER') || category.contains('TKJ')) {
            icon = Icons.device_hub_rounded;
            iconColor = const Color(0xFF2563EB);
            iconBg = const Color(0xFFEEF2FF);
          } else if (category.contains('LUNAK') || category.contains('RPL')) {
            icon = Icons.code_rounded;
            iconColor = const Color(0xFFEA580C);
            iconBg = const Color(0xFFFFF7ED);
          } else if (category.contains('MULTIMEDIA') || category.contains('DKV')) {
            icon = Icons.palette_rounded;
            iconColor = const Color(0xFF9333EA);
            iconBg = const Color(0xFFF5F3FF);
          } else if (category.contains('MESIN')) {
            icon = Icons.local_fire_department_rounded;
            iconColor = const Color(0xFF16A34A);
            iconBg = const Color(0xFFF0FDF4);
          }

          return ModuleItem(
            category: category,
            title: json['title'],
            description: json['description'],
            grade: json['grade'],
            completed: json['completed'],
            total: json['total'],
            progress: (json['progress'] as num).toDouble(),
            icon: icon,
            iconColor: iconColor,
            iconBgColor: iconBg,
            modulesList: json['modules_list'] ?? [],
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Error Fetch Modules: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}