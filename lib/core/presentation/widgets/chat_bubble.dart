import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String senderName;
  final String time;
  final bool isAI;

  const ChatBubble({
    super.key,
    required this.text,
    required this.senderName,
    required this.time,
    this.isAI = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
          child: Row(
            mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isAI) _buildAvatar(colorScheme, textTheme, true),
              const SizedBox(width: 8),
              Text(
                '$senderName • $time',
                style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              if (!isAI) const SizedBox(width: 8),
              if (!isAI) _buildAvatar(colorScheme, textTheme, false),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isAI 
                ? (isDark ? colorScheme.surfaceContainerHigh : colorScheme.primaryContainer)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isAI ? Radius.zero : const Radius.circular(20),
              bottomRight: isAI ? const Radius.circular(20) : Radius.zero,
            ),
            border: isAI ? null : Border.all(color: colorScheme.outlineVariant.withOpacity(0.15)),
          ),
          child: Text(
            text,
            style: textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: isAI 
                  ? (isDark ? colorScheme.onSurface : colorScheme.onPrimaryContainer)
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, TextTheme textTheme, bool isAI) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: isAI ? colorScheme.primary : colorScheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: isAI 
          ? Text('AI', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimary, fontSize: 10))
          : Icon(Icons.person, size: 14, color: colorScheme.onSurfaceVariant),
    );
  }
}
