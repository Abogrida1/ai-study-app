import '../../domain/entities/chat_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.content,
    required super.type,
    super.fileUrl,
    required super.createdAt,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      senderId: json['sender_id'] ?? '',
      senderName: json['sender']?['full_name'] ?? 'Unknown',
      senderAvatar: json['sender']?['avatar_url'],
    );
  }
}

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.type,
    super.name,
    super.lastMessage,
    super.memberCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'direct',
      name: json['name'] ?? json['course']?['name'],
      lastMessage: json['last_message'] != null ? MessageModel.fromJson(json['last_message']) : null,
      memberCount: json['member_count'],
    );
  }
}
