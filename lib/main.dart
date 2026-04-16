import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/cubit/theme_cubit.dart';
import 'core/cubit/language_cubit.dart';
import 'core/cubit/auth_cubit.dart';
import 'core/app_localizations.dart';
import 'core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'injection_container.dart' as di;

import 'features/courses/presentation/cubit/course_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://hrnzudvlazwlqdcbtgjn.supabase.co',
    anonKey: 'sb_publishable_ajFGoPlO_g2p2UASEBslNg_wzi4pwuU',
  );
  
  await di.init(); // Initialize Dependency Injection
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()),
        BlocProvider<AuthCubit>(create: (_) => di.sl<AuthCubit>()),
        BlocProvider<CourseCubit>(create: (_) => di.sl<CourseCubit>()),
      ],
      child: const TheScholarApp(),
    ),
  );
}

class TheScholarApp extends StatelessWidget {
  const TheScholarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'The Scholar',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(locale),
              darkTheme: AppTheme.dark(locale),
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [
                Locale('en', ''),
                Locale('ar', ''),
              ],
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}

// Keeping FoundationShell for later usage
class FoundationShell extends StatelessWidget {
  const FoundationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final langCubit = context.read<LanguageCubit>();
    final isArabic = langCubit.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'هيكل المشروع الأساسي' : 'Project Foundation Shell'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.architecture,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                isArabic 
                    ? 'تم تنظيف الواجهات بنجاح' 
                    : 'UI Cleaned Successfully',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isArabic 
                    ? 'تم الحفاظ على منطق الترجمة والوضع المظلم. المشروع جاهز لاستقبال الواجهات الجديدة.' 
                    : 'Translation and Dark Mode logic preserved. Ready for new UI implementation.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              
              // Verification Buttons
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                   BlocBuilder<ThemeCubit, ThemeMode>(
                     builder: (context, themeMode) {
                       return ElevatedButton.icon(
                         onPressed: () => themeCubit.cycleTheme(),
                         icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                         label: Text(isArabic ? 'تبديل الوضع' : 'Toggle Theme'),
                       );
                     }
                   ),
                  ElevatedButton.icon(
                    onPressed: () {
                      langCubit.setLocale(isArabic ? const Locale('en') : const Locale('ar'));
                    },
                    icon: const Icon(Icons.language),
                    label: Text(isArabic ? 'English' : 'العربية'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

