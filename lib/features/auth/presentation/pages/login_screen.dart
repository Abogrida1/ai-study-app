import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/language_provider.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/user_provider.dart';
import '../../../student/presentation/pages/student_shell.dart';
import '../../../doctor/presentation/pages/doctor_shell.dart';
import '../../../assistant/presentation/pages/assistant_shell.dart';
import '../../../../core/seed_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _uidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    String email = _uidController.text.trim();
    final password = _passwordController.text;

    // Automatically append the university domain if they only entered their ID
    if (email.isNotEmpty && !email.contains('@')) {
      email = '$email@scholar.uni';
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final userProvider = context.read<UserProvider>();

    if (email.isEmpty || password.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Sign In + Load Profile via UserProvider
      await userProvider.signIn(email, password);
      
      final role = userProvider.role;
      debugPrint('Detected Role: $role');
      
      if (!mounted) return;

      // Diagnostic Toast
      final colorScheme = Theme.of(context).colorScheme;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Logged in as: ${userProvider.fullName} (Role: ${role ?? "None"})'),
          backgroundColor: colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Widget destination;
      if (role == 'doctor') {
        destination = const DoctorShell();
      } else if (role == 'ta') {
        destination = const AssistantShell();
      } else if (role == 'student') {
        destination = const StudentShell();
      } else {
        // Fallback for unset roles or newly registered users
        debugPrint('Warning: Role mismatch or missing profile. Defaulting to Student UI.');
        destination = const StudentShell();
      }

      navigator.pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Abstract Background Elements
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            width: 500,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox(),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            width: 400,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      GestureDetector(
                        onLongPress: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          // Hidden Seed Trigger for Demo
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Provisioning Demo Accounts...')),
                          );
                          await SeedService().seedDemoAccounts();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Demo Accounts Ready!')),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.12),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.menu_book,
                                color: colorScheme.onPrimaryContainer,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.translate('academic_luminary'),
                              style: textTheme.headlineLarge?.copyWith(
                                fontSize: 28,
                                color: colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.translate('scholaris_prime'),
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Login Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Text(
                              l10n.translate('welcome_back'),
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // University ID (used as email for login here)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    l10n.translate('university_id_label'),
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _uidController,
                                  enabled: !_isLoading,
                                  decoration: InputDecoration(
                                    hintText: 'مثال: 2022001',
                                    hintStyle: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.outline.withOpacity(0.6),
                                    ),
                                    prefixIcon: Icon(Icons.email, color: colorScheme.outline),
                                    filled: true,
                                    fillColor: colorScheme.surfaceContainerLow,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 2),
                                    ),
                                  ),
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    l10n.translate('password_label'),
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  enabled: !_isLoading,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.outline.withOpacity(0.6),
                                      letterSpacing: 2.0,
                                    ),
                                    prefixIcon: Icon(Icons.lock, color: colorScheme.outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: colorScheme.outline),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surfaceContainerLow,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 2),
                                    ),
                                  ),
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      minimumSize: Size.zero,
                                    ),
                                    child: Text(
                                      l10n.translate('forgot_password'),
                                      style: textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Login Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _isLoading ? colorScheme.outline : colorScheme.primary,
                                      _isLoading ? colorScheme.outline : colorScheme.primary.withOpacity(0.8)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isLoading)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        ),
                                      ),
                                    Text(
                                      _isLoading ? 'Authenticating...' : l10n.translate('login'),
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    if (!_isLoading) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        isArabic ? Icons.arrow_back : Icons.arrow_forward,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),

                      // Decorative Footer Info
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                            height: 1.6,
                          ),
                          children: [
                            TextSpan(
                              text: l10n.translate('access_restricted_info'),
                            ),
                            TextSpan(
                              text: l10n.translate('system_status_label'),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: l10n.translate('operational'),
                              style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.secondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Visual Anchor: Intelligence Chip Style Info
          if (MediaQuery.of(context).size.width > 600)
            Positioned(
              bottom: 32,
              left: isArabic ? null : 32,
              right: isArabic ? 32 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.onTertiaryContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.translate('ai_verification_active'),
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onTertiaryContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
