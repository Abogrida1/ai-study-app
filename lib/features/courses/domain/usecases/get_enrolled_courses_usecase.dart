import '../../../../core/usecases/usecase.dart';
import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetEnrolledCoursesUseCase implements UseCase<List<CourseEntity>, String> {
  final CourseRepository repository;

  GetEnrolledCoursesUseCase(this.repository);

  @override
  Future<Result<List<CourseEntity>>> call(String userId) async {
    return await repository.getEnrolledCourses(userId);
  }
}
