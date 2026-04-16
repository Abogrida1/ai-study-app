import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lecture_model.dart';
import '../../../../core/error/failures.dart';

abstract class LectureRemoteDataSource {
  Future<List<LectureModel>> getLectures(String courseId);
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
          .order('order');
          
      return (response as List).map((e) => LectureModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
