import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class ApiService {
  // Ganti dengan IP laptopmu jika pakai HP fisik, contoh: 'http://192.168.1.10:8000/api'
  static const String baseUrl = 'http://127.0.0.1:8000/api'; 

  Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['data'];
      return data.map((item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data modul.');
    }
  }
}