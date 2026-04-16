import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/auth_state.dart';
import '../../../courses/presentation/cubit/course_cubit.dart';
import '../../../courses/presentation/cubit/course_state.dart';
import '../../../../core/presentation/widgets/modern_card.dart';
import '../../../../core/presentation/widgets/gradient_button.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<CourseCubit>().fetchAssignedCourses(authState.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final profile = authState.profile;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                floating: true,
                backgroundColor: colorScheme.surface.withOpacity(0.8),
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: colorScheme.primary),
                  onPressed: () {},
                ),
                title: Text(
                  'Academic Ledger',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: profile['avatar_url'] != null
                          ? NetworkImage(profile['avatar_url'])
                          : null,
                      child: profile['avatar_url'] == null
                          ? Icon(Icons.person, color: colorScheme.primary, size: 24)
                          : null,
                    ),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    BlocBuilder<CourseCubit, CourseState>(
                      builder: (context, courseState) {
                        String firstCourse = 'No Active Session';
                        String firstCourseSubtitle = 'Check your schedule';
                        if (courseState is EnrolledCoursesLoaded && courseState.courses.isNotEmpty) {
                          firstCourse = 'Start Live Session';
                          firstCourseSubtitle = '${courseState.courses.first.name} - ${courseState.courses.first.code}';
                        }
                        return _buildHeroSection(context, profile['full_name'] ?? 'Doctor', firstCourse, firstCourseSubtitle);
                      },
                    ),
                    const SizedBox(height: 32),

                    // My Assigned Sections
                    _buildSectionTitle(
                      context,
                      title: 'My Assigned Sections',
                      subtitle: 'الأقسام المعينة لي',
                    ),
                    const SizedBox(height: 16),
                    
                    BlocBuilder<CourseCubit, CourseState>(
                      builder: (context, courseState) {
                        if (courseState is CourseLoading || courseState is CourseInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (courseState is CourseError) {
                          return _buildEmptyState(context, 'لا يوجد مواد مسندة حالياً');
                        }
                        if (courseState is EnrolledCoursesLoaded) {
                          final courses = courseState.courses;
                          if (courses.isEmpty) {
                            return _buildEmptyState(context, 'لا يوجد مواد مسندة حالياً');
                          }
                          return Column(
                            children: courses.asMap().entries.map((entry) {
                               final index = entry.key;
                               final course = entry.value;
                               final colors = [const Color(0xFFE3F2FD), const Color(0xFFFFF8E1), const Color(0xFFFFEBEE)];
                               final iconColors = [colorScheme.primary, Colors.amber.shade900, Colors.red];
                               
                               return Padding(
                                 padding: const EdgeInsets.only(bottom: 12),
                                 child: ModernCard(
                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                   color: colors[index % colors.length],
                                   child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                        child: Icon(Icons.auto_stories, color: iconColors[index % iconColors.length]),
                                      ),
                                      title: Text(
                                        course.name, 
                                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                                      ),
                                      subtitle: Text(
                                        course.nameAr ?? course.code ?? '', 
                                        style: textTheme.labelSmall?.copyWith(fontSize: 10, color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.outlineVariant),
                                      onTap: () {},
                                   ),
                                 ),
                               );
                            }).toList(),
                          );
                        }
                        return _buildErrorState(context, 'فشل تحميل المواد');
                      },
                    ),

                    const SizedBox(height: 40),

                    // Active Lecture Tools
                    _buildSectionTitle(
                      context,
                      title: 'Active Lecture Tools',
                      subtitle: 'أدوات المحاضرات النشطة',
                      trailing: 'View All',
                    ),
                    const SizedBox(height: 16),
                    _buildActiveLectureCard(context),
                    const SizedBox(height: 40),

                    // System Status
                    _buildSectionTitle(
                      context,
                      title: 'System Status',
                      subtitle: 'حالة النظام',
                    ),
                    const SizedBox(height: 16),
                    _buildStatusCard(context),
                    const SizedBox(height: 120), // Bottom padding for Nav
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context, String name, String sessionTitle, String sessionSubtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.account_balance_rounded, size: 140, color: colorScheme.primary),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,\n${name.split(' ').first}',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                  height: 1.2,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The Digital Chancellor is ready for your session',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: sessionTitle,
                subtitle: sessionSubtitle,
                icon: Icons.play_circle_fill,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, {required String title, required String subtitle, String? trailing}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary),
              ),
              Text(
                subtitle,
                style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
              ),
            ],
          ),
        ),
        if (trailing != null)
          Text(trailing, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.primary)),
      ],
    );
  }

  Widget _buildActiveLectureCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModernCard(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHYS201 • YEAR 3', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurfaceVariant.withOpacity(0.6))),
                  const SizedBox(height: 4),
                  Text('Quantum Mechanics I', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary, fontSize: 20)),
                ],
              ),
              _buildLuminaryBadge(context),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoBadge(context, Icons.group_rounded, '124 Students'),
              const SizedBox(width: 24),
              _buildInfoBadge(context, Icons.schedule_rounded, '10:30 AM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuminaryBadge(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFFFDF9E), borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF584411), size: 14),
          const SizedBox(width: 4),
          Text('LUMINA AI', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF584411))),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModernCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.movie_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lecture Auto-Upload', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Physics Year 3 • 2.4 GB', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              _buildProcessingBadge(context),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.65, minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
            ),
          ),
          const SizedBox(height: 12),
          Text('AI analysis and transcription at 65%', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildProcessingBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(6)),
      child: Text('Processing', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSecondaryContainer)),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
     return Center(child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)));
  }

  Widget _buildErrorState(BuildContext context, String message) {
     return Center(child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)));
  }
}
