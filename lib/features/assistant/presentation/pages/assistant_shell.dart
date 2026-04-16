import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/widgets/modern_nav_bar.dart';
import 'assistant_home_screen.dart';
import 'assistant_profile_screen.dart';
import 'assistant_messages_screen.dart';

class AssistantShell extends StatefulWidget {
  const AssistantShell({super.key});

  @override
  State<AssistantShell> createState() => _AssistantShellState();
}

class _AssistantShellState extends State<AssistantShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AssistantHomeScreen(),
    const Center(child: Text('Lab Schedule Placeholder')),
    const AssistantMessagesScreen(),
    const AssistantProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.school_rounded, 'label': l10n.translate('overview')},
      {'icon': Icons.calendar_today_rounded, 'label': 'Labs'},
      {'icon': Icons.chat_bubble_rounded, 'label': l10n.translate('messages')},
      {'icon': Icons.person_rounded, 'label': l10n.translate('profile')},
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ModernNavBar(
              currentIndex: _currentIndex,
              items: navItems,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
