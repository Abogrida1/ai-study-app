import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme_provider.dart';
import 'core/language_provider.dart';
import 'core/app_localizations.dart';
import 'core/theme.dart';
import 'core/auth_service.dart';
import 'core/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://hrnzudvlazwlqdcbtgjn.supabase.co',
    anonKey: 'sb_publishable_ajFGoPlO_g2p2UASEBslNg_wzi4pwuU',
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const TheScholarApp(),
    ),
  );
}

class TheScholarApp extends StatelessWidget {
  const TheScholarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    return MaterialApp(
      title: 'The Scholar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(languageProvider.locale),
      darkTheme: AppTheme.dark(languageProvider.locale),
      themeMode: context.watch<ThemeProvider>().themeMode,
      locale: languageProvider.locale,
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
  }
}

// Keeping FoundationShell for later usage
class FoundationShell extends StatelessWidget {
  const FoundationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final langProvider = context.read<LanguageProvider>();
    final isArabic = langProvider.isArabic;

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
                  ElevatedButton.icon(
                    onPressed: () => themeProvider.cycleTheme(),
                    icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    label: Text(isArabic ? 'تبديل الوضع' : 'Toggle Theme'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      langProvider.setLocale(isArabic ? const Locale('en') : const Locale('ar'));
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
