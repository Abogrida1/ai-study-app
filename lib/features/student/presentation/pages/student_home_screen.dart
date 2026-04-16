import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.translate('academic_luminary'),
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.notifications, color: colorScheme.onSurfaceVariant),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Greeting
            Text(
              '${l10n.translate('welcome_back')} Julian!',
              style: textTheme.headlineLarge?.copyWith(
                fontSize: 32,
                color: colorScheme.primary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '3 ${l10n.translate('lectures_remaining')}',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),

            // Quick Access Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colorScheme.primary, colorScheme.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 24, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 16,
                          right: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                color: colorScheme.secondaryContainer.withOpacity(0.2),
                                child: Icon(Icons.auto_awesome, color: colorScheme.secondaryContainer, size: 24),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: -16,
                          right: -16,
                          child: Opacity(
                            opacity: 0.1,
                            child: Icon(Icons.auto_stories, color: Colors.white, size: 120),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  l10n.translate('intelligence'),
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onTertiaryContainer,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.translate('ai_summary'),
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Review key points from yesterday's Law 101",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.analytics, color: colorScheme.primary, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.translate('my_grades'), 
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold, 
                                    color: colorScheme.primary
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.newspaper, color: colorScheme.primary, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.translate('uni_news'), 
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold, 
                                    color: colorScheme.primary
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Today's Schedule
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.translate('todays_schedule'),
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        l10n.translate('full_calendar'),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                children: [
                  _buildLectureCard(
                    context: context,
                    time: '09:00 AM',
                    room: 'ROOM 402',
                    title: 'Advanced Microeconomics',
                    professor: 'Prof. Elena Vance',
                    icon: Icons.query_stats,
                    isActive: false,
                  ),
                  const SizedBox(width: 16),
                  _buildLectureCard(
                    context: context,
                    time: '11:30 AM',
                    room: 'MAIN HALL',
                    title: 'Constitutional Law II',
                    professor: 'Dr. Marcus Thorne',
                    icon: Icons.gavel,
                    isActive: true,
                  ),
                  const SizedBox(width: 16),
                  _buildLectureCard(
                    context: context,
                    time: '02:00 PM',
                    room: 'LAB 03',
                    title: 'Data Visualization',
                    professor: 'Assist. Sarah Chen',
                    icon: Icons.pie_chart,
                    isActive: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Pinned Subjects
            Text(
              l10n.translate('pinned_subjects'),
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                _buildPinnedSubject(
                  context: context,
                  icon: Icons.balance,
                  title: 'Criminal Jurisprudence',
                  subtitle: '12 new resources added',
                ),
                const SizedBox(height: 16),
                _buildPinnedSubject(
                  context: context,
                  icon: Icons.history_edu,
                  title: 'Political Philosophy',
                  subtitle: 'Assignment due in 2 days',
                ),
                const SizedBox(height: 16),
                _buildPinnedSubject(
                  context: context,
                  icon: Icons.calculate,
                  title: 'Statistics for Social Sciences',
                  subtitle: 'No new updates',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureCard({
    required BuildContext context,
    required String time,
    required String room,
    required String title,
    required String professor,
    required IconData icon,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.surfaceContainerLowest : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border(left: BorderSide(color: colorScheme.primary, width: 4)) : null,
        boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 8))] : [],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? colorScheme.surfaceContainerHigh : colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      room,
                      style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                professor,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          Positioned(
            bottom: -8,
            right: -8,
            child: Opacity(
              opacity: 0.05,
              child: Icon(icon, size: 80, color: colorScheme.onSurface),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPinnedSubject({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Center(
              child: Icon(icon, color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.outlineVariant),
        ],
      ),
    );
  }
}
