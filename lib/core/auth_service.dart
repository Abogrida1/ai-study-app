import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Sign in user with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Get current user role from `users` table (primary) or user_metadata (fallback)
  Future<String?> getUserRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // 1. Try `users` table (Database source of truth)
    try {
      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      
      final dbRole = response?['role'] as String?;
      if (dbRole != null) {
        debugPrint('Role found in DB (users table): $dbRole');
        return dbRole;
      }
    } catch (e) {
      debugPrint('Error fetching user role from DB: $e');
    }

    // 2. Fallback to Metadata
    final metadataRole = user.userMetadata?['role'];
    if (metadataRole != null) {
      debugPrint('Role found in Metadata: $metadataRole');
      return metadataRole as String;
    }

    return null;
  }

  /// Get full user profile from `users` table
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      return await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Check if user is logged in
  bool get isAuthenticated => supabase.auth.currentUser != null;

  /// Get current user data
  User? get currentUser => supabase.auth.currentUser;
}
