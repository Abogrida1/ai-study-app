import 'package:equatable/equatable.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class EnrolledCoursesLoaded extends CourseState {
  final List<dynamic> courses; // Using dynamic for now to match the existing UI expectations, but should ideally be List<CourseEntity>
  const EnrolledCoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseError extends CourseState {
  final String message;
  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}
