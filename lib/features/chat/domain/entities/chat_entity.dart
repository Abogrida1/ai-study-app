import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String content;
  final String type;
  final String? fileUrl;
  final DateTime createdAt;
  final String senderId;
  final String senderName;
  final String? senderAvatar;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.type,
    this.fileUrl,
    required this.createdAt,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
  });

  @override
  List<Object?> get props => [id, content, type, fileUrl, createdAt, senderId, senderName, senderAvatar];
}

class ChatEntity extends Equatable {
  final String id;
  final String type;
  final String? name;
  final MessageEntity? lastMessage;
  final int? memberCount;

  const ChatEntity({
    required this.id,
    required this.type,
    this.name,
    this.lastMessage,
    this.memberCount,
  });

  @override
  List<Object?> get props => [id, type, name, lastMessage, memberCount];
}
