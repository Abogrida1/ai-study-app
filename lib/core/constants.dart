import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors (Original)
  static const Color primary = Color(0xFF4456BA);
  static const Color primaryContainer = Color(0xFF8596FF);
  static const Color primaryDim = Color(0xFF3749AD);
  
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFEBEEF0);
  static const Color surfaceContainerLow = Color(0xFFF1F4F5);
  static const Color surfaceContainerHigh = Color(0xFFE5E9EB);
  static const Color surfaceContainerHighest = Color(0xFFDEE3E6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  
  static const Color onSurface = Color(0xFF2D3335);
  static const Color onSurfaceVariant = Color(0xFF5A6062);
  static const Color outline = Color(0xFF767C7E);
  static const Color outlineVariant = Color(0xFFADB3B5);

  // Dark Mode Colors (Extracted from Source)
  static const Color darkPrimary = Color(0xFF8596FF);
  static const Color darkPrimaryContainer = Color(0xFF3749AD);
  static const Color darkPrimaryDim = Color(0xFF3749AD);

  static const Color darkSurface = Color(0xFF0C0F10);
  static const Color darkSurfaceContainer = Color(0xFF1D2427);
  static const Color darkSurfaceContainerLow = Color(0xFF151C1E);
  static const Color darkSurfaceContainerHigh = Color(0xFF282F32);
  static const Color darkSurfaceContainerHighest = Color(0xFF333A3D);
  static const Color darkSurfaceContainerLowest = Color(0xFF07090A);

  static const Color darkOnSurface = Color(0xFFF8F9FA);
  static const Color darkOnSurfaceVariant = Color(0xFFA1A7AA);
  static const Color darkOutline = Color(0xFF8B9193);
  static const Color darkOutlineVariant = Color(0xFF40484B);

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [darkPrimary, Color(0xFF4555A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadius {
  static const double lg = 32.0; // 2rem
  static const double xl = 48.0; // 3rem
}

class AppShadows {
  static const List<BoxShadow> editorial = [
    BoxShadow(
      color: Color.fromRGBO(45, 51, 53, 0.06),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];
}

class Lecture {
  final String id;
  final String title;
  final String instructor;
  final int lessons;
  final int progress;
  final String level;
  final String thumbnail;
  final String category;
  final String? videoUrl;
  final String? pdfUrl;
  final String? aiSummary;

  const Lecture({
    required this.id,
    required this.title,
    required this.instructor,
    required this.lessons,
    required this.progress,
    required this.level,
    required this.thumbnail,
    required this.category,
    this.videoUrl,
    this.pdfUrl,
    this.aiSummary,
  });
}

class Question {
  final String id;
  final String student;
  final String studentInitials;
  final String text;
  final String time;
  final Color color;

  const Question({
    required this.id,
    required this.student,
    required this.studentInitials,
    required this.text,
    required this.time,
    required this.color,
  });
}

class AppData {
  static const String defaultSubjectImage = 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&q=80&w=800';
  static const String defaultLectureImage = 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&q=80&w=800';

  static const List<Lecture> featuredLectures = [
    Lecture(
      id: '1',
      title: 'Introduction to Quantum Mechanics',
      instructor: 'Dr. Alistair Vance',
      lessons: 12,
      progress: 75,
      level: 'Advanced',
      thumbnail: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&q=80&w=800',
      category: 'Science',
    ),
    Lecture(
      id: '2',
      title: 'The Beauty of Pure Mathematics',
      instructor: 'Prof. Sarah Jenkins',
      lessons: 8,
      progress: 25,
      level: 'Core',
      thumbnail: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&q=80&w=800',
      category: 'Math',
    ),
    Lecture(
      id: '3',
      title: 'Renaissance Art Mastery',
      instructor: 'Leo DiVinci',
      lessons: 15,
      progress: 0,
      level: 'Elective',
      thumbnail: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&q=80&w=800',
      category: 'Arts',
    ),
  ];

  static const List<Lecture> recentLectures = [
    Lecture(
      id: '4',
      title: 'Big Data & Cloud Systems',
      instructor: 'Module 4: Distributed Computing',
      lessons: 10,
      progress: 40,
      level: 'Core',
      thumbnail: 'https://images.unsplash.com/photo-1551288049-bbda48658a7d?auto=format&fit=crop&q=80&w=400',
      category: 'Science',
    ),
    Lecture(
      id: '5',
      title: 'Cybersecurity Fundamentals',
      instructor: 'Module 1: Threat Landscape',
      lessons: 6,
      progress: 15,
      level: 'Core',
      thumbnail: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&q=80&w=400',
      category: 'Science',
    ),
    Lecture(
      id: '6',
      title: 'Global Environmental Change',
      instructor: 'Module 7: Arctic Melting',
      lessons: 12,
      progress: 60,
      level: 'Core',
      thumbnail: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&q=80&w=400',
      category: 'Science',
    ),
  ];

  static const List<Question> unansweredQuestions = [
    Question(
      id: 'q1',
      student: 'Sarah Chen',
      studentInitials: 'SC',
      text: 'How does the Machiavellian philosophy apply to the modern corporate governance models we discussed?',
      time: '2m ago',
      color: Color(0xFFE0E7FF),
    ),
    Question(
      id: 'q2',
      student: 'Marcus King',
      studentInitials: 'MK',
      text: 'Can you recommend additional readings for the last module on Neoclassicism?',
      time: '15m ago',
      color: Color(0xFFF3E8FF),
    ),
  ];
}

class SupabaseConfig {
  static const String url = 'https://hrnzudvlazwlqdcbtgjn.supabase.co';
  static const String anonKey = 'sb_publishable_ajFGoPlO_g2p2UASEBslNg_wzi4pwuU';
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
