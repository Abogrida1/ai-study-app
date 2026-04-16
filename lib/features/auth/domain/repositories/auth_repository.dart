import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signInWithEmailPassword(String email, String password);
  Future<Result<void>> signOut();
  Future<Result<UserEntity?>> getCurrentUser();
  Future<Result<UserEntity>> updateProfile(Map<String, dynamic> updates);
  Future<Result<String>> uploadAvatar(String filePath);
}
