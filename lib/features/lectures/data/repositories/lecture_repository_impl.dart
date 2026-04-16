import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../domain/repositories/lecture_repository.dart';
import '../datasources/lecture_remote_data_source.dart';
import '../../../../core/error/failures.dart';
import '../models/lecture_model.dart';

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
  Future<Result<void>> generateWeeksPlan(String courseId) async {
    try {
      await remoteDataSource.generateWeeksPlan(courseId);
      return const Success(null);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateLecture(LectureEntity lecture) async {
    try {
      await remoteDataSource.updateLecture(lecture as LectureModel);
      return const Success(null);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addSingleWeek(String courseId, int weekOrder) async {
    try {
      await remoteDataSource.addSingleWeek(courseId, weekOrder);
      return const Success(null);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteLecture(String lectureId) async {
    try {
      await remoteDataSource.deleteLecture(lectureId);
      return const Success(null);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> uploadFile(String bucket, String path, dynamic file) async {
    try {
      final url = await remoteDataSource.uploadFile(bucket, path, file);
      return Success(url);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }
}
