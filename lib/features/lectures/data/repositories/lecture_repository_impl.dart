import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../domain/repositories/lecture_repository.dart';
import '../datasources/lecture_remote_data_source.dart';
import '../../../../core/error/failures.dart';

class LectureRepositoryImpl implements LectureRepository {
  final LectureRemoteDataSource remoteDataSource;

  LectureRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<LectureEntity>>> getCourseLectures(String courseId) async {
    try {
      final lectures = await remoteDataSource.getLectures(courseId);
      return Success(lectures);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<LectureEntity>> createLecture(Map<String, dynamic> data) async {
      // Stub for brevity, could implement if needed
      return const Error(ServerFailure("Not implemented yet in this refactor pass"));
  }
}
