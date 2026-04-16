import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/language_provider.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/auth_service.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class AssistantProfileScreen extends StatelessWidget {
  const AssistantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isArabic = context.watch<LanguageProvider>().isArabic;

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.person, size: 64, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Asst. Demo Assistant',
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Teaching Assistant • CS Dept',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Settings Section
            Text(
              l10n.translate('account_settings'),
              style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 24),

            _buildSettingItem(
              context: context,
              icon: Icons.language,
              title: l10n.translate('language'),
              subtitle: isArabic ? 'العربية' : 'English (US)',
              onTap: () {
                final langProvider = context.read<LanguageProvider>();
                langProvider.setLocale(isArabic ? const Locale('en') : const Locale('ar'));
              },
            ),
            _buildSettingItem(
              context: context,
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              title: l10n.translate('appearance'),
              subtitle: isDark ? 'Dark Mode' : 'Light Mode',
              onTap: () {
                context.read<ThemeProvider>().cycleTheme();
              },
            ),
            _buildSettingItem(
              context: context,
              icon: Icons.assignment_ind_rounded,
              title: 'Teaching Credentials',
              subtitle: 'TA Access Badge #4029',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              context: context,
              icon: Icons.logout,
              title: l10n.translate('logout'),
              subtitle: 'End assistant session',
              onTap: () async {
                final navigator = Navigator.of(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signing out...')),
                );
                await context.read<AuthService>().signOut();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final bgColor = isDestructive 
        ? colorScheme.errorContainer.withOpacity(0.1) 
        : colorScheme.surfaceContainerLowest;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive ? colorScheme.error.withOpacity(0.1) : colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(icon, color: isDestructive ? colorScheme.error : colorScheme.primary),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
