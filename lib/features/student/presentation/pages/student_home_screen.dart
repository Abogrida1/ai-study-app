import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/auth_state.dart';
import '../../../courses/presentation/cubit/course_cubit.dart';
import '../../../courses/presentation/cubit/course_state.dart';
import '../../../../core/presentation/widgets/modern_card.dart';
import '../../../../core/presentation/widgets/schedule_tile.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final profile = authState.profile;
        final userId = authState.userId;
        final name = profile['full_name']?.split(' ').first ?? 'Student';

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
                  '${l10n.translate('welcome_back')} $name!',
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    color: colorScheme.primary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                
                BlocBuilder<CourseCubit, CourseState>(
                  builder: (context, courseState) {
                    if (courseState is CourseInitial) {
                      context.read<CourseCubit>().fetchEnrolledCourses(userId!);
                      return const SizedBox.shrink();
                    }
                    if (courseState is EnrolledCoursesLoaded) {
                      return Text(
                        '${courseState.courses.length} ${l10n.translate('lectures_remaining')}',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 40),

                // Quick Access Section
                _buildQuickAccess(context),
                const SizedBox(height: 48),

                // Today's Schedule
                _buildScheduleHeader(context),
                const SizedBox(height: 24),
                _buildScheduleList(context),
                const SizedBox(height: 48),

                // Pinned Subjects (Enrolled Courses)
                Text(
                  l10n.translate('pinned_subjects'),
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                
                BlocBuilder<CourseCubit, CourseState>(
                  builder: (context, courseState) {
                    if (courseState is EnrolledCoursesLoaded) {
                      final courses = courseState.courses;
                      if (courses.isEmpty) return const Center(child: Text('No courses pinned'));
                      return Column(
                        children: courses.map((course) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildPinnedSubject(
                            context: context,
                            icon: Icons.menu_book,
                            title: course.name,
                            subtitle: course.code ?? '',
                          ),
                        )).toList(),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModernCard(
          padding: EdgeInsets.zero,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                const Positioned(
                  bottom: -16, right: -16,
                  child: Opacity(opacity: 0.1, child: Icon(Icons.auto_stories, color: Colors.white, size: 120)),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                        child: Text(l10n.translate('intelligence'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      const Text('ملخص المذاكرة الذكي', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("راجع أهم النقاط من محاضرة الفيزياء", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(child: ModernCard(
                onTap: () {},
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.analytics, color: colorScheme.primary), const SizedBox(height: 8), Text(l10n.translate('my_grades'), style: const TextStyle(fontWeight: FontWeight.bold))]),
              )),
              const SizedBox(width: 16),
              Expanded(child: ModernCard(
                onTap: () {},
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.newspaper, color: colorScheme.primary), const SizedBox(height: 8), Text(l10n.translate('uni_news'), style: const TextStyle(fontWeight: FontWeight.bold))]),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.translate('todays_schedule'), style: textTheme.headlineMedium?.copyWith(fontSize: 24, color: colorScheme.onSurface)),
        GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Text(l10n.translate('full_calendar'), style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleList(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: const [
          ScheduleTile(time: '09:00 AM', room: 'ROOM 402', title: 'Advanced Microeconomics', subtitle: 'Prof. Elena Vance', icon: Icons.query_stats),
          SizedBox(width: 16),
          ScheduleTile(time: '11:30 AM', room: 'MAIN HALL', title: 'Constitutional Law II', subtitle: 'Dr. Marcus Thorne', icon: Icons.gavel, isActive: true),
          SizedBox(width: 16),
          ScheduleTile(time: '02:00 PM', room: 'LAB 03', title: 'Data Visualization', subtitle: 'Assist. Sarah Chen', icon: Icons.pie_chart),
        ],
      ),
    );
  }

  Widget _buildPinnedSubject({required BuildContext context, required IconData icon, required String title, required String subtitle}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: colorScheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
            child: Center(child: Icon(icon, color: colorScheme.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.outlineVariant),
        ],
      ),
    );
  }
}
