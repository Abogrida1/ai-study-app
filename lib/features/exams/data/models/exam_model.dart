import '../../domain/entities/exam_entity.dart';

class ExamModel extends ExamEntity {
  const ExamModel({
    required super.id,
    required super.title,
    super.description,
    required super.totalMarks,
    required super.durationMinutes,
    super.startTime,
    super.endTime,
    required super.isPublished,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      totalMarks: (json['total_marks'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['duration_minutes'] ?? 0,
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      isPublished: json['is_published'] ?? false,
    );
  }
}
