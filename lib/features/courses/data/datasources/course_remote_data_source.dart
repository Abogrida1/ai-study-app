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
      final response = await supabaseClient
          .from('enrollments')
          .select('course:courses (*)')
          .eq('user_id', userId)
          .eq('status', 'active');
      
      return (response as List).map((e) => CourseModel.fromJson(e['course'])).toList();
    } catch (e) {
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
