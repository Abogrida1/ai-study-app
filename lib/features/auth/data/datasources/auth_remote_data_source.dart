import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile(Map<String, dynamic> updates);
  Future<String> uploadAvatar(String filePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      await supabaseClient.auth.signInWithPassword(email: email, password: password);
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const AuthFailure('Sign in failed, no user found');
      
      return await _fetchProfile(user.id, user.email ?? email);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;
    
    return await _fetchProfile(user.id, user.email ?? '');
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw const AuthFailure('No user logged in');

    await supabaseClient.from('users').update(updates).eq('id', user.id);
    return await _fetchProfile(user.id, user.email ?? '');
  }

  Future<UserModel> _fetchProfile(String id, String email) async {
    try {
      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson({...response, 'email': email});
      } else {
        // Construct fallback from metadata if needed
        final user = supabaseClient.auth.currentUser;
        return UserModel(
          id: id,
          email: email,
          role: user?.userMetadata?['role'] ?? 'student',
          fullName: user?.userMetadata?['full_name'] ?? 'User',
          universityId: user?.userMetadata?['university_id'] ?? id,
        );
      }
    } catch (e) {
      throw ServerFailure('Failed to fetch profile: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw const AuthFailure('No user logged in');

    final fileName = 'avatar_${user.id}.jpg';
    final file = File(filePath);

    await supabaseClient.storage.from('avatars').upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final String publicUrl = supabaseClient.storage.from('avatars').getPublicUrl(fileName);
    return publicUrl;
  }
}
