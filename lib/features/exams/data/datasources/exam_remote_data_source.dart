import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_model.dart';
import '../../../../core/error/failures.dart';

abstract class ExamRemoteDataSource {
  Future<List<ExamModel>> getExams(String courseId);
  Future<ExamModel> getExamDetails(String examId);
}

class ExamRemoteDataSourceImpl implements ExamRemoteDataSource {
  final SupabaseClient supabaseClient;

  ExamRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ExamModel>> getExams(String courseId) async {
    try {
      final response = await supabaseClient
          .from('exams')
          .select()
          .eq('course_id', courseId);
          
      return (response as List).map((e) => ExamModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ExamModel> getExamDetails(String examId) async {
    try {
      final response = await supabaseClient
          .from('exams')
          .select()
          .eq('id', examId)
          .single();
          
      return ExamModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
