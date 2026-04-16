import '../../../../core/usecases/usecase.dart';
import '../entities/course_entity.dart';

abstract class CourseRepository {
  Future<Result<List<CourseEntity>>> getAllCourses();
  Future<Result<List<CourseEntity>>> getEnrolledCourses(String userId);
  Future<Result<List<CourseEntity>>> getAssignedCourses(String userId);
  Future<Result<CourseEntity>> getCourseDetails(String courseId);
}
