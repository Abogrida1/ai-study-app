import 'package:equatable/equatable.dart';

class ExamEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final double totalMarks;
  final int durationMinutes;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isPublished;

  const ExamEntity({
    required this.id,
    required this.title,
    this.description,
    required this.totalMarks,
    required this.durationMinutes,
    this.startTime,
    this.endTime,
    required this.isPublished,
  });

  @override
  List<Object?> get props => [id, title, description, totalMarks, durationMinutes, startTime, endTime, isPublished];
}
