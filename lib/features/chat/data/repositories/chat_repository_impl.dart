import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../../../../core/error/failures.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<ChatEntity>>> getUserChats(String userId) async {
    try {
      final chats = await remoteDataSource.getUserChats(userId);
      return Success(chats);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<MessageEntity>>> getMessages(String chatId) async {
    try {
      final messages = await remoteDataSource.getMessages(chatId);
      return Success(messages);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(chatId, senderId, content);
      return Success(message);
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(ServerFailure(e.toString()));
    }
  }
}
