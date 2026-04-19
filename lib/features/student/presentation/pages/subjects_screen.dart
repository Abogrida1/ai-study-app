import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/constants.dart';
import '../../../../core/cubit/language_cubit.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/auth_state.dart';
import '../../../../core/local_storage/pinned_courses_storage.dart';
import '../../../courses/presentation/cubit/course_cubit.dart';
import '../../../courses/presentation/cubit/course_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'subject_details_screen.dart';
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
            Icon(Icons.menu_book, color: colorScheme.primary, size: 24),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Subjects',
              style: textTheme.headlineLarge?.copyWith(
                fontSize: 36,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Continue your intellectual odyssey. Your currently active courses and academic progress are curated below.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: l10n.translate('search_subjects'),
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline, fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, size: 16),
                      label: Text(l10n.translate('all_filter')), // Simplified Filter to All in dummy ui
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(height: 48),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return BlocBuilder<CourseCubit, CourseState>(
                    builder: (context, courseState) {
                      if (courseState is CourseInitial) {
                        context.read<CourseCubit>().fetchEnrolledCourses(authState.userId!);
                        return const Center(child: CircularProgressIndicator());
                      } else if (courseState is CourseLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (courseState is EnrolledCoursesLoaded) {
                        if (courseState.courses.isEmpty) {
                          return Center(child: Text(l10n.translate('no_data')));
                        }
                        return Column(
                          children: courseState.courses.map((course) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: _buildSubjectCard(
                                context,
                                courseId: course.id ?? '',
                                imageUrl: course.thumbnailUrl ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuBcV2JQzIr4AAGIQnG-FEeujZbkbW62yohyEp5OGlRHPl04-vBZShXLWxcwOjmi2LX3eQEhRSoSloJqezrQx7_Gr3SjJs6miXUsn6lPSL9naIXyBgwyU1pKxmUlmfuRRvzuGy7nCdmPDjaL6O_busVhK8L3HH3rq1OuEXPWfAbL2Bp6GnGV1PSSWP4s_PGOWF88DKoOx1Fa2TQdx062Ucok-cP-cXD1_EabH2SkE47IEaytqR_21-mwn2g0-PJLWOpCate1NpJEPTsK',
                                tag: course.code,
                                title: context.read<LanguageCubit>().isArabic ? course.nameAr : course.name,
                                professor: course.professorName?.trim() ?? '',
                                progress: 0.0,
                              ),
                            );
                          }).toList(),
                        );
                      } else if (courseState is CourseError) {
                        return Center(child: Text(courseState.message));
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.auto_awesome, color: colorScheme.onPrimary, size: 32),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l10n.translate('ai_unified'),
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onTertiaryContainer,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ready for Finals?',
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 20,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(text: 'Based on your current progress in '),
                                  TextSpan(
                                    text: 'Molecular Genetics',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                                  ),
                                  const TextSpan(text: ', you should focus on Section 4: CRISPR Sequencing.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text(
                        'Generate Quiz',
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context, {
    required String courseId,
    required String imageUrl,
    required String tag,
    required String title,
    required String professor,
    required double progress,
    bool isInverted = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isInverted ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainerLowest;
    final textColor = colorScheme.onSurface;

    String formatProfessorName(String rawName) {
      final normalized = rawName.trim();
      final lower = normalized.toLowerCase();
      if (lower.startsWith('dr.') || lower.startsWith('prof.') || lower.startsWith('dr ') || lower.startsWith('prof ')) {
        return normalized;
      }
      return 'Dr. $normalized';
    }

    final professorLabel = professor.isNotEmpty ? formatProfessorName(professor) : 'Dr. TBD';

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()));
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return FutureBuilder<bool>(
            future: PinnedCoursesStorage.isPinned(courseId),
            builder: (context, snapshot) {
              final isBookmarked = snapshot.data ?? false;
              
              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () async {
                              if (isBookmarked) {
                                await PinnedCoursesStorage.removePinnedCourse(courseId);
                              } else {
                                await PinnedCoursesStorage.addPinnedCourse(courseId);
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isBookmarked ? colorScheme.primary : Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                size: 20,
                                color: isBookmarked ? colorScheme.onPrimary : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tag,
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context)!.translate('professor').capitalize()}: $professorLabel',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
