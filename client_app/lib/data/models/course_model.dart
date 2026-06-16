// lib/data/models/course_model.dart
class Course {
  final int id;
  final String title;
  final String description;
  final String departmentName;
  final String gradeLevel;
  final int totalLessons;
  final int completedLessons;
  final String? thumbnailUrl;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.departmentName,
    required this.gradeLevel,
    required this.totalLessons,
    required this.completedLessons,
    this.thumbnailUrl,
  });

  double get progress {
    if (totalLessons == 0) return 0.0;
    return completedLessons / totalLessons;
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      departmentName: json['department_name'] as String,
      gradeLevel: json['grade_level'] as String,
      totalLessons: json['total_lessons'] as int,
      completedLessons: json['completed_lessons'] as int,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'department_name': departmentName,
      'grade_level': gradeLevel,
      'total_lessons': totalLessons,
      'completed_lessons': completedLessons,
      'thumbnail_url': thumbnailUrl,
    };
  }
}