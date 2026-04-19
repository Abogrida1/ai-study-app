import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String nameAr;
  final String? description;
  final int? creditHours;
  final String? semester;
  final String? thumbnailUrl;
  final String? professorName;

  const CourseEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.nameAr,
    this.description,
    this.creditHours,
    this.semester,
    this.thumbnailUrl,
    this.professorName,
  });

  @override
  List<Object?> get props => [id, code, name, nameAr, description, creditHours, semester, thumbnailUrl, professorName];
}
