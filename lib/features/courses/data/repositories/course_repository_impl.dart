import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_data_source.dart';
import '../../../../core/error/failures.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<CourseEntity>>> getAllCourses() async {
    try {
      final courses = await remoteDataSource.getAllCourses();
      return Success(courses);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CourseEntity>>> getEnrolledCourses(String userId) async {
    try {
      final courses = await remoteDataSource.getEnrolledCourses(userId);
      return Success(courses);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CourseEntity>>> getAssignedCourses(String userId) async {
    try {
      final courses = await remoteDataSource.getAssignedCourses(userId);
      return Success(courses);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CourseEntity>> getCourseDetails(String courseId) async {
    try {
      final course = await remoteDataSource.getCourseDetails(courseId);
      return Success(course);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }
}
