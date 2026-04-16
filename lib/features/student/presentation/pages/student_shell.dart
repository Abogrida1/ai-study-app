import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/widgets/modern_nav_bar.dart';
import 'student_home_screen.dart';
import 'subjects_screen.dart';
import 'ai_chat_screen.dart';
import 'profile_screen.dart';
import 'chats_list_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const SubjectsScreen(),
    const AIChatScreen(),
    const ChatsListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.grid_view_rounded, 'label': l10n.translate('overview')},
      {'icon': Icons.library_books_rounded, 'label': l10n.translate('lectures')},
      {'icon': Icons.auto_awesome_rounded, 'label': l10n.translate('chat')},
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
