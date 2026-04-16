import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../datasources/exam_remote_data_source.dart';
import '../../../../core/error/failures.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource remoteDataSource;

  ExamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<ExamEntity>>> getCourseExams(String courseId) async {
    try {
      final exams = await remoteDataSource.getExams(courseId);
      return Success(exams);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ExamEntity>> getExamDetails(String examId) async {
    try {
      final exam = await remoteDataSource.getExamDetails(examId);
      return Success(exam);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }
}
