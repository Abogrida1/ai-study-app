import '../../domain/entities/lecture_entity.dart';

class LectureModel extends LectureEntity {
  const LectureModel({
    required super.id,
    required super.title,
    required super.titleAr,
    super.description,
    super.videoUrl,
    super.pdfUrl,
    required super.order,
    super.durationMinutes,
    required super.isPublished,
    required super.createdAt,
    required super.creatorName,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['title_ar'] ?? '',
      description: json['description'],
      videoUrl: json['video_url'],
      pdfUrl: json['pdf_url'],
      order: json['order'] ?? 0,
      durationMinutes: json['duration_minutes'],
      isPublished: json['is_published'] ?? false,
      createdAt: json['created_at'] ?? '',
      creatorName: json['creator']?['full_name'] ?? 'Unknown',
    );
  }
}
