import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/presentation/widgets/chat_bubble.dart';
import '../../../chat/presentation/cubit/chat_cubit.dart';
import '../../../chat/presentation/cubit/chat_state.dart';
import '../../../../injection_container.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatCubit>(),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            appBar: _buildAppBar(context, l10n),
            body: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildTopicChip(context, 'Molecular Genetics'),
                    const SizedBox(height: 24),
                    Expanded(
                      child: BlocBuilder<ChatCubit, ChatState>(
                        builder: (context, state) {
                          if (state is ChatLoading && (state as dynamic).messages == null) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          List<Map<String, dynamic>> messages = [];
                          bool isTyping = false;
                          if (state is ChatLoaded) {
                            messages = state.messages;
                          } else if (state is ChatLoading) {
                            isTyping = true;
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: messages.length + (isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == messages.length && isTyping) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('AI is typing...', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                                );
                              }
                              final msg = messages[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: ChatBubble(
                                  isAI: msg['sender'] == 'AI',
                                  senderName: msg['sender'] == 'AI' ? l10n.translate('ai_assistant') : l10n.translate('you'),
                                  time: msg['time'],
                                  text: msg['text'],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                _buildMessageInput(context, l10n),
              ],
            ),
          );
        }
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(l10n.translate('academic_luminary'), style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildTopicChip(BuildContext context, String topic) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology, size: 16, color: colorScheme.onTertiaryContainer),
            const SizedBox(width: 8),
            Text(topic, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onTertiaryContainer)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 110, left: 24, right: 24,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: l10n.translate('type_your_message'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (val) {
                       context.read<ChatCubit>().sendMessage(val);
                       _messageController.clear();
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<ChatCubit>().sendMessage(_messageController.text);
                    _messageController.clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Scholaris AI helps you study smarter.', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
