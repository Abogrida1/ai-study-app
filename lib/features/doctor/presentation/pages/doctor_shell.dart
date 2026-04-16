import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/widgets/modern_nav_bar.dart';
import 'doctor_home_screen.dart';
import 'doctor_profile_screen.dart';
import 'doctor_messages_screen.dart';

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DoctorHomeScreen(),
    const Center(child: Text('Schedule Screen Placeholder')),
    const DoctorMessagesScreen(),
    const DoctorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.school_rounded, 'label': l10n.translate('overview')},
      {'icon': Icons.calendar_today_rounded, 'label': l10n.translate('todays_schedule')},
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
