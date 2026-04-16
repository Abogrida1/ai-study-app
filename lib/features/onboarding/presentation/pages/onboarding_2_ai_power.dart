import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import 'onboarding_3_connectivity.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class Onboarding2AiPowerScreen extends StatelessWidget {
  const Onboarding2AiPowerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -48,
            left: -48,
            width: 256,
            height: 256,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -48,
            right: -48,
            width: 192,
            height: 192,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Skip Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 600),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        child: Text(l10n.translate('skip')),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Illustrative Bento Hero
                        SizedBox(
                          height: 380,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              // Main AI Core Visualization
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: MediaQuery.of(context).size.width * 0.55,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBVeXvYTIe4mGsl9UJQiAPDMv5DjGM5WeREcrC1bpVPZKgKbm36erXeVLToW-MDFXpYmn02wYmnajbD9n3mHmU8u_vyf5qdley11vDMFyaQMwNyaHVS_TbGJC-Ub1edHRB9wI7xHxUDDJOgfzQ48mq0E3lV2KgIj6qOEJUB0KCh6AteRfBWckBg9QN7-8e2mija3lLGBZgcYvSxZPDuAO-OSDlnMlLlwhuv73O7b1N76gdkTC52pV4EpO6kd8BTBk_VgS2aseVFWtDG',
                                          fit: BoxFit.cover,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [colorScheme.primary.withOpacity(0.4), Colors.transparent],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 16, left: 16, right: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: colorScheme.tertiaryContainer,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.auto_awesome, size: 14, color: colorScheme.onTertiaryContainer),
                                                const SizedBox(width: 8),
                                                Text(
                                                  l10n.translate('ai_tutor_active'),
                                                  style: textTheme.labelSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.onTertiaryContainer,
                                                    letterSpacing: 1.0,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // PDF Insight Card
                              Positioned(
                                right: 0,
                                top: 0,
                                height: 180,
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(
                                          color: colorScheme.errorContainer.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Icon(Icons.picture_as_pdf, color: colorScheme.error),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(999))),
                                          const SizedBox(height: 8),
                                          Container(height: 6, width: 40, decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(999))),
                                        ],
                                      ),
                                      Text(
                                        l10n.translate('instant_summary'),
                                        style: textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurfaceVariant,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Chat Interaction Bubble
                              Positioned(
                                right: 0,
                                bottom: 0,
                                height: 180,
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.3 : 0.6),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.15)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32, height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: colorScheme.secondary,
                                            ),
                                            child: Icon(Icons.chat_bubble, color: colorScheme.onSecondary, size: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(height: 8, width: 48, decoration: BoxDecoration(color: colorScheme.onSurfaceVariant.withOpacity(0.2), borderRadius: BorderRadius.circular(999))),
                                                const SizedBox(height: 4),
                                                Container(height: 8, width: 36, decoration: BoxDecoration(color: colorScheme.onSurfaceVariant.withOpacity(0.1), borderRadius: BorderRadius.circular(999))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),

                        // Typography Content
                        Text(
                          l10n.translate('onboarding_2_title'),
                          style: textTheme.headlineLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.translate('onboarding_2_description'),
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Progress & Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.outlineVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 8),
                            Container(
                              width: 32, height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.outlineVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // CTA Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const Onboarding3ConnectivityScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 600),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [colorScheme.primary, colorScheme.primaryContainer],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(color: colorScheme.primary.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.translate('next'),
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.arrow_forward, color: colorScheme.onPrimary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
