import 'package:equatable/equatable.dart';

class LectureEntity extends Equatable {
  final String id;
  final String title;
  final String titleAr;
  final String? description;
  final String? videoUrl;
  final String? pdfUrl;
  final int order;
  final int? durationMinutes;
  final bool isPublished;
  final String createdAt;
  final String creatorName;

  const LectureEntity({
    required this.id,
    required this.title,
    required this.titleAr,
    this.description,
    this.videoUrl,
    this.pdfUrl,
    required this.order,
    this.durationMinutes,
    required this.isPublished,
    required this.createdAt,
    required this.creatorName,
  });

  @override
  List<Object?> get props => [id, title, titleAr, description, videoUrl, pdfUrl, order, durationMinutes, isPublished, createdAt, creatorName];
}
