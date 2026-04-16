import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/language_provider.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/auth_service.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDRqA_Wchi95dvoW17eGeJpYrKSC-8lyFUeXYclOKpPBqiscGT7r5gnFAf9YYi99QORLH-sCPPIliavH89VKqfSk-6pvMwSYhjG1ALtM0jDn5l30RkxofvePZlAVXJu4TPrpgDS5er6B-oDbVy_6EkJwKxa5bMlMkGkncqOVH87ZMU3QTDc1CWJ6X7jmmJG9cYrIrNuUJHWY7dogbUOWEEIZNTv45g2pi4VBn_X_w2kU2wXjHyYK79BieBuh78UsWm-i7aPCokDIxVu'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.surface, width: 2),
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Julian Thorne',
                      style: textTheme.headlineLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Master of Comparative Literature',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),
            
            // Stats Section
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildHeaderStat(context, 'UNIVERSITY ID', 'AL-29384-TX'),
                _buildHeaderStat(context, 'ENROLLMENT', '6 Active Courses'),
              ],
            ),
            const SizedBox(height: 48),

            Text(
              l10n.translate('account_settings'),
              style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 24),

            // Dynamic Toggles
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
              icon: Icons.notifications_active,
              title: l10n.translate('notifications'),
              subtitle: 'Daily summaries and alerts',
              onTap: () {},
            ),
            _buildSettingItem(
              context: context,
              icon: Icons.lock,
              title: l10n.translate('security_legal'),
              subtitle: 'Manage your data and access',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              context: context,
              icon: Icons.logout,
              title: l10n.translate('logout'),
              subtitle: 'Sign out of your account',
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                
                // Show confirming feedback
                messenger.showSnackBar(
                  const SnackBar(content: Text('Signing out...')),
                );

                await context.read<AuthService>().signOut();
                
                if (context.mounted) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
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
        ? colorScheme.errorContainer.withOpacity(0.2) 
        : colorScheme.surfaceContainerLowest;
    
    final iconBgColor = isDestructive 
        ? colorScheme.errorContainer 
        : colorScheme.primaryContainer.withOpacity(0.5);

    final iconColor = isDestructive ? colorScheme.error : colorScheme.primary;
    final titleColor = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isDestructive)
                  Icon(Icons.chevron_right, size: 20, color: colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
