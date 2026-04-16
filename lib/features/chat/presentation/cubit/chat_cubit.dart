import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial()) {
    _loadInitialMessages();
  }

  final List<Map<String, dynamic>> _messages = [];

  void _loadInitialMessages() {
    _messages.add({
      'text': 'Hello! I am Scholaris AI. How can I help you today?',
      'sender': 'AI',
      'time': 'Just now',
    });
    emit(ChatLoaded(List.from(_messages)));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add({
      'text': text,
      'sender': 'User',
      'time': 'Now',
    });
    emit(ChatLoaded(List.from(_messages)));

    // Simulate AI response (Since we don't have real AI endpoint yet)
    emit(ChatLoading());
    await Future.delayed(const Duration(seconds: 1));
    
    _messages.add({
      'text': 'I understand. Let me help you with "$text". I am currently processing this request...',
      'sender': 'AI',
      'time': 'Now',
    });
    
    emit(ChatLoaded(List.from(_messages)));
  }
}
