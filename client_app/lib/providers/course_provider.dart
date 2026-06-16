import 'package:flutter/material.dart';
import '../data/models/course_model.dart';
import '../data/services/api_service.dart';
import 'package:flutter/foundation.dart';

class CourseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

  Future<void> getCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _courses = await _apiService.fetchCourses();
    } catch (e) {
  debugPrint('Error fetching courses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}