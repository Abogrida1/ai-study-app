import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';


class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Professors', 'Groups', 'Students'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Text(
          'Chats',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.edit_square, color: colorScheme.primary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                  prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: isSelected
                            ? [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Text(
                        _filters[index],
                        style: textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Chat List
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0).copyWith(bottom: 120),
              children: [
                _buildChatTile(
                  context: context,
                  name: 'Dr. Alistair Thorne',
                  role: 'Professor',
                  lastMessage: 'The quantum physics papers are available. Let me know if you need any help grasping the concepts.',
                  time: '10:42 AM',
                  unreadCount: 2,
                  isOnline: true,
                  avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB46u7z4Gtyn5s-X_KdqFuprea8_mD_pl_6WXow-Hq6tE30h4Z0O_OkFNaXciUIMJUZSJJn4ol2erCJaCUHHwmL8ieZDt8WGYeGSpGDJWwYAziScvZMvS6aENgZ_oiH86LrcGSb963un0-LJKcmT17uMfzz9H9qwOe3vCwYMFgt3uM1lJIK9h9to5dxj-q_4ToLYGc8tliIbbVv_m5CHJ2ranNKeagBlb7NHPBKctgUrvoYktREKHe1xCLz17bvoEDr82Fx4dM1QEtn',
                ),
                _buildChatTile(
                  context: context,
                  name: 'Advanced CS Study Group',
                  role: 'Group • 8 Members',
                  lastMessage: 'Mike: Has anyone solved equation 4 on the assignment?',
                  time: 'Yesterday',
                  unreadCount: 5,
                  isOnline: false,
                  avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAnM50XmY-C7ZLY88X88TqKTYu2c3m1i-P4lZp3p1l0h4lHwPQp8XoH51I8B4DqzYj-Q6iO1_8qL2Z7L0lQjI2Zt1mIuL76-JjL6iO8kL6wT-k0i_B0Yh4pP0g_1f9D8c_bZpN6jI9rA1uLm-L0dYv3I0_u8pNj4hX0d8wJ1o-v3M4kPqU0vLxJbX_q09yP1M7c_j',
                  isGroup: true,
                ),
                _buildChatTile(
                  context: context,
                  name: 'Sarah Chen',
                  role: 'Student',
                  lastMessage: 'Thanks for sharing the notes from yesterday\'s lecture!',
                  time: 'Yesterday',
                  unreadCount: 0,
                  isOnline: false,
                  avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAhMUiXc9pBJmMDwDDSVFoN6ROHXyDPJp_p4CQM8VVtkE2NawcKFjT5UZnizerp_Ay9wzqauoTlqYMr7pGAgdwMbeU0ipqVIZEqtiVjIzCYtsjItHWHUsjG3W23aXIMy0pQZqzfPJuQP1lwIdGOHk78CGOfsOs2qdc4m-J__rQtzfXXMnT-8b-mwL9H7efn9U7wutXfVH5W-kZ1kf3w46OW6awlfTFMx3TOxNOkjt0Qd3kjs4JjgBB93092jR_Dn2qbAn6__EgVv8eX',
                ),
                _buildChatTile(
                  context: context,
                  name: 'Dr. Marcus Sterling',
                  role: 'Professor',
                  lastMessage: 'Your thesis draft looks solid. Review the comments I sent.',
                  time: 'Mon',
                  unreadCount: 0,
                  isOnline: true,
                  avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBcV2JQzIr4AAGIQnG-FEeujZbkbW62yohyEp5OGlRHPl04-vBZShXLWxcwOjmi2LX3eQEhRSoSloJqezrQx7_Gr3SjJs6miXUsn6lPSL9naIXyBgwyU1pKxmUlmfuRRvzuGy7nCdmPDjaL6O_busVhK8L3HH3rq1OuEXPWfAbL2Bp6GnGV1PSSWP4s_PGOWF88DKoOx1Fa2TQdx062Ucok-cP-cXD1_EabH2SkE47IEaytqR_21-mwn2g0-PJLWOpCate1NpJEPTsK',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String role,
    required String lastMessage,
    required String time,
    required int unreadCount,
    required bool isOnline,
    required String avatarUrl,
    bool isGroup = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // If not matching filter, return empty space (simple mock filtering)
    if (_selectedFilterIndex == 1 && role != 'Professor') return const SizedBox.shrink();
    if (_selectedFilterIndex == 2 && !isGroup) return const SizedBox.shrink();
    if (_selectedFilterIndex == 3 && role != 'Student') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatName: name, 
                chatRole: role, 
                avatarUrl: avatarUrl, 
                isOnline: isOnline,
              ),
            ),
          );
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: isGroup ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: isGroup ? BorderRadius.circular(16) : null,
                      image: DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isOnline && !isGroup)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Emerald 500
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
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
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr, // Keep names standard
                          ),
                        ),
                        Text(
                          time,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                            color: unreadCount > 0 ? colorScheme.primary : colorScheme.outline,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                              color: unreadCount > 0 ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
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
      ),
    );
  }
}
