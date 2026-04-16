import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/lecture_repository.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../data/models/lecture_model.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

// States
abstract class LectureState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LectureInitial extends LectureState {}

class LectureLoading extends LectureState {}

class LectureLoaded extends LectureState {
  final List<LectureModel> lectures;
  LectureLoaded(this.lectures);

  @override
  List<Object?> get props => [lectures];
}

class LectureError extends LectureState {
  final String message;
  LectureError(this.message);

  @override
  List<Object?> get props => [message];
}

class LectureCubit extends Cubit<LectureState> {
  final LectureRepository repository;

  LectureCubit({required this.repository}) : super(LectureInitial());

  Future<void> getLectures(String courseId) async {
    if (isClosed) return;
    emit(LectureLoading());
    final result = await repository.getCourseLectures(courseId);
    
    if (result is Success<List<LectureEntity>>) {
      final lectures = result.data;
      if (!isClosed) emit(LectureLoaded(lectures as List<LectureModel>));
    } else if (result is Error<List<LectureEntity>>) {
      final failure = result.failure;
      if (!isClosed) emit(LectureError(failure.message));
    }
  }

  Future<void> generateInitialWeeks(String courseId) async {
    if (isClosed) return;
    emit(LectureLoading());
    final result = await repository.generateWeeksPlan(courseId);
    if (result is Success<void>) {
      await getLectures(courseId);
    } else if (result is Error<void>) {
      final failure = result.failure;
      if (!isClosed) emit(LectureError(failure.message));
    }
  }

  Future<void> updateWeekMaterial(String courseId, LectureModel lecture) async {
    if (isClosed) return;
    final result = await repository.updateLecture(lecture);
    if (result is Success<void>) {
      await getLectures(courseId);
    } else if (result is Error<void>) {
      final failure = result.failure;
      if (!isClosed) emit(LectureError(failure.message));
    }
  }

  Future<void> addSingleWeek(String courseId, int weekOrder) async {
    if (isClosed) return;
    emit(LectureLoading());
    final result = await repository.addSingleWeek(courseId, weekOrder);
    if (result is Success<void>) {
      await getLectures(courseId);
    } else if (result is Error<void>) {
      final failure = result.failure;
      if (!isClosed) emit(LectureError(failure.message));
    }
  }

  Future<void> deleteLecture(String courseId, String lectureId) async {
    if (isClosed) return;
    final result = await repository.deleteLecture(lectureId);
    if (result is Success<void>) {
      await getLectures(courseId);
    } else if (result is Error<void>) {
      final failure = result.failure;
      if (!isClosed) emit(LectureError(failure.message));
    }
  }

  Future<String?> uploadFile(String bucket, String path, dynamic file) async {
    final result = await repository.uploadFile(bucket, path, file);
    if (result is Success<String>) {
      return result.data;
    } else if (result is Error<String>) {
      if (!isClosed) emit(LectureError(result.failure.message));
      return null;
    }
    return null;
  }
}
