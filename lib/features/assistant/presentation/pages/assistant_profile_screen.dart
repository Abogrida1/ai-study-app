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

class AssistantProfileScreen extends StatelessWidget {
  const AssistantProfileScreen({super.key});

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
            Icon(Icons.workspace_premium_rounded, color: colorScheme.primary, size: 24),
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
                Center(
                  child: Column(
                    children: [
                      ProfileAvatar(
                        imageUrl: profile['avatar_url'],
                        onTap: () => _pickAndUploadImage(context),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        profile['full_name'] ?? 'Assistant Name',
                        style: textTheme.headlineLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Teaching Assistant • ${profile['department'] ?? 'Dept'}',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

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
                  icon: Icons.assignment_ind_rounded,
                  title: 'Teaching Credentials',
                  subtitle: 'TA Access Badge #${profile['university_id'] ?? '4029'}',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                SettingTile(
                  icon: Icons.logout,
                  title: l10n.translate('logout'),
                  subtitle: 'End assistant session',
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
}
