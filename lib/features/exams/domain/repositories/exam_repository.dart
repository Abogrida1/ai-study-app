import '../../../../core/usecases/usecase.dart';
import '../entities/exam_entity.dart';

abstract class ExamRepository {
  Future<Result<List<ExamEntity>>> getCourseExams(String courseId);
  Future<Result<ExamEntity>> getExamDetails(String examId);
}
