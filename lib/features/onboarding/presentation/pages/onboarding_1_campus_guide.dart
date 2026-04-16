import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import 'onboarding_2_ai_power.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class Onboarding1CampusGuideScreen extends StatelessWidget {
  const Onboarding1CampusGuideScreen({super.key});

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
          // Visual Accents: Asymmetric Shapes
          Positioned(
            top: -96, left: -96,
            width: 384, height: 384,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -96, right: -96,
            width: 384, height: 384,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: const SizedBox(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Utility Row
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: Text(l10n.translate('skip')),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          // Hero Illustration Container
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.9,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Decorative Back Gradients
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      colors: [colorScheme.primary.withOpacity(0.1), colorScheme.secondary.withOpacity(0.3)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: colorScheme.surface, blurRadius: 40, spreadRadius: 10),
                                    ],
                                  ),
                                ),
                                // Bento-style Asymmetric Composition
                                Positioned(
                                  top: 16, bottom: 64, left: 0, right: 48,
                                  child: Transform.rotate(
                                    angle: -2 * 3.14159 / 180,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBewjww9EilaltsTBogKNL4TaJ7O8rqk1Qfqtl_Tsyy-d5PWFfkDUqk7KCeas2PxO7JxW2lKYkd_fpviWMjJ0Nnnruh8CjLdqRLx7i2vJS0tl89qkShkU_jQqhBObL9bQzaU7vsMRXU6vat6ZpEOPoAtcXwa8qgizfOoHb9I63zlStZxerHd8vIE_wxW6Go2l2QQvPyqqqkeggshjdWKkEsvacQGPQ3-oIGRdS0Xoh8oljDJrJSrfPwGrqiLMPY2X4481v3NVr53fEX',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 100, bottom: 24, left: MediaQuery.of(context).size.width * 0.45, right: 0,
                                  child: Transform.rotate(
                                    angle: 3 * 3.14159 / 180,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8)),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCvMaGIAi3qh-471O6TjDj2Aqb_9xiWECStyBMr0s1LbIt3aHfCY0MNm08ufc9Gz-gHXz_0-rX9LyDAp4Lz4RTmDEnk82AMaPJPOTmuy7A--ulIFaaoQ-tC8qLtI0Xp7-luThj3o03h3rWBzA3dh7fk9rAYKKkT1y5XCYtI4DPzg6qQu2n-zTWlg8-FBKZ6r5pY5AYHjkimDA8xPLUKP2GW83-KKG0r1UnGZulXDIpYzL66-rhmXsaAqTFC6yXLapvkJ_UZuDoD4Zsi',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // AI Intelligence Chip floating
                                Positioned(
                                  top: MediaQuery.of(context).size.width * 0.45,
                                  right: -16,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.3 : 0.6),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: colorScheme.tertiaryContainer,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(Icons.auto_awesome, size: 16, color: colorScheme.onTertiaryContainer),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              l10n.translate('ai_unified'),
                                              style: textTheme.labelSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                                letterSpacing: -0.5,
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
                            l10n.translate('onboarding_1_title'),
                            style: textTheme.headlineLarge?.copyWith(
                              fontSize: 32,
                              height: 1.1,
                              color: colorScheme.primary,
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.translate('onboarding_1_description'),
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer: Navigation & Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    children: [
                      // Progress Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 32, height: 6, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(3))),
                          const SizedBox(width: 8),
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(3))),
                          const SizedBox(width: 8),
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(3))),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Primary Action
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const Onboarding2AiPowerScreen(),
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
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colorScheme.primary, colorScheme.primaryContainer],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(color: colorScheme.primary.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.translate('next'),
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: colorScheme.onPrimary),
                            ],
                          ),
                        ),
                      ),
                    ],
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
