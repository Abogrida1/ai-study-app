import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lecture_model.dart';
import '../../../../core/error/failures.dart';

abstract class LectureRemoteDataSource {
  Future<List<LectureModel>> getLectures(String courseId);
  Future<void> generateWeeksPlan(String courseId);
  Future<void> updateLecture(LectureModel lecture);
  Future<void> addSingleWeek(String courseId, int weekOrder);
  Future<void> deleteLecture(String lectureId);
  Future<String> uploadFile(String bucket, String path, dynamic file);
}

class LectureRemoteDataSourceImpl implements LectureRemoteDataSource {
  final SupabaseClient supabaseClient;

  LectureRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<LectureModel>> getLectures(String courseId) async {
    try {
      final response = await supabaseClient
          .from('lectures')
          .select('*, creator:users!created_by (full_name)')
          .eq('course_id', courseId)
          .order('order', ascending: true);
          
      return (response as List).map((e) => LectureModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> generateWeeksPlan(String courseId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const ServerFailure('User not authenticated');

      final List<Map<String, dynamic>> weeks = [];
      // 6 weeks
      for (int i = 1; i <= 6; i++) {
        weeks.add({
          'course_id': courseId,
          'title': 'Week $i',
          'title_ar': 'الأسبوع $i',
          'order': i,
          'is_published': true,
          'created_by': userId,
          'materials': [],
        });
      }
      // General Material
      weeks.add({
        'course_id': courseId,
        'title': 'General Course Material',
        'title_ar': 'ماتيريال المادة',
        'order': 999,
        'is_published': true,
        'created_by': userId,
        'materials': [],
      });

      await supabaseClient.from('lectures').insert(weeks);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateLecture(LectureModel lecture) async {
    try {
      await supabaseClient.from('lectures').update({
        'title_ar': lecture.titleAr,
        'thumbnail_url': lecture.thumbnailUrl,
        'materials': lecture.materials,
      }).eq('id', lecture.id);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> addSingleWeek(String courseId, int weekOrder) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const ServerFailure('User not authenticated');

      await supabaseClient.from('lectures').insert({
        'course_id': courseId,
        'title': 'Week $weekOrder',
        'title_ar': 'الأسبوع $weekOrder',
        'order': weekOrder,
        'is_published': true,
        'created_by': userId,
        'materials': [],
      });
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteLecture(String lectureId) async {
    try {
      await supabaseClient.from('lectures').delete().eq('id', lectureId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> uploadFile(String bucket, String path, dynamic file) async {
    try {
      await supabaseClient.storage.from(bucket).upload(path, file);
      return supabaseClient.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
