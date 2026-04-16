import '../../../../core/usecases/usecase.dart';
import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetAssignedCoursesUseCase implements UseCase<List<CourseEntity>, String> {
  final CourseRepository repository;

  GetAssignedCoursesUseCase(this.repository);

  @override
  Future<Result<List<CourseEntity>>> call(String params) async {
    return await repository.getAssignedCourses(params);
  }
}
