import '../../../../core/usecases/usecase.dart';
import '../entities/lecture_entity.dart';

abstract class LectureRepository {
  Future<Result<List<LectureEntity>>> getCourseLectures(String courseId);
  Future<Result<LectureEntity>> createLecture(Map<String, dynamic> lectureData);
}
