import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'auth_state.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/upload_avatar_usecase.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../usecases/usecase.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;
  final SupabaseClient supabaseClient;

  AuthCubit({
    required this.signInUseCase,
    required this.getCurrentUserUseCase,
    required this.uploadAvatarUseCase,
    required this.supabaseClient,
  }) : super(AuthInitial()) {
    _init();
  }

  void _init() {
    supabaseClient.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        loadProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        emit(AuthUnauthenticated());
      }
    });

    if (supabaseClient.auth.currentUser != null) {
      loadProfile();
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final result = await signInUseCase(SignInParams(email: email, password: password));
    
    if (result is Success<UserEntity>) {
      // Stream listener or loadProfile will emit AuthAuthenticated shortly
      await loadProfile();
    } else if (result is Error<UserEntity>) {
      emit(AuthError(result.failure.message));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> loadProfile() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());

    if (result is Success<UserEntity?>) {
      final userEntity = result.data;
      if (userEntity != null) {
        final profile = {
          'id': userEntity.id,
          'full_name': userEntity.fullName,
          'role': userEntity.role,
          'university_id': userEntity.universityId,
          'email': userEntity.email,
          'avatar_url': userEntity.avatarUrl,
        };
        emit(AuthAuthenticated(profile));
        debugPrint('Profile loaded: ${userEntity.fullName} (${userEntity.role})');
      } else {
        emit(AuthUnauthenticated());
      }
    } else if (result is Error<UserEntity?>) {
      debugPrint('Error loading profile: ${result.failure.message}');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await supabaseClient.auth.signOut();
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return;

    await supabaseClient.from('users').update(updates).eq('id', user.id);
    await loadProfile();
  }

  Future<void> uploadAvatar(String filePath) async {
    final result = await uploadAvatarUseCase(filePath);
    if (result is Success<String>) {
      await updateProfile({'avatar_url': result.data});
    }
  }
}

