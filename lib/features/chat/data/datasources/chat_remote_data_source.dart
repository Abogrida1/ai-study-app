import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../../../../core/error/failures.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> getUserChats(String userId);
  Future<List<MessageModel>> getMessages(String chatId);
  Future<MessageModel> sendMessage(String chatId, String senderId, String content);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ChatModel>> getUserChats(String userId) async {
    try {
      final response = await supabaseClient
          .from('chat_members')
          .select('chat:chats (*, course:courses (*))')
          .eq('user_id', userId);
      
      return (response as List).map((e) => ChatModel.fromJson(e['chat'])).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final response = await supabaseClient
          .from('messages')
          .select('*, sender:users (*)')
          .eq('chat_id', chatId)
          .order('created_at');
          
      return (response as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<MessageModel> sendMessage(String chatId, String senderId, String content) async {
    try {
      final response = await supabaseClient
          .from('messages')
          .insert({
            'chat_id': chatId,
            'sender_id': senderId,
            'content': content,
          })
          .select('*, sender:users (*)')
          .single();
          
      return MessageModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
