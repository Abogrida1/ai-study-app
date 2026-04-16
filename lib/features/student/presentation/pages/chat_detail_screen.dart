import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatName;
  final String chatRole;
  final String avatarUrl;
  final bool isOnline;

  const ChatDetailScreen({
    super.key,
    required this.chatName,
    required this.chatRole,
    required this.avatarUrl,
    this.isOnline = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! Are we still on for the research meeting?',
      'isMe': false,
      'time': '10:30 AM',
      'isRead': true,
    },
    {
      'text': 'Yes, definitely. I have processed the latest lab results.',
      'isMe': true,
      'time': '10:32 AM',
      'isRead': true,
    },
    {
      'text': 'Great! I will bring the draft proposal for the new grant.',
      'isMe': false,
      'time': '10:42 AM',
      'isRead': true,
    },
    {
      'text': 'Perfect. See you at the Faculty Ledger room.',
      'isMe': true,
      'time': '10:45 AM',
      'isRead': false,
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text.trim(),
          'isMe': true,
          'time': 'Now',
          'isRead': false,
        });
      });
      _messageController.clear();
      // Auto scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isGroup = widget.chatRole.contains('Group');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: colorScheme.surface.withOpacity(0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.primary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              title: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(widget.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (widget.isOnline && !isGroup)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 2.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chatName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          widget.isOnline ? l10n.translate('online') : widget.chatRole,
                          style: textTheme.labelSmall?.copyWith(
                            color: widget.isOnline ? const Color(0xFF10B981) : colorScheme.onSurfaceVariant,
                            fontWeight: widget.isOnline ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_vert, color: colorScheme.primary),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 130, left: 24, right: 24, bottom: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          // Demo Date Splitter
          if (index == 0) {
            return Column(
              children: [
                _buildDateDivider(context, 'Today'),
                _buildMessageBubble(context, msg),
              ],
            );
          }
          return _buildMessageBubble(context, msg);
        },
      ),
      bottomNavigationBar: _buildInputArea(context, l10n),
    );
  }

  Widget _buildDateDivider(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        children: [
          Expanded(child: Divider(color: colorScheme.outlineVariant.withOpacity(0.3))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colorScheme.outline,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(child: Divider(color: colorScheme.outlineVariant.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    final isMe = msg['isMe'];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: isMe ? LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                color: isMe ? null : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isMe ? 24 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe ? colorScheme.primary.withOpacity(0.2) : Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                msg['text'],
                style: textTheme.bodyLarge?.copyWith(
                  color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg['time'],
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: msg['isRead'] ? const Color(0xFF3B82F6) : colorScheme.outline,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent, // Background of the bar itself is handled by children or this
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.add_rounded, color: colorScheme.primary, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: textTheme.bodyMedium,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: l10n.translate('type_your_message'),
                    hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded, color: colorScheme.onPrimary, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
