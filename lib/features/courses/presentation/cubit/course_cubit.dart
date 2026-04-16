import 'package:flutter_bloc/flutter_bloc.dart';
import 'course_state.dart';
import '../../domain/usecases/get_enrolled_courses_usecase.dart';
import '../../domain/usecases/get_assigned_courses_usecase.dart';
import '../../domain/entities/course_entity.dart';
import '../../../../core/usecases/usecase.dart';

class CourseCubit extends Cubit<CourseState> {
  final GetEnrolledCoursesUseCase getEnrolledCoursesUseCase;
  final GetAssignedCoursesUseCase getAssignedCoursesUseCase;

  CourseCubit({
    required this.getEnrolledCoursesUseCase,
    required this.getAssignedCoursesUseCase,
  }) : super(CourseInitial());

  Future<void> fetchEnrolledCourses(String userId) async {
    emit(CourseLoading());
    final result = await getEnrolledCoursesUseCase(userId);

    if (result is Success<List<CourseEntity>>) {
      emit(EnrolledCoursesLoaded(result.data));
    } else if (result is Error<List<CourseEntity>>) {
      emit(CourseError(result.failure.message));
    }
  }

  Future<void> fetchAssignedCourses(String userId) async {
    emit(CourseLoading());
    final result = await getAssignedCoursesUseCase(userId);

    if (result is Success<List<CourseEntity>>) {
      emit(EnrolledCoursesLoaded(result.data)); // Using the same state for UI simplicity, as the UI expects this state
    } else if (result is Error<List<CourseEntity>>) {
      emit(CourseError(result.failure.message));
    }
  }
}
