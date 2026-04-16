import '../../../../core/usecases/usecase.dart';
import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Future<Result<List<ChatEntity>>> getUserChats(String userId);
  Future<Result<List<MessageEntity>>> getMessages(String chatId);
  Future<Result<MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  });
}
