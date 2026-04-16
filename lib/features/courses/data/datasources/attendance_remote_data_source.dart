import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_model.dart';
import '../../../../core/error/failures.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<Map<String, dynamic>>> getEnrolledStudentsWithAttendance(String courseId, String lectureId);
  Future<void> toggleAttendance(String courseId, String lectureId, String studentId, bool isPresent);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final SupabaseClient supabaseClient;

  AttendanceRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getEnrolledStudentsWithAttendance(String courseId, String lectureId) async {
    try {
      // Fetch enrolled students
      final enrollments = await supabaseClient
          .from('enrollments')
          .select('user_id, status, users!user_id(id, full_name, university_id)')
          .eq('course_id', courseId)
          .eq('status', 'active');

      // Fetch attendance for this specific lecture
      final attendanceResponse = await supabaseClient
          .from('attendance')
          .select()
          .eq('lecture_id', lectureId);
          
      final Map<String, AttendanceModel> attendanceMap = {};
      for (var row in attendanceResponse as List) {
        final att = AttendanceModel.fromJson(row);
        attendanceMap[att.studentId] = att;
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
          'attendance': attendanceMap[studentId] ?? AttendanceModel(
            id: '', 
            courseId: courseId, 
            lectureId: lectureId,
            studentId: studentId, 
            createdAt: '',
          ),
        });
      }

      return result;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> toggleAttendance(String courseId, String lectureId, String studentId, bool isPresent) async {
    try {
      // Using upsert based on unique constraint (lecture_id, student_id)
      await supabaseClient.from('attendance').upsert({
        'course_id': courseId,
        'lecture_id': lectureId,
        'student_id': studentId,
        'is_present': isPresent,
      }, onConflict: 'lecture_id,student_id');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
