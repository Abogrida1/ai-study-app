class AttendanceModel {
  final String id;
  final String courseId;
  final String lectureId;
  final String studentId;
  final String? studentName;
  final bool isPresent;
  final String createdAt;

  AttendanceModel({
    required this.id,
    required this.courseId,
    required this.lectureId,
    required this.studentId,
    this.studentName,
    this.isPresent = false,
    required this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      lectureId: json['lecture_id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student']?['full_name'] as String?,
      isPresent: json['is_present'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'lecture_id': lectureId,
      'student_id': studentId,
      'is_present': isPresent,
    };
  }
}
