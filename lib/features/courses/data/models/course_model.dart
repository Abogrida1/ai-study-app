import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.code,
    required super.name,
    required super.nameAr,
    super.description,
    super.creditHours,
    super.semester,
    super.thumbnailUrl,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      description: json['description'],
      creditHours: json['credit_hours'],
      semester: json['semester'],
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'credit_hours': creditHours,
      'semester': semester,
      'thumbnail_url': thumbnailUrl,
    };
  }
}
