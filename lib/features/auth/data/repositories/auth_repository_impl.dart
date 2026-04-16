import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/error/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<UserEntity>> signInWithEmailPassword(String email, String password) async {
    try {
      final user = await remoteDataSource.signIn(email, password);
      return Success(user);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Success(null);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Success(user);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = await remoteDataSource.updateProfile(updates);
      return Success(user);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> uploadAvatar(String filePath) async {
    try {
      final url = await remoteDataSource.uploadAvatar(filePath);
      return Success(url);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }
}
