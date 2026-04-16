import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/cubit/language_cubit.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/auth_state.dart';
import '../../../../core/app_localizations.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../../core/presentation/widgets/profile_avatar.dart';
import '../../../../core/presentation/widgets/setting_tile.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../courses/presentation/cubit/course_cubit.dart';
import '../../../courses/presentation/cubit/course_state.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
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

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null && context.mounted) {
      await context.read<AuthCubit>().uploadAvatar(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = context.watch<LanguageCubit>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            Icon(Icons.school, color: colorScheme.primary, size: 24),
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
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = authState.profile;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32).copyWith(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile Info
                Center(
                  child: Column(
                    children: [
                      ProfileAvatar(
                        imageUrl: profile['avatar_url'],
                        onTap: () => _pickAndUploadImage(context),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        profile['full_name'] ?? 'Prof. Dr.',
                        style: textTheme.headlineLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الكود الجامعي: ${profile['university_id'] ?? ''}',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),

                // Assigned Courses Section
                const SectionHeader(title: 'المواد المُدرَّسة'),
                const SizedBox(height: 16),
                
                BlocBuilder<CourseCubit, CourseState>(
                  builder: (context, courseState) {
                    if (courseState is CourseLoading || courseState is CourseInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (courseState is EnrolledCoursesLoaded) {
                      final courses = courseState.courses;
                      if (courses.isEmpty) {
                        return _buildEmptyState(context, 'لا يوجد مواد مسندة إليك حالياً.');
                      }
                      return Column(
                        children: courses.map((course) => _buildCourseCard(context, course)).toList(),
                      );
                    }
                    return _buildEmptyState(context, 'لا يوجد مواد مسندة إليك حالياً.');
                  },
                ),

                const SizedBox(height: 48),

                // Settings Section
                SectionHeader(title: l10n.translate('account_settings')),
                const SizedBox(height: 24),

                SettingTile(
                  icon: Icons.language,
                  title: l10n.translate('language'),
                  subtitle: isArabic ? 'العربية' : 'English (US)',
                  onTap: () => context.read<LanguageCubit>().toggleLanguage(),
                ),
                SettingTile(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  title: l10n.translate('appearance'),
                  subtitle: isDark ? 'Dark Mode' : 'Light Mode',
                  onTap: () => context.read<ThemeCubit>().cycleTheme(),
                ),
                SettingTile(
                  icon: Icons.logout,
                  title: l10n.translate('logout'),
                  subtitle: 'End faculty session',
                  isDestructive: true,
                  onTap: () async {
                    context.read<AuthCubit>().signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isArabic = context.watch<LanguageCubit>().isArabic;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? (course.nameAr ?? course.name) : course.name,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                Text(
                  course.code ?? '',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(message, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
      ),
    );
  }

}
