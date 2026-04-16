import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UploadAvatarUseCase implements UseCase<String, String> {
  final AuthRepository repository;

  UploadAvatarUseCase(this.repository);

  @override
  Future<Result<String>> call(String params) async {
    return await repository.uploadAvatar(params);
  }
}
