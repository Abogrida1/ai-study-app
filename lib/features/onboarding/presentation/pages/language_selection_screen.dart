import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cubit/language_cubit.dart';
import 'onboarding_1_campus_guide.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = 'EN';

  @override
  Widget build(BuildContext context) {
    // ... rest of code unchanged except changing the button click
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Visual Anchor / Background Decoration
          Positioned(
            top: 0, right: 0,
            width: MediaQuery.of(context).size.width * 0.33,
            height: MediaQuery.of(context).size.height * 0.33,
            child: Opacity(
              opacity: 0.20,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(9999)),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBbSprPpTmp9e2PHc5ni8MCFUvPqlOI8d-r3C_dXbcazvGAoAF3j-81Dg21f4isdltOJFqD7bv83H032AslH_EQqYVLj79eUBkcAkos6EL9TAancOMgmWu7Ia8p9cASHTfYmCjX6FKXKt2IJIQTjO-U8xUyIsiYzTVztj7VeyvKuyV3Rs4NPkrTdRW8m05ihzDUYAqVOdp9_QgHKnw2tCXHXTMAq-Z3-eusmkn79vrlyhVjy-evHK9TSHMQfun9wKrmRKqXCXbb8twi',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0,
            width: MediaQuery.of(context).size.width * 0.25,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Opacity(
              opacity: 0.10,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(9999)),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBOpfh-KXMjuKQxZh-0lmb_AtX-YTBtXjwlnKd8nTCih_TnjeCT0azIlmOvNCKJo5aQe4DlmsMIXQsWNrOlZw7fbSWEEP2-QeYlr5kv26M8d9ro9ifsZIm6ZHaOVyQEIc5UV5fjuNjyn_GXx1n1aHBghnLBdKlT5UKU9PG7L075EQAKqMvNJnT6w_XehdMPy-fhfHErpMLGc9HL_4gY7pOty8Dcen-hXCmgnzB4WI87Nu7GI74ZjnWEGN88yyRNWvqflmr2hy_e8INt',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Row(
                    children: [
                      Text(
                        'Luminary',
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          letterSpacing: -1,
                        ),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Hero Section
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surfaceContainerHigh,
                          ),
                          child: Center(
                            child: Icon(Icons.language, color: colorScheme.primary, size: 32),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Select Language',
                          style: textTheme.headlineLarge?.copyWith(
                            fontSize: 32,
                            color: colorScheme.primary,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اختر اللغة',
                          style: textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Tailor your learning journey by choosing your primary language.\nخصص رحلة تعلمك باختيار لغتك الأساسية.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Language Selection Grid
                        _buildLanguageOption(
                          context,
                          code: 'EN',
                          title: 'English',
                          subtitle: 'International Academic Standard',
                          isSelected: selectedLanguage == 'EN',
                          onTap: () => setState(() => selectedLanguage = 'EN'),
                          ltr: true,
                        ),
                        const SizedBox(height: 24),
                        _buildLanguageOption(
                          context,
                          code: 'ع',
                          title: 'العربية',
                          subtitle: 'المحتوى التعليمي باللغة العربية',
                          isSelected: selectedLanguage == 'AR',
                          onTap: () => setState(() => selectedLanguage = 'AR'),
                          ltr: false,
                        ),
                        
                        const SizedBox(height: 48),

                        // AI Assistant Hint (Glassmorphism)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              color: colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.3 : 0.6),
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [colorScheme.primary, colorScheme.primaryContainer],
                                      ),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(Icons.auto_awesome, color: colorScheme.onPrimary, size: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: colorScheme.tertiaryContainer,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'AI SUPPORT',
                                            style: textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onTertiaryContainer,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Luminary's AI adapts to your choice, providing translations and summaries in your preferred language.\nيتكيف الذكاء الاصطناعي مع اختيارك، مما يوفر ترجمات وملخصات بلغتك المفضلة.",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 48),

                        // Action Button
                        ElevatedButton(
                          onPressed: () {
                            if (selectedLanguage == 'AR') {
                              context.read<LanguageCubit>().setLocale(const Locale('ar'));
                            } else {
                              context.read<LanguageCubit>().setLocale(const Locale('en'));
                            }
                            
                            // Navigate to onboarding
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const Onboarding1CampusGuideScreen(),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [colorScheme.primary, colorScheme.primaryContainer],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                selectedLanguage == 'AR' ? 'تأكيد الاختيار' : 'Confirm Selection',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          selectedLanguage == 'AR' ? 'يمكنك تغيير هذا في أي وقت من الإعدادات.' : 'You can change this anytime in settings.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 48),
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

  Widget _buildLanguageOption(
    BuildContext context, {
    required String code,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool ltr,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8))]
              : [],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: ltr ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      code,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: ltr ? 0 : null,
                left: ltr ? null : 0,
                child: Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
              ),
          ],
        ),
      ),
    );
  }
}
