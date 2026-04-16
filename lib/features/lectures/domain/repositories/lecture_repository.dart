import '../../../../core/usecases/usecase.dart';
import '../entities/lecture_entity.dart';

abstract class LectureRepository {
  Future<Result<List<LectureEntity>>> getCourseLectures(String courseId);
  Future<Result<void>> generateWeeksPlan(String courseId);
  Future<Result<void>> updateLecture(LectureEntity lecture);
  Future<Result<void>> addSingleWeek(String courseId, int weekOrder);
  Future<Result<void>> deleteLecture(String lectureId);
  Future<Result<String>> uploadFile(String bucket, String path, dynamic file);
}
