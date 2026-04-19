import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_selection_screen.dart';

import '../../../student/presentation/pages/student_shell.dart';
import '../../../doctor/presentation/pages/doctor_shell.dart';
import '../../../assistant/presentation/pages/assistant_shell.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/auth_state.dart';
import '../../../../core/supabase_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleRedirection();
  }

  Future<void> _handleRedirection() async {
    // Wait for animation to breathe
    await Future.delayed(const Duration(seconds: 4));
    
    if (!mounted) return;

    final navigator = Navigator.of(context);
    final authCubit = context.read<AuthCubit>();

    // 1. Check if user is logged in
    if (supabase.auth.currentUser != null) {
      // 2. Load the global user profile!
      await authCubit.loadProfile();
      
      String? role;
      final state = authCubit.state;
      if (state is AuthAuthenticated) {
        role = state.role;
      }
      
      if (!mounted) return;

      Widget destination;
      switch (role) {
        case 'doctor':
          destination = const DoctorShell();
          break;
        case 'ta':
        case 'assistant':
          destination = const AssistantShell();
          break;
        case 'student':
        default:
          destination = const StudentShell();
          break;
      }

      navigator.pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      // 3. Not logged in, go to onboarding/language
      navigator.pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LanguageSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.primaryContainer],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Texture
            Positioned.fill(
              child: Opacity(
                opacity: 0.10,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA129HBxoQEUxMOLHjODQ4MQUYYGxwLGuB0TEXQyFmhnvck_uQQGiboQJlchXga716_O1zEOMsUrgonmmENZyZ9gAqNjiC52imMiD2ulgtlj4ylzlH9XOI31GVg4PduggonLBckP3DC1nBsgBaHkZVWQkydM_9uP0jSfguG-RyorlwD7NFdwnT4UqfiDVEQQZa6P1uS0rgJoYcNLU1Q_17T32iaDwYiUols0cqiSrFPo0hFtyaLoNH8T5q_lrSd7Bn4FvuMUMcSNh3-',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Secondary Imagery Detail
            Positioned(
              right: -80,
              top: MediaQuery.of(context).size.height * 0.25,
              width: 384,
              height: 384,
              child: Transform.rotate(
                angle: 12 * 3.14159 / 180,
                child: Opacity(
                  opacity: 0.20,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDB1qHunq1dqi4Y_UYHRZKSYEffPhzaJP__R4up5qL0Ud8rtspZ73El7YtSr5H823eqTONCX3K4G9Vy-rTM6V8tk0AhlPQu0tbxR9vu2HsSZSo13aZSA8Xr2B0TVvcE3OnfwuQd4b6agLTMnl7EOKoJqv7SKlsrYFJ7BF5fccr0ffLbgNXrK1dMRp7YMoDxKpdh1iAoRKve9kYNeN2JJ7Or0JZV6dTsYISN3hWf4pCKehevbJ5h0wXnbkfJZBv82K6t0P-zrKVch38r',
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.screen,
                  ),
                ),
              ),
            ),

            // Decorative Light Aura
            Positioned(
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.10),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 2.seconds, begin: 0.5, end: 1.0),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox(),
              ),
            ),

            // Central Identity Cluster
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -8, bottom: -8, left: -8, right: -8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.20),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                            boxShadow: [
                               BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.auto_awesome,
                              size: 60,
                              color: colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ].animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                ),
                const SizedBox(height: 32),

                // Brand Typography
                Text(
                  'Luminary',
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 56,
                    color: Colors.white,
                    letterSpacing: -2,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                  ),
                  textDirection: TextDirection.ltr,
                ).animate().fade(delay: 300.ms).slideY(begin: 0.3),
                const SizedBox(height: 8),
                Text(
                  'THE DIGITAL ATHENEUM',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.2,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ).animate().fade(delay: 500.ms),
              ],
            ),

            // Minimalist Corner Accents
            Positioned(
              top: 48, left: 48,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white.withOpacity(0.1)),
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 48, right: 48,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white.withOpacity(0.1)),
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
            ),

            // Bottom Loading Area
            Positioned(
              bottom: 80,
              left: 48, right: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '"Knowledge is not a vessel to be filled, but a fire to be kindled."',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.6),
                      height: 1.6,
                    ),
                    textDirection: TextDirection.ltr,
                  ).animate().fade(delay: 800.ms),
                  const SizedBox(height: 24),
                  
                  // Progress Bar
                  Container(
                    width: 240,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colorScheme.inversePrimary,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.inversePrimary.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat()).slideX(begin: -2.0, end: 4.0, duration: 1.5.seconds, curve: Curves.easeInOut),
                      ],
                    ),
                  ).animate().fade(delay: 1000.ms),

                  const SizedBox(height: 24),
                  Text(
                    'INITIALIZING INTELLIGENCE SHELL',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.4),
                    ),
                  ).animate().fade(delay: 1200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
