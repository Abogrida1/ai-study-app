import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// فئة لإدارة المواد المثبتة محلياً
class PinnedCoursesStorage {
  static const String _pinnedCoursesKey = 'pinned_courses';
  static final StreamController<List<String>> _pinnedCoursesStreamController = StreamController<List<String>>.broadcast();
  
  /// Stream للاستماع لتغييرات المواد المثبتة
  static Stream<List<String>> get pinnedCoursesStream => _pinnedCoursesStreamController.stream;
  
  /// حفظ المواد المثبتة وإخطار المستمعين
  static Future<void> addPinnedCourse(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedCourses = prefs.getStringList(_pinnedCoursesKey) ?? [];
    
    if (!pinnedCourses.contains(courseId)) {
      pinnedCourses.add(courseId);
      await prefs.setStringList(_pinnedCoursesKey, pinnedCourses);
      _pinnedCoursesStreamController.add(pinnedCourses);
    }
  }
  
  /// إزالة مادة من المثبتة وإخطار المستمعين
  static Future<void> removePinnedCourse(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedCourses = prefs.getStringList(_pinnedCoursesKey) ?? [];
    
    pinnedCourses.remove(courseId);
    await prefs.setStringList(_pinnedCoursesKey, pinnedCourses);
    _pinnedCoursesStreamController.add(pinnedCourses);
  }
  
  /// الحصول على جميع المواد المثبتة
  static Future<List<String>> getPinnedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pinnedCoursesKey) ?? [];
  }
  
  /// التحقق من كون المادة مثبتة
  static Future<bool> isPinned(String courseId) async {
    final pinnedCourses = await getPinnedCourses();
    return pinnedCourses.contains(courseId);
  }
  
  /// حذف جميع المواد المثبتة وإخطار المستمعين
  static Future<void> clearAllPinned() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinnedCoursesKey);
    _pinnedCoursesStreamController.add([]);
  }
}
