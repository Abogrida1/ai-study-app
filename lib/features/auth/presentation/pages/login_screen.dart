import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cubit/language_cubit.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/auth_state.dart';
import '../../../student/presentation/pages/student_shell.dart';
import '../../../doctor/presentation/pages/doctor_shell.dart';
import '../../../assistant/presentation/pages/assistant_shell.dart';
import '../../../../core/seed_service.dart';
import '../../../../core/presentation/widgets/auth_text_field.dart';
import '../../../../core/presentation/widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _uidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    String email = _uidController.text.trim();
    final password = _passwordController.text;

    if (email.isNotEmpty && !email.contains('@')) {
      email = '$email@scholar.uni';
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    context.read<AuthCubit>().signIn(email, password);
  }

  void _navigateToDestination(String? role) {
    Widget destination;
    if (role == 'doctor') {
      destination = const DoctorShell();
    } else if (role == 'ta') {
      destination = const AssistantShell();
    } else {
      destination = const StudentShell();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = context.watch<LanguageCubit>().isArabic;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthAuthenticated) {
          _navigateToDestination(state.role);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildBackground(context),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      children: [
                        _buildLogo(context, l10n),
                        const SizedBox(height: 48),
                        _buildLoginForm(context, l10n, isArabic),
                        const SizedBox(height: 48),
                        _buildFooter(context, l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned(
          top: -100, right: -100, width: 400, height: 400,
          child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primary.withOpacity(0.05))),
        ),
        Positioned(
          bottom: -100, left: -100, width: 300, height: 300,
          child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.secondary.withOpacity(0.05))),
        ),
      ],
    );
  }

  Widget _buildLogo(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onLongPress: () async {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(const SnackBar(content: Text('Provisioning Demo Accounts...')));
        await SeedService().seedDemoAccounts();
        if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Demo Accounts Ready!')));
      },
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
            child: Icon(Icons.menu_book, color: colorScheme.onPrimaryContainer, size: 36),
          ),
          const SizedBox(height: 24),
          Text(l10n.translate('academic_luminary'), style: textTheme.headlineLarge?.copyWith(fontSize: 28, color: colorScheme.primary)),
          Text(l10n.translate('scholaris_prime'), style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, AppLocalizations l10n, bool isArabic) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('welcome_back'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              AuthTextField(
                controller: _uidController,
                enabled: !isLoading,
                label: l10n.translate('university_id_label'),
                hint: 'مثال: 2022001',
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 24),
              AuthTextField(
                controller: _passwordController,
                enabled: !isLoading,
                label: l10n.translate('password_label'),
                hint: '••••••••',
                prefixIcon: Icons.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              Align(
                alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                child: TextButton(onPressed: () {}, child: Text(l10n.translate('forgot_password'))),
              ),
              const SizedBox(height: 32),
              isLoading 
                ? const Center(child: CircularProgressIndicator())
                : GradientButton(
                    text: l10n.translate('login'),
                    icon: isArabic ? Icons.arrow_back : Icons.arrow_forward,
                    onTap: _onLoginPressed,
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n) {
    return Text(
      l10n.translate('access_restricted_info'),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
    );
  }
}
