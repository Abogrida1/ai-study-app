import 'package:flutter_bloc/flutter_bloc.dart';
import 'course_state.dart';
import '../../domain/usecases/get_enrolled_courses_usecase.dart';
import '../../domain/entities/course_entity.dart';
import '../../../../core/usecases/usecase.dart';

class CourseCubit extends Cubit<CourseState> {
  final GetEnrolledCoursesUseCase getEnrolledCoursesUseCase;

  CourseCubit({required this.getEnrolledCoursesUseCase}) : super(CourseInitial());

  Future<void> fetchEnrolledCourses(String userId) async {
    emit(CourseLoading());
    final result = await getEnrolledCoursesUseCase(userId);

    if (result is Success<List<CourseEntity>>) {
      emit(EnrolledCoursesLoaded(result.data));
    } else if (result is Error<List<CourseEntity>>) {
      emit(CourseError(result.failure.message));
    }
  }
}
