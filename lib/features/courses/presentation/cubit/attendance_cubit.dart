import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import 'package:equatable/equatable.dart';

// States
abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Map<String, dynamic>> studentsAttendance;
  AttendanceLoaded(this.studentsAttendance);

  @override
  List<Object?> get props => [studentsAttendance];
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRemoteDataSource dataSource;

  AttendanceCubit({required this.dataSource}) : super(AttendanceInitial());

  Future<void> getEnrolledStudentsWithAttendance(String courseId, String lectureId) async {
    if (isClosed) return;
    emit(AttendanceLoading());
    try {
      final data = await dataSource.getEnrolledStudentsWithAttendance(courseId, lectureId);
      if (!isClosed) emit(AttendanceLoaded(data));
    } catch (e) {
      if (!isClosed) emit(AttendanceError(e.toString()));
    }
  }

  Future<void> toggleAttendance(String courseId, String lectureId, String studentId, bool isPresent) async {
    try {
      await dataSource.toggleAttendance(courseId, lectureId, studentId, isPresent);
      // Reload current lecture attendance
      if (!isClosed) await getEnrolledStudentsWithAttendance(courseId, lectureId);
    } catch (e) {
      if (!isClosed) emit(AttendanceError(e.toString()));
    }
  }
}
