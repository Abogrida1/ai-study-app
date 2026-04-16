import '../../domain/entities/lecture_entity.dart';

class LectureModel extends LectureEntity {
  const LectureModel({
    required super.id,
    required super.title,
    required super.titleAr,
    super.description,
    super.thumbnailUrl,
    required super.materials,
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
      thumbnailUrl: json['thumbnail_url'],
      materials: (json['materials'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      order: json['order'] ?? 0,
      durationMinutes: json['duration_minutes'],
      isPublished: json['is_published'] ?? false,
      createdAt: json['created_at'] ?? '',
      creatorName: json['creator']?['full_name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title_ar': titleAr,
      'thumbnail_url': thumbnailUrl,
      'materials': materials,
      'is_published': isPublished,
    };
  }
}
