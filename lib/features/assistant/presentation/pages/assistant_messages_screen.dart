import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import '../../../student/presentation/pages/chat_detail_screen.dart';

class AssistantMessagesScreen extends StatelessWidget {
  const AssistantMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header / Title & Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('messages'),
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.translate('search_messages_hint'),
                        hintStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.outline.withOpacity(0.6),
                        ),
                        prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                l10n.translate('direct_conversations').toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Conversations List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMessageItem(
                  context,
                  name: 'Dr. Aris (Professor)',
                  message: "Can you help with grading the lab scripts for Year 3?",
                  time: '11:15 AM',
                  unreadCount: 3,
                  isOnline: true,
                ),
                _buildMessageItem(
                  context,
                  name: 'Lab Support Team',
                  message: "The new IDE licenses are now active in Room 402.",
                  time: '9:30 AM',
                  unreadCount: 0,
                  isGroup: true,
                  isOnline: false,
                ),
                _buildMessageItem(
                  context,
                  name: 'Omar Khaled (Student)',
                  message: "I am having trouble with the local setup for Lab 05.",
                  time: 'Yesterday',
                  unreadCount: 1,
                  isOnline: false,
                ),
              ]),
            ),
          ),
          
          // Extra bottom space for Nav Bar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), 
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: colorScheme.primary,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    String? imageUrl,
    bool isOnline = false,
    bool isGroup = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatName: name,
                chatRole: isGroup ? 'Group' : 'User',
                avatarUrl: imageUrl ?? 'https://via.placeholder.com/150',
                isOnline: isOnline,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Avatar Stack
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isGroup ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHigh,
                    image: (!isGroup && imageUrl != null)
                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: isGroup
                      ? Icon(Icons.groups_rounded, color: colorScheme.onSecondaryContainer, size: 28)
                      : (imageUrl == null ? Icon(Icons.person, color: colorScheme.onSurfaceVariant) : null),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          color: unreadCount > 0 ? colorScheme.primary : colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            color: unreadCount > 0 ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
