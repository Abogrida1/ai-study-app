class GradeModel {
  final String id;
  final String courseId;
  final String studentId;
  final String? studentName;
  final double midterm;
  final double practical;
  final double oral;
  final double tasksAttendance;
  final double finalExam;
  final double bonus;

  GradeModel({
    required this.id,
    required this.courseId,
    required this.studentId,
    this.studentName,
    this.midterm = 0,
    this.practical = 0,
    this.oral = 0,
    this.tasksAttendance = 0,
    this.finalExam = 0,
    this.bonus = 0,
  });

  double get total => midterm + practical + oral + tasksAttendance + finalExam + bonus;

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student']?['full_name'] as String?,
      midterm: (json['midterm'] as num?)?.toDouble() ?? 0,
      practical: (json['practical'] as num?)?.toDouble() ?? 0,
      oral: (json['oral'] as num?)?.toDouble() ?? 0,
      tasksAttendance: (json['tasks_attendance'] as num?)?.toDouble() ?? 0,
      finalExam: (json['final_exam'] as num?)?.toDouble() ?? 0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'student_id': studentId,
      'midterm': midterm,
      'practical': practical,
      'oral': oral,
      'tasks_attendance': tasksAttendance,
      'final_exam': finalExam,
      'bonus': bonus,
    };
  }
}
