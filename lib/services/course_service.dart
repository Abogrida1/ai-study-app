import 'package:flutter/foundation.dart';
import '../core/supabase_client.dart';

/// Service for course-related operations.
/// Handles enrollments, assignments, and course data queries.
class CourseService {
  static final CourseService _instance = CourseService._internal();
  factory CourseService() => _instance;
  CourseService._internal();

  /// Get courses a student is enrolled in (with course details)
  Future<List<Map<String, dynamic>>> getEnrolledCourses(String userId) async {
    try {
      final response = await supabase
          .from('enrollments')
          .select('''
            id,
            status,
            enrolled_at,
            course:courses (
              id,
              code,
              name,
              name_ar,
              description,
              credit_hours,
              level_id,
              semester,
              thumbnail_url
            ),
            section:sections (
              id,
              name,
              name_ar
            )
          ''')
          .eq('user_id', userId)
          .eq('status', 'active');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching enrolled courses: $e');
      return [];
    }
  }

  /// Get courses assigned to a doctor or TA
  Future<List<Map<String, dynamic>>> getAssignedCourses(String userId) async {
    try {
      final response = await supabase
          .from('assignments')
          .select('''
            id,
            scope,
            scope_id,
            role,
            course:courses (
              id,
              code,
              name,
              name_ar,
              description,
              credit_hours,
              semester,
              thumbnail_url
            )
          ''')
          .eq('user_id', userId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching assigned courses: $e');
      return [];
    }
  }

  /// Get all available courses (for browsing)
  Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final response = await supabase
          .from('courses')
          .select('''
            id,
            code,
            name,
            name_ar,
            description,
            credit_hours,
            semester,
            thumbnail_url,
            level:levels (
              id,
              name,
              name_ar
            )
          ''')
          .order('code');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching all courses: $e');
      return [];
    }
  }

  /// Get course details with related data
  Future<Map<String, dynamic>?> getCourseDetails(String courseId) async {
    try {
      final response = await supabase
          .from('courses')
          .select('''
            *,
            level:levels (id, name, name_ar),
            lectures (id, title, title_ar, description, video_url, pdf_url, "order", duration_minutes, is_published, created_at),
            requirements (id, title, description, type, file_url, link_url, due_date)
          ''')
          .eq('id', courseId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error fetching course details: $e');
      return null;
    }
  }

  /// Get students enrolled in a specific course (for doctors)
  Future<List<Map<String, dynamic>>> getCourseStudents(String courseId) async {
    try {
      final response = await supabase
          .from('enrollments')
          .select('''
            id,
            status,
            user:users (
              id,
              full_name,
              university_id,
              email,
              avatar_url
            )
          ''')
          .eq('course_id', courseId)
          .eq('status', 'active');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching course students: $e');
      return [];
    }
  }
}
