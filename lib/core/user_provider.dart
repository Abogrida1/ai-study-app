import 'package:flutter/foundation.dart';
import 'supabase_client.dart';

/// Holds the current authenticated user's profile data.
/// Used across the app for role-based UI and data access.
class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;

  String? get userId => _profile?['id'];
  String? get role => _profile?['role'];
  String? get fullName => _profile?['full_name'];
  String? get universityId => _profile?['university_id'];
  String? get email => _profile?['email'];
  String? get avatarUrl => _profile?['avatar_url'];

  bool get isStudent => role == 'student';
  bool get isDoctor => role == 'doctor';
  bool get isTA => role == 'ta';
  bool get isAuthenticated => supabase.auth.currentUser != null;

  /// Sign in and load user profile
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await loadProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load the current user's profile from the `users` table
  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _profile = null;
      notifyListeners();
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _profile = response;
        debugPrint('Profile loaded: ${_profile?['full_name']} (${_profile?['role']})');
      } else {
        // Fallback to user_metadata if profile not yet created by trigger
        _profile = {
          'id': user.id,
          'full_name': user.userMetadata?['full_name'] ?? 'User',
          'role': user.userMetadata?['role'] ?? 'student',
          'university_id': user.userMetadata?['university_id'] ?? user.id,
          'email': user.email,
        };
        debugPrint('Profile from metadata: ${_profile?['full_name']} (${_profile?['role']})');
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // Fallback to metadata
      _profile = {
        'id': user.id,
        'full_name': user.userMetadata?['full_name'] ?? 'User',
        'role': user.userMetadata?['role'] ?? 'student',
        'university_id': user.userMetadata?['university_id'] ?? user.id,
        'email': user.email,
      };
    }
    notifyListeners();
  }

  /// Sign out and clear profile
  Future<void> signOut() async {
    await supabase.auth.signOut();
    _profile = null;
    notifyListeners();
  }

  /// Update profile fields
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('users')
        .update(updates)
        .eq('id', user.id);

    // Reload profile
    await loadProfile();
  }
}
