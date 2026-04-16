import 'package:flutter/foundation.dart';
import '../core/supabase_client.dart';

/// Service for lecture-related operations.
class LectureService {
  static final LectureService _instance = LectureService._internal();
  factory LectureService() => _instance;
  LectureService._internal();

  /// Get lectures for a specific course
  Future<List<Map<String, dynamic>>> getCourseLectures(String courseId) async {
    try {
      final response = await supabase
          .from('lectures')
          .select('''
            id,
            title,
            title_ar,
            description,
            video_url,
            pdf_url,
            "order",
            duration_minutes,
            is_published,
            created_by,
            created_at,
            creator:users!created_by (
              full_name,
              avatar_url
            )
          ''')
          .eq('course_id', courseId)
          .order('"order"', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching lectures: $e');
      return [];
    }
  }

  /// Create a new lecture (for doctors)
  Future<Map<String, dynamic>?> createLecture({
    required String courseId,
    required String title,
    String? titleAr,
    String? description,
    String? videoUrl,
    String? pdfUrl,
    int order = 0,
    int? durationMinutes,
    required String createdBy,
  }) async {
    try {
      // Convert Google Drive link to embed URL if needed
      final embedUrl = videoUrl != null ? _convertToEmbedUrl(videoUrl) : null;

      final response = await supabase
          .from('lectures')
          .insert({
            'course_id': courseId,
            'title': title,
            'title_ar': titleAr,
            'description': description,
            'video_url': embedUrl,
            'pdf_url': pdfUrl,
            'order': order,
            'duration_minutes': durationMinutes,
            'is_published': false,
            'created_by': createdBy,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      debugPrint('Error creating lecture: $e');
      return null;
    }
  }

  /// Update an existing lecture
  Future<bool> updateLecture(String lectureId, Map<String, dynamic> updates) async {
    try {
      // Convert video URL if present
      if (updates.containsKey('video_url') && updates['video_url'] != null) {
        updates['video_url'] = _convertToEmbedUrl(updates['video_url']);
      }

      await supabase
          .from('lectures')
          .update(updates)
          .eq('id', lectureId);

      return true;
    } catch (e) {
      debugPrint('Error updating lecture: $e');
      return false;
    }
  }

  /// Delete a lecture
  Future<bool> deleteLecture(String lectureId) async {
    try {
      await supabase
          .from('lectures')
          .delete()
          .eq('id', lectureId);

      return true;
    } catch (e) {
      debugPrint('Error deleting lecture: $e');
      return false;
    }
  }

  /// Toggle publish status
  Future<bool> togglePublish(String lectureId, bool isPublished) async {
    return updateLecture(lectureId, {'is_published': isPublished});
  }

  /// Convert Google Drive link to embeddable URL
  /// Handles formats:
  /// - https://drive.google.com/file/d/FILE_ID/view
  /// - https://drive.google.com/open?id=FILE_ID
  /// - Direct FILE_ID
  String _convertToEmbedUrl(String url) {
    String? fileId;

    // Pattern 1: /file/d/FILE_ID/
    final regex1 = RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)');
    final match1 = regex1.firstMatch(url);
    if (match1 != null) {
      fileId = match1.group(1);
    }

    // Pattern 2: ?id=FILE_ID
    if (fileId == null) {
      final regex2 = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)');
      final match2 = regex2.firstMatch(url);
      if (match2 != null) {
        fileId = match2.group(1);
      }
    }

    // Pattern 3: Already an embed or just an ID
    if (fileId == null) {
      if (url.contains('drive.google.com/file/d/')) {
        return url; // Already formatted
      }
      // Assume it's a raw file ID
      if (RegExp(r'^[a-zA-Z0-9_-]{20,}$').hasMatch(url)) {
        fileId = url;
      }
    }

    if (fileId != null) {
      return 'https://drive.google.com/file/d/$fileId/preview';
    }

    return url; // Return as-is if can't parse
  }
}
