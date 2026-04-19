import 'package:flutter/foundation.dart';
import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.code,
    required super.name,
    required super.nameAr,
    super.description,
    super.creditHours,
    super.semester,
    super.thumbnailUrl,
    super.professorName,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // 1. Determine the source of course data (could be top-level or nested in an enrollment)
    final Map<String, dynamic> courseData = json.containsKey('course') ? json['course'] : json;

    String? profName;

    String? extractName(Map<String, dynamic>? userData) {
      if (userData == null) return null;

      String? valueFor(String key) {
        final dynamic value = userData[key];
        return value is String && value.trim().isNotEmpty ? value.trim() : null;
      }

      final candidates = [
        'full_name',
        'name',
        'fullName',
        'display_name',
        'displayName',
        'professor_name',
        'instructor_name',
        'lead_instructor',
        'doctor_name',
        'prof_name',
        'faculty_name',
        'professor',
        'instructor',
      ];

      for (final candidate in candidates) {
        final found = valueFor(candidate);
        if (found != null) return found;
      }

      for (final entry in userData.entries) {
        final key = entry.key.toString().toLowerCase();
        final value = entry.value;
        if (value is String && value.trim().isNotEmpty && key.contains('name')) {
          return value.trim();
        }
      }

      return null;
    }

    String? searchCourseDataInstructor(Map<String, dynamic> data) {
      const courseKeys = [
        'professor_name',
        'instructor_name',
        'lead_instructor',
        'professor',
        'instructor',
        'doctor',
      ];
      for (final key in courseKeys) {
        final dynamic value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      for (final entry in data.entries) {
        final key = entry.key.toString().toLowerCase();
        final value = entry.value;
        if (value is String && value.trim().isNotEmpty && key.contains('prof') && key.contains('name')) {
          return value.trim();
        }
      }
      return null;
    }

    // 2. Gather assignments from the course
    final assignmentsRaw = courseData['assignments'];
    final List<dynamic> assignments = assignmentsRaw is List ? assignmentsRaw : [];

    // 3. Search for a professor (doctor) prioritizing real ones
    Map<String, dynamic>? selectedAssignment;

    for (final a in assignments) {
      if (a is Map<String, dynamic>) {
        final role = a['role']?.toString().toLowerCase();
        if (role == 'doctor' || role == 'professor' || role == 'instructor' || role == 'lecturer') {
          final userData = a['user'] as Map<String, dynamic>? ??
              a['profiles'] as Map<String, dynamic>? ??
              a;
          final name = extractName(userData);
          if (name != null && userData['university_id'] != 'prof_001') {
            selectedAssignment = a;
            break;
          }
          selectedAssignment ??= a;
        }
      }
    }

    // 4. If doctor/professor role wasn't found, take the first assignment with a name
    if (selectedAssignment == null) {
      for (final a in assignments) {
        if (a is Map<String, dynamic>) {
          final userData = a['user'] as Map<String, dynamic>? ??
              a['profiles'] as Map<String, dynamic>? ??
              a;
          final name = extractName(userData);
          if (name != null) {
            selectedAssignment = a;
            break;
          }
        }
      }
    }

    // 5. Extract the name from the selected assignment
    if (selectedAssignment != null) {
      final userData = selectedAssignment['user'] as Map<String, dynamic>? ??
          selectedAssignment['profiles'] as Map<String, dynamic>? ??
          selectedAssignment;
      profName = extractName(userData);
    }

    // 6. Fallbacks for instructor metadata fields on course
    profName ??= searchCourseDataInstructor(courseData);

    if (profName == null) {
      debugPrint('⚠️ [CourseModel.fromJson] missing professor for course_id=${courseData['id']} code=${courseData['code']}');
      debugPrint('⚠️ [CourseModel.fromJson] courseData keys=${courseData.keys.toList()}');
      debugPrint('⚠️ [CourseModel.fromJson] assignments=${courseData['assignments']}');
    }

    return CourseModel(
      id: courseData['id'] ?? '',
      code: courseData['code'] ?? '',
      name: courseData['name'] ?? '',
      nameAr: courseData['name_ar'] ?? '',
      description: courseData['description'],
      creditHours: courseData['credit_hours'],
      semester: courseData['semester'],
      thumbnailUrl: courseData['thumbnail_url'],
      professorName: profName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'credit_hours': creditHours,
      'semester': semester,
      'thumbnail_url': thumbnailUrl,
    };
  }
}
