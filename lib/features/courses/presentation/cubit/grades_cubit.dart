import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/grades_remote_data_source.dart';
import '../../data/models/grade_model.dart';
import 'package:equatable/equatable.dart';

// States
abstract class GradesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GradesInitial extends GradesState {}

class GradesLoading extends GradesState {}

class GradesLoaded extends GradesState {
  final List<Map<String, dynamic>> studentsGrades;
  GradesLoaded(this.studentsGrades);

  @override
  List<Object?> get props => [studentsGrades];
}

class GradesError extends GradesState {
  final String message;
  GradesError(this.message);

  @override
  List<Object?> get props => [message];
}

class GradesUpdateSuccess extends GradesState {}

// Cubit
class GradesCubit extends Cubit<GradesState> {
  final GradesRemoteDataSource dataSource;

  GradesCubit({required this.dataSource}) : super(GradesInitial());

  Future<void> getEnrolledStudentsWithGrades(String courseId) async {
    if (isClosed) return;
    emit(GradesLoading());
    try {
      final data = await dataSource.getEnrolledStudentsWithGrades(courseId);
      if (!isClosed) emit(GradesLoaded(data));
    } catch (e) {
      if (!isClosed) emit(GradesError(e.toString()));
    }
  }

  Future<void> updateGrade(String courseId, GradeModel grade) async {
    try {
      await dataSource.updateGrade(grade);
      // Refresh the list silently or emit success then reload
      if (!isClosed) await getEnrolledStudentsWithGrades(courseId);
    } catch (e) {
      if (!isClosed) emit(GradesError(e.toString()));
    }
  }
}
