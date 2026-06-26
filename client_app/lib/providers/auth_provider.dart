import 'package:flutter/material.dart';
// import '../data/models/course_model.dart';
// import '../data/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  String? _token;
  Map<String, dynamic>? _user;
  
  bool _isLoading = false; // Loading untuk tombol aksi
  bool _isInitializing = true; // Loading khusus saat aplikasi baru pertama kali dibuka

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing; // Tambahkan getter ini
  bool get isAuthenticated => _token != null;
  // Fungsi untuk Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['data']['token'];
        _user = data['data']['user'];

        // Simpan token ke penyimpanan lokal perangkat
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error Login: $e");
      return false;
    }
  }

  // Fungsi untuk Cek Sesi (Dijalankan saat aplikasi pertama kali dibuka)
  Future<void> checkAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('auth_token')) {
      _token = prefs.getString('auth_token');
      await fetchUserData(); // Ambil data user terbaru menggunakan token
    }
    // Setelah pengecekan selesai, ubah status inisialisasi jadi false
    _isInitializing = false;
    notifyListeners();
  }

  // Fungsi untuk Mengambil Data User Terkini
  Future<void> fetchUserData() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token', // Sisipkan Token Sanctum!
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = data['data'];
        notifyListeners();
      } else {
        // Jika token expired/tidak valid, paksa logout
        await logout();
      }
    } catch (e) {
      debugPrint("Error Fetch User: $e");
    }
  }

  // Fungsi untuk Logout
  Future<void> logout() async {
    if (_token != null) {
      // Panggil API logout di backend (opsional, untuk menghapus token di database)
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
    }

    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Hapus token dari perangkat
    notifyListeners();
  }
}