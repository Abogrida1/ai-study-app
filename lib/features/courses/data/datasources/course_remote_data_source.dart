import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../../../../core/error/failures.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getAllCourses();
  Future<List<CourseModel>> getEnrolledCourses(String userId);
  Future<List<CourseModel>> getAssignedCourses(String userId);
  Future<CourseModel> getCourseDetails(String courseId);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final SupabaseClient supabaseClient;

  CourseRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final response = await supabaseClient.from('courses').select().order('code');
      return (response as List).map((e) => CourseModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<CourseModel>> getEnrolledCourses(String userId) async {
    try {
      // خطوة 1: جلب المواد المسجلة للطالب
      final enrollmentResponse = await supabaseClient
          .from('enrollments')
          .select('*, course:courses (*)')
          .eq('user_id', userId)
          .eq('status', 'active');

      final enrollments = enrollmentResponse as List;
      debugPrint('🔍 [getEnrolledCourses] enrollments count=${enrollments.length}');

      final courses = enrollments.map((e) => CourseModel.fromJson(e)).toList();
      final courseIds = courses.map((c) => c.id).toList();

      if (courseIds.isEmpty) {
        return courses;
      }

      // خطوة 2: جلب جميع الدكاترة مع مواديهم (مثل الأدمن)
      final doctorResponse = await supabaseClient
          .from('users')
          .select('id, full_name, university_id, assignments(course_id, role)')
          .eq('role', 'doctor');

      final doctors = (doctorResponse as List)
          .whereType<Map<String, dynamic>>()
          .toList();

      debugPrint('🔍 [getEnrolledCourses] doctors count=${doctors.length}');

      // خطوة 3: بناء خريطة من course_id إلى professor name
      final Map<String, String> professorByCourse = {};
      for (final doctor in doctors) {
        final doctorName = doctor['full_name'] as String?;
        final assignments = doctor['assignments'] as List? ?? [];
        
        for (final assignment in assignments) {
          if (assignment is Map<String, dynamic>) {
            final role = assignment['role']?.toString().toLowerCase();
            final courseId = assignment['course_id'] as String?;
            
            if (role == 'doctor' && courseId != null && doctorName != null) {
              if (!professorByCourse.containsKey(courseId)) {
                professorByCourse[courseId] = doctorName.trim();
                debugPrint('🔍 [getEnrolledCourses] mapped course=$courseId => doctor=$doctorName');
              }
            }
          }
        }
      }

      debugPrint('🔍 [getEnrolledCourses] professorByCourse mapped=${professorByCourse.length}');

      // خطوة 4: دمج البيانات مع المواد
      final updatedCourses = courses.map((course) {
        final professorName = professorByCourse[course.id];
        if (professorName != null) {
          debugPrint('🔍 [getEnrolledCourses] course=${course.code} professor=$professorName ✅');
          return CourseModel(
            id: course.id,
            code: course.code,
            name: course.name,
            nameAr: course.nameAr,
            description: course.description,
            creditHours: course.creditHours,
            semester: course.semester,
            thumbnailUrl: course.thumbnailUrl,
            professorName: professorName,
          );
        }
        debugPrint('🔍 [getEnrolledCourses] course=${course.code} professor=null');
        return course;
      }).toList();

      return updatedCourses;
    } catch (e) {
      debugPrint('❌ [getEnrolledCourses] ERROR: $e');
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<CourseModel>> getAssignedCourses(String userId) async {
    try {
      debugPrint('🔍 [getAssignedCourses] userId=$userId');

      final response = await supabaseClient
          .from('assignments')
          .select('course:courses (*)')
          .eq('user_id', userId);

      debugPrint('🔍 [getAssignedCourses] raw response: $response');
      debugPrint('🔍 [getAssignedCourses] row count: ${(response as List).length}');

      final courses = response
          .where((e) => e['course'] != null)
          .map((e) => CourseModel.fromJson(e['course']))
          .toList();

      debugPrint('🔍 [getAssignedCourses] courses after filter: ${courses.length}');
      return courses;
    } catch (e) {
      debugPrint('❌ [getAssignedCourses] ERROR: $e');
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<CourseModel> getCourseDetails(String courseId) async {
    try {
      final response = await supabaseClient
          .from('courses')
          .select()
          .eq('id', courseId)
          .single();
          
      return CourseModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
