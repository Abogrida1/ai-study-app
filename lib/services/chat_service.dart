import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';

/// Service for chat and messaging operations.
/// Supports Supabase Realtime for live message updates.
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  /// Get all chats the user is a member of
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    try {
      final response = await supabase
          .from('chat_members')
          .select('''
            chat:chats (
              id,
              type,
              name,
              course_id,
              section_id,
              created_at,
              course:courses (
                id,
                name,
                name_ar,
                code
              )
            )
          ''')
          .eq('user_id', userId);

      // Flatten and add last message for each chat
      final chats = <Map<String, dynamic>>[];
      for (final item in response) {
        final chat = Map<String, dynamic>.from(item['chat'] as Map);
        
        // Fetch last message
        try {
          final lastMsg = await supabase
              .from('messages')
              .select('content, type, created_at, sender:users!sender_id(full_name)')
              .eq('chat_id', chat['id'])
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
          
          chat['last_message'] = lastMsg;
        } catch (_) {}

        // Fetch member count
        try {
          final members = await supabase
              .from('chat_members')
              .select('id')
              .eq('chat_id', chat['id']);
          chat['member_count'] = members.length;
        } catch (_) {}

        chats.add(chat);
      }

      // Sort by last message time
      chats.sort((a, b) {
        final aTime = a['last_message']?['created_at'] ?? a['created_at'];
        final bTime = b['last_message']?['created_at'] ?? b['created_at'];
        return (bTime ?? '').compareTo(aTime ?? '');
      });

      return chats;
    } catch (e) {
      debugPrint('Error fetching user chats: $e');
      return [];
    }
  }

  /// Get messages for a specific chat
  Future<List<Map<String, dynamic>>> getMessages(String chatId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await supabase
          .from('messages')
          .select('''
            id,
            content,
            type,
            file_url,
            created_at,
            sender_id,
            sender:users!sender_id (
              id,
              full_name,
              avatar_url,
              role
            )
          ''')
          .eq('chat_id', chatId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return [];
    }
  }

  /// Send a text message
  Future<Map<String, dynamic>?> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String type = 'text',
    String? fileUrl,
  }) async {
    try {
      final response = await supabase
          .from('messages')
          .insert({
            'chat_id': chatId,
            'sender_id': senderId,
            'content': content,
            'type': type,
            'file_url': fileUrl,
          })
          .select('''
            id,
            content,
            type,
            file_url,
            created_at,
            sender_id,
            sender:users!sender_id (
              id,
              full_name,
              avatar_url,
              role
            )
          ''')
          .single();

      return response;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }

  /// Subscribe to real-time messages for a chat
  /// Returns a RealtimeChannel that can be unsubscribed later
  RealtimeChannel subscribeToMessages(
    String chatId,
    void Function(Map<String, dynamic> newMessage) onMessage,
  ) {
    final channel = supabase
        .channel('messages:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            debugPrint('New message received in chat $chatId');
            onMessage(newRecord);
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await supabase.removeChannel(channel);
  }

  /// Get chat members
  Future<List<Map<String, dynamic>>> getChatMembers(String chatId) async {
    try {
      final response = await supabase
          .from('chat_members')
          .select('''
            user:users (
              id,
              full_name,
              avatar_url,
              role,
              university_id
            )
          ''')
          .eq('chat_id', chatId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching chat members: $e');
      return [];
    }
  }

  /// Create a direct chat between two users
  Future<String?> createDirectChat(String userId1, String userId2) async {
    try {
      // Check if direct chat already exists
      final existing = await supabase
          .from('chat_members')
          .select('chat_id')
          .eq('user_id', userId1);

      for (final membership in existing) {
        final chatId = membership['chat_id'];
        final otherMember = await supabase
            .from('chat_members')
            .select('user_id')
            .eq('chat_id', chatId)
            .eq('user_id', userId2)
            .maybeSingle();

        if (otherMember != null) {
          // Check if this is a direct chat
          final chat = await supabase
              .from('chats')
              .select('type')
              .eq('id', chatId)
              .eq('type', 'direct')
              .maybeSingle();

          if (chat != null) return chatId as String;
        }
      }

      // Create new direct chat
      final chat = await supabase
          .from('chats')
          .insert({'type': 'direct'})
          .select('id')
          .single();

      final chatId = chat['id'] as String;

      // Add both members
      await supabase.from('chat_members').insert([
        {'chat_id': chatId, 'user_id': userId1},
        {'chat_id': chatId, 'user_id': userId2},
      ]);

      return chatId;
    } catch (e) {
      debugPrint('Error creating direct chat: $e');
      return null;
    }
  }
}
