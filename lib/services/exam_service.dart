import 'package:flutter/foundation.dart';
import '../core/supabase_client.dart';

/// Service for exam-related operations.
class ExamService {
  static final ExamService _instance = ExamService._internal();
  factory ExamService() => _instance;
  ExamService._internal();

  /// Get exams for a specific course (student view — published only)
  Future<List<Map<String, dynamic>>> getCourseExams(String courseId, {bool publishedOnly = true}) async {
    try {
      var query = supabase
          .from('exams')
          .select('''
            id,
            title,
            description,
            total_marks,
            duration_minutes,
            start_time,
            end_time,
            is_published,
            created_at,
            course:courses (
              id,
              name,
              name_ar,
              code
            )
          ''')
          .eq('course_id', courseId);

      if (publishedOnly) {
        query = query.eq('is_published', true);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching exams: $e');
      return [];
    }
  }

  /// Get all upcoming exams for a student (across all enrolled courses)
  Future<List<Map<String, dynamic>>> getStudentUpcomingExams(String userId) async {
    try {
      // First get enrolled course IDs
      final enrollments = await supabase
          .from('enrollments')
          .select('course_id')
          .eq('user_id', userId)
          .eq('status', 'active');

      final courseIds = enrollments.map((e) => e['course_id'] as String).toList();
      if (courseIds.isEmpty) return [];

      final now = DateTime.now().toIso8601String();
      final response = await supabase
          .from('exams')
          .select('''
            id,
            title,
            description,
            total_marks,
            duration_minutes,
            start_time,
            end_time,
            course:courses (
              id,
              name,
              name_ar,
              code
            )
          ''')
          .inFilter('course_id', courseIds)
          .eq('is_published', true)
          .gte('end_time', now)
          .order('start_time', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching upcoming exams: $e');
      return [];
    }
  }

  /// Get exam details with questions and options
  Future<Map<String, dynamic>?> getExamWithQuestions(String examId) async {
    try {
      final response = await supabase
          .from('exams')
          .select('''
            *,
            exam_questions (
              id,
              question_text,
              question_type,
              marks,
              "order",
              exam_options (
                id,
                option_text,
                is_correct,
                "order"
              )
            )
          ''')
          .eq('id', examId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error fetching exam details: $e');
      return null;
    }
  }

  /// Submit an exam attempt with answers
  Future<Map<String, dynamic>?> submitAttempt({
    required String examId,
    required String userId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      // Create attempt
      final attempt = await supabase
          .from('exam_attempts')
          .insert({
            'exam_id': examId,
            'user_id': userId,
            'submitted_at': DateTime.now().toIso8601String(),
            'status': 'submitted',
          })
          .select()
          .single();

      final attemptId = attempt['id'] as String;

      // Insert answers
      final answerInserts = answers.map((a) => {
        'attempt_id': attemptId,
        'question_id': a['question_id'],
        'selected_option_id': a['selected_option_id'],
        'answer_text': a['answer_text'],
      }).toList();

      await supabase.from('exam_answers').insert(answerInserts);

      // Auto-grade MCQ and True/False
      await _autoGrade(attemptId);

      // Return updated attempt
      return await supabase
          .from('exam_attempts')
          .select()
          .eq('id', attemptId)
          .single();
    } catch (e) {
      debugPrint('Error submitting attempt: $e');
      return null;
    }
  }

  /// Auto-grade MCQ and True/False answers
  Future<void> _autoGrade(String attemptId) async {
    try {
      // Get all answers for this attempt
      final answers = await supabase
          .from('exam_answers')
          .select('''
            id,
            question_id,
            selected_option_id,
            answer_text,
            question:exam_questions (
              question_type,
              marks,
              correct_answer
            )
          ''')
          .eq('attempt_id', attemptId);

      double totalScore = 0;

      for (final answer in answers) {
        final question = answer['question'] as Map<String, dynamic>;
        final questionType = question['question_type'] as String;
        final marks = (question['marks'] as num?)?.toDouble() ?? 1;
        bool isCorrect = false;

        if (questionType == 'mcq' && answer['selected_option_id'] != null) {
          // Check if selected option is correct
          final option = await supabase
              .from('exam_options')
              .select('is_correct')
              .eq('id', answer['selected_option_id'])
              .maybeSingle();

          isCorrect = option?['is_correct'] == true;
        } else if (questionType == 'true_false') {
          isCorrect = answer['answer_text']?.toString().toLowerCase() ==
              question['correct_answer']?.toString().toLowerCase();
        }
        // Essay questions are not auto-graded

        if (questionType != 'essay') {
          await supabase.from('exam_answers').update({
            'is_correct': isCorrect,
            'marks_awarded': isCorrect ? marks : 0,
          }).eq('id', answer['id']);

          if (isCorrect) totalScore += marks;
        }
      }

      // Update attempt score
      await supabase.from('exam_attempts').update({
        'score': totalScore,
        'status': 'graded',
      }).eq('id', attemptId);
    } catch (e) {
      debugPrint('Error auto-grading: $e');
    }
  }

  /// Create exam (for doctors)
  Future<Map<String, dynamic>?> createExam({
    required String courseId,
    required String title,
    String? description,
    required double totalMarks,
    required int durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    required String createdBy,
  }) async {
    try {
      final response = await supabase
          .from('exams')
          .insert({
            'course_id': courseId,
            'title': title,
            'description': description,
            'total_marks': totalMarks,
            'duration_minutes': durationMinutes,
            'start_time': startTime?.toIso8601String(),
            'end_time': endTime?.toIso8601String(),
            'is_published': false,
            'created_by': createdBy,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      debugPrint('Error creating exam: $e');
      return null;
    }
  }

  /// Add question to an exam
  Future<Map<String, dynamic>?> addQuestion({
    required String examId,
    required String questionText,
    required String questionType,
    double marks = 1,
    int order = 0,
    String? correctAnswer,
    List<Map<String, dynamic>>? options,
  }) async {
    try {
      final question = await supabase
          .from('exam_questions')
          .insert({
            'exam_id': examId,
            'question_text': questionText,
            'question_type': questionType,
            'marks': marks,
            'order': order,
            'correct_answer': correctAnswer,
          })
          .select()
          .single();

      // Add MCQ options if provided
      if (options != null && options.isNotEmpty) {
        final optionInserts = options.asMap().entries.map((entry) => {
          'question_id': question['id'],
          'option_text': entry.value['text'],
          'is_correct': entry.value['is_correct'] ?? false,
          'order': entry.key,
        }).toList();

        await supabase.from('exam_options').insert(optionInserts);
      }

      return question;
    } catch (e) {
      debugPrint('Error adding question: $e');
      return null;
    }
  }

  /// Get student's attempt for an exam
  Future<Map<String, dynamic>?> getStudentAttempt(String examId, String userId) async {
    try {
      return await supabase
          .from('exam_attempts')
          .select('''
            *,
            exam_answers (
              id,
              question_id,
              selected_option_id,
              answer_text,
              is_correct,
              marks_awarded
            )
          ''')
          .eq('exam_id', examId)
          .eq('user_id', userId)
          .maybeSingle();
    } catch (e) {
      debugPrint('Error fetching attempt: $e');
      return null;
    }
  }
}
