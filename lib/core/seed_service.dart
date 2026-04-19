import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class SeedService {
  static final SeedService _instance = SeedService._internal();
  factory SeedService() => _instance;
  SeedService._internal();

  final List<Map<String, String>> _demoAccounts = [
    {
      'email': 'student@demo.com',
      'password': 'password123',
      'role': 'student',
      'u_id': '2024001',
      'name': 'Demo Student',
    },
    {
      'email': 'doctor@demo.com',
      'password': 'password123',
      'role': 'doctor',
      'u_id': 'prof_001',
      'name': 'Prof. Dr. Demo',
    },
    {
      'email': 'assistant@demo.com',
      'password': 'password123',
      'role': 'ta',
      'u_id': 'ta_001',
      'name': 'Demo Assistant',
    },
  ];

  /// Seed demo accounts and create user profiles
  Future<void> seedDemoAccounts() async {
    final createdUserIds = <String, String>{}; // email -> user_id

    for (var account in _demoAccounts) {
      try {
        debugPrint('Attempting to create account: ${account['email']}');
        
        // 1. Sign up the user
        final AuthResponse res = await supabase.auth.signUp(
          email: account['email']!,
          password: account['password']!,
          data: {
             'full_name': account['name'],
             'role': account['role'],
             'university_id': account['u_id'],
          }
        );

        if (res.user != null) {
          createdUserIds[account['email']!] = res.user!.id;
          debugPrint('Account created successfully: ${account['email']}');
        }
      } catch (e) {
        if (e.toString().contains('User already registered')) {
          debugPrint('User ${account['email']} already exists.');
        } else {
          debugPrint('Error seeding ${account['email']}: $e');
        }
      }
    }

    // After creating accounts, seed enrollments and assignments
    // This requires logging in as each user, so we'll do it separately
    debugPrint('Demo accounts seeding complete. ${createdUserIds.length} new accounts created.');
    debugPrint('Note: Enrollments and assignments will be created when database seed data is applied via SQL.');
  }

  /// Seed enrollment and assignment data for demo accounts
  /// This should be called after the SQL seed has been run
  /// and requires service_role access (run from admin or Edge Function)
  Future<void> seedEnrollmentsForDemo() async {
    try {
      // These operations require the auto-created user IDs from the trigger
      // For demo purposes, we'll fetch user IDs by email
      
      // Get student ID
      final studentQuery = await supabase
          .from('users')
          .select('id')
          .eq('university_id', '2024001')
          .maybeSingle();
      
      // Get doctor ID
      final doctorQuery = await supabase
          .from('users')
          .select('id')
          .eq('university_id', 'prof_001')
          .maybeSingle();

      // Get TA ID
      final taQuery = await supabase
          .from('users')
          .select('id')
          .eq('university_id', 'ta_001')
          .maybeSingle();

      if (studentQuery == null || doctorQuery == null || taQuery == null) {
        debugPrint('Cannot seed enrollments: some demo users not found in users table.');
        debugPrint('Student: $studentQuery, Doctor: $doctorQuery, TA: $taQuery');
        return;
      }

      final studentId = studentQuery['id'] as String;
      final doctorId = doctorQuery['id'] as String;
      final taId = taQuery['id'] as String;

      // Enroll student in courses
      final courses = await supabase
          .from('courses')
          .select('id, code')
          .inFilter('code', ['CS101', 'MATH201', 'PHY101']);

      for (final course in courses) {
        try {
          await supabase.from('enrollments').upsert({
            'user_id': studentId,
            'course_id': course['id'],
            'section_id': 'c1000000-0000-0000-0000-000000000001', // Section 1
            'status': 'active',
          }, onConflict: 'user_id,course_id');
          debugPrint('Enrolled student in ${course['code']}');
        } catch (e) {
          debugPrint('Enrollment exists or error: $e');
        }
      }

      // Assign doctor to demo courses only
      for (final course in courses) {
        try {
          await supabase.from('assignments').upsert({
            'user_id': doctorId,
            'course_id': course['id'],
            'scope': 'course',
            'role': 'doctor',
          }, onConflict: 'user_id,course_id,scope,scope_id');
          debugPrint('Assigned doctor to ${course['code']}');
        } catch (e) {
          debugPrint('Assignment exists or error: $e');
        }
      }

      // Assign TA to sections
      if (courses.isNotEmpty) {
        try {
          await supabase.from('assignments').upsert({
            'user_id': taId,
            'course_id': courses[0]['id'],
            'scope': 'section',
            'scope_id': 'c1000000-0000-0000-0000-000000000001',
            'role': 'ta',
          }, onConflict: 'user_id,course_id,scope,scope_id');
          debugPrint('Assigned TA to section');
        } catch (e) {
          debugPrint('TA assignment exists or error: $e');
        }
      }

      // Create sample lectures
      if (courses.isNotEmpty) {
        final cs101Id = courses.firstWhere((c) => c['code'] == 'CS101')['id'];
        try {
          await supabase.from('lectures').upsert([
            {
              'course_id': cs101Id,
              'title': 'Introduction to Algorithms',
              'title_ar': 'مقدمة في الخوارزميات',
              'description': 'Understanding what algorithms are and why they matter',
              'order': 1,
              'duration_minutes': 45,
              'is_published': true,
              'created_by': doctorId,
            },
            {
              'course_id': cs101Id,
              'title': 'Variables and Data Types',
              'title_ar': 'المتغيرات وأنواع البيانات',
              'description': 'Learn about different data types in programming',
              'order': 2,
              'duration_minutes': 60,
              'is_published': true,
              'created_by': doctorId,
            },
            {
              'course_id': cs101Id,
              'title': 'Control Flow Statements',
              'title_ar': 'جمل التحكم',
              'description': 'If-else, loops, and switch statements',
              'order': 3,
              'duration_minutes': 50,
              'is_published': true,
              'created_by': doctorId,
            },
          ]);
          debugPrint('Sample lectures created for CS101');
        } catch (e) {
          debugPrint('Lectures exist or error: $e');
        }
      }

      // Create course chats
      for (final course in courses) {
        try {
          final chatResult = await supabase.from('chats').upsert({
            'type': 'course',
            'name': '${course['code']} Chat',
            'course_id': course['id'],
          }).select().maybeSingle();

          if (chatResult != null) {
            final chatId = chatResult['id'];
            // Add all demo users as members
            await supabase.from('chat_members').upsert([
              {'chat_id': chatId, 'user_id': studentId},
              {'chat_id': chatId, 'user_id': doctorId},
              {'chat_id': chatId, 'user_id': taId},
            ], onConflict: 'chat_id,user_id');
            debugPrint('Created chat for ${course['code']}');
          }
        } catch (e) {
          debugPrint('Chat creation error: $e');
        }
      }

      debugPrint('Demo enrollment seeding complete!');
    } catch (e) {
      debugPrint('Error seeding enrollments: $e');
    }
  }
}
