import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/language_provider.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/auth_service.dart';
import '../../../../core/user_provider.dart';
import '../../../../core/supabase_client.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _isUploading = false;

  Future<List<dynamic>> _fetchCourses(String userId) async {
    try {
      final response = await supabase
          .from('assignments')
          .select('courses:course_id(code, name, name_ar)')
          .eq('user_id', userId)
          .eq('scope', 'course');
          
      return response;
    } catch (e) {
      debugPrint('Error fetching assigned courses: $e');
      return [];
    }
  }

  Future<void> _uploadImage() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.userId == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile == null) return;

    setState(() => _isUploading = true);
    
    try {
      final fileName = '${userProvider.userId}_${DateTime.now().millisecondsSinceEpoch}.webp';
      
      if (kIsWeb) {
        final fileBytes = await pickedFile.readAsBytes();
        await supabase.storage.from('avatars').uploadBinary(
          fileName,
          fileBytes,
          fileOptions: const FileOptions(contentType: 'image/webp', upsert: true),
        );
      } else {
        final filePath = pickedFile.path;
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          filePath,
          minWidth: 500,
          minHeight: 500,
          quality: 60,
          format: CompressFormat.webp,
        );

        if (compressedBytes == null) throw Exception('Compression Failed');

        await supabase.storage.from('avatars').uploadBinary(
          fileName,
          compressedBytes,
          fileOptions: const FileOptions(contentType: 'image/webp', upsert: true),
        );
      }

      // 3. Get Public URL
      final imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // 4. Update Profile in DB and Local Provider
      await userProvider.updateProfile({'avatar_url': imageUrl});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة بنجاح!')),
        );
      }
    } catch (e) {
      debugPrint('Avatar upload failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل رفع الصورة: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            Icon(Icons.school, color: colorScheme.primary, size: 24),
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Info
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isUploading ? null : _uploadImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primaryContainer,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.1),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            image: userProvider.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(userProvider.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: userProvider.avatarUrl == null
                              ? Icon(Icons.person, size: 64, color: colorScheme.onPrimaryContainer)
                              : null,
                        ),
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: colorScheme.surface, width: 3),
                              ),
                              child: Icon(Icons.camera_alt, size: 20, color: colorScheme.onPrimary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userProvider.fullName ?? 'Prof. Dr.',
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الكود الجامعي: ${userProvider.universityId ?? ''}',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),

            // Assigned Courses Section
            Text(
              'المواد المُدرَّسة',
              style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (userProvider.userId == null)
              const Center(child: CircularProgressIndicator())
            else
              FutureBuilder<List<dynamic>>(
                future: _fetchCourses(userProvider.userId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'حدث خطأ أثناء تحميل المواد',
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    );
                  }

                  final assignedCourses = snapshot.data ?? [];

                  if (assignedCourses.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          'لا يوجد مواد مسندة إليك حالياً.',
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: assignedCourses.map((assignment) {
                      final course = assignment['courses'];
                      if (course == null) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.menu_book, color: colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? (course['name_ar'] ?? course['name']) : course['name'],
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                  ),
                                  Text(
                                    course['code'] ?? '',
                                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

            const SizedBox(height: 48),

            // Settings Section
            Text(
              l10n.translate('account_settings'),
              style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

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
              icon: Icons.security,
              title: l10n.translate('security_legal'),
              subtitle: 'Professor Access Shield Active',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              context: context,
              icon: Icons.logout,
              title: l10n.translate('logout'),
              subtitle: 'End faculty session',
              onTap: () async {
                final navigator = Navigator.of(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signing out...')),
                );
                await context.read<AuthService>().signOut();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              isDestructive: true,
            ),
          ],
        ),
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
        ? colorScheme.errorContainer.withOpacity(0.1) 
        : colorScheme.surfaceContainerLowest;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive ? colorScheme.error.withOpacity(0.1) : colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(icon, color: isDestructive ? colorScheme.error : colorScheme.primary),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
