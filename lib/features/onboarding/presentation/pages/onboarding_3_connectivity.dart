import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class Onboarding3ConnectivityScreen extends StatelessWidget {
  const Onboarding3ConnectivityScreen({super.key});

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
          SafeArea(
            child: Column(
              children: [
                // Top Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.translate('academic_luminary').toUpperCase(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          letterSpacing: -1,
                        ),
                      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Illustrative Graphic Layer
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 380),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Background Decorative Element
                              Positioned(
                                top: -16, right: -16,
                                width: 192, height: 192,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.secondary.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                                  child: const SizedBox(),
                                ),
                              ),

                              // Main Illustration Container
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Image with grayscale & multiply
                                      ColorFiltered(
                                        colorFilter: const ColorFilter.matrix([
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0,      0,      0,      1, 0,
                                        ]),
                                        child: Opacity(
                                          opacity: 0.40,
                                          child: Image.network(
                                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBTDSlhzNxeuHKKDUlvyWrmmkFDXnXtTuHPY34khK-Vq90mEebXGnrZXqlPyVrYFeLsjQmbXSn24gjzTzBJ1nkZudOT-M_w1M1GNQvUK6J6bTmLGpZpx_1iP8funLU_E7Uxzut5otbmPdCkz-emHosDvta_ovamcaj3lLEyc9x3nV85L7R6uCwQH0jN1xkl2nCpQ1SW7_Zda1RbB9Oqops-B6B9_ZWa8h-PCatkTzwnxOESSYqyEdV3ywOOHsGXLuR4EyYRQo2WsPM3',
                                            fit: BoxFit.cover,
                                            colorBlendMode: BlendMode.multiply,
                                          ),
                                        ),
                                      ),

                                      // Floating Glass UI Elements
                                      Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // Live Video Simulation
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    width: MediaQuery.of(context).size.width * 0.6,
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.3 : 0.6),
                                                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Stack(
                                                          clipBehavior: Clip.none,
                                                          children: [
                                                            Container(
                                                              width: 40, height: 40,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                border: Border.all(color: Colors.white, width: 2),
                                                                image: const DecorationImage(
                                                                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD-qNThDbm-YDDpKlUthATW5Ry5DD-yHuJMPfpBqy8omOLDei3zY9iiGSa39sWm5ZRlmNOx_cQ1A-iHv4d-1LjXljEVZ8i23MMVLF_I1EbwU_WnNVcrF4U_GB3L5WSJaGCetEgATEWzqe2XJo2V_v35sm7E4uQr8wcfjKFA7JOEll5FOclNVD9v8sa4HKjc_YQ9JnIfOGLByDu9YXwQmELXTUga05pZL1xT2S7a_qLYlAPv-pjPG-LXi67woR9aOBOMUlkDWUvxCkc9'),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: -2, right: -2,
                                                              child: Container(
                                                                width: 12, height: 12,
                                                                decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(l10n.translate('live_session'), style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: -0.5)),
                                                              Text('Dr. Sarah Jenkins', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            // Chat Bubbles
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    width: MediaQuery.of(context).size.width * 0.5,
                                                    decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.3 : 0.6), border: Border.all(color: Colors.white.withOpacity(0.1))),
                                                    child: Text(l10n.translate('chat_sample_question'), style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                width: MediaQuery.of(context).size.width * 0.45,
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary,
                                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                                                ),
                                                child: Text(l10n.translate('chat_sample_answer'), style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                                              ),
                                            ),

                                            const Spacer(),

                                            // AI Summary Available
                                            Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.tertiaryContainer,
                                                  borderRadius: BorderRadius.circular(999),
                                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.auto_awesome, size: 14, color: colorScheme.onTertiaryContainer),
                                                    const SizedBox(width: 8),
                                                    Text(l10n.translate('ai_summary_available'), style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onTertiaryContainer, letterSpacing: 1.0)),
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
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),

                        // Copy Text
                        Text(
                          l10n.translate('onboarding_3_title'),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            l10n.translate('onboarding_3_description'),
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),

                      ],
                    ),
                  ),
                ),

                // Bottom Actions: Navigation & CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.outlineVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 8),
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.outlineVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 8),
                          Container(width: 32, height: 8, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // Get Started Button
                      ElevatedButton(
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
                          child: Center(
                            child: Text(
                              l10n.translate('get_started'),
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
