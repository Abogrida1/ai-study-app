import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grade_model.dart';
import '../../../../core/error/failures.dart';

abstract class GradesRemoteDataSource {
  Future<List<Map<String, dynamic>>> getEnrolledStudentsWithGrades(String courseId);
  Future<void> updateGrade(GradeModel grade);
}

class GradesRemoteDataSourceImpl implements GradesRemoteDataSource {
  final SupabaseClient supabaseClient;

  GradesRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getEnrolledStudentsWithGrades(String courseId) async {
    try {
      // Fetch enrolled students
      final enrollments = await supabaseClient
          .from('enrollments')
          .select('user_id, status, users!user_id(id, full_name, university_id)')
          .eq('course_id', courseId)
          .eq('status', 'active');

      // Fetch grades for this course
      final gradesResponse = await supabaseClient
          .from('course_grades')
          .select()
          .eq('course_id', courseId);
          
      final Map<String, GradeModel> gradesMap = {};
      for (var row in gradesResponse as List) {
        final grade = GradeModel.fromJson(row);
        gradesMap[grade.studentId] = grade;
      }

      // Merge data
      final List<Map<String, dynamic>> result = [];
      for (var row in enrollments as List) {
        final user = row['users'];
        if (user == null) continue;
        
        final studentId = user['id'];
        result.add({
          'student_id': studentId,
          'full_name': user['full_name'] ?? 'Unknown',
          'university_id': user['university_id'] ?? '',
          'grade': gradesMap[studentId] ?? GradeModel(
            id: '', 
            courseId: courseId, 
            studentId: studentId, 
          ),
        });
      }

      return result;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateGrade(GradeModel grade) async {
    try {
      if (grade.id.isEmpty) {
        // Insert
        await supabaseClient.from('course_grades').insert({
          'course_id': grade.courseId,
          'student_id': grade.studentId,
          'midterm': grade.midterm,
          'practical': grade.practical,
          'oral': grade.oral,
          'tasks_attendance': grade.tasksAttendance,
          'final_exam': grade.finalExam,
          'bonus': grade.bonus,
        });
      } else {
        // Update
        await supabaseClient.from('course_grades').update({
          'midterm': grade.midterm,
          'practical': grade.practical,
          'oral': grade.oral,
          'tasks_attendance': grade.tasksAttendance,
          'final_exam': grade.finalExam,
          'bonus': grade.bonus,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', grade.id);
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
