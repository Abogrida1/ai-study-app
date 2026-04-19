import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_localizations.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/auth_state.dart';
import '../../../../core/presentation/widgets/modern_card.dart';
import '../../../../core/supabase_client.dart';

class AssistantLabsScreen extends StatelessWidget {
  const AssistantLabsScreen({super.key});

  Future<List<_AssignedLabSection>> _loadAssignedSections(String userId) async {
    // Step 1: Get assignments for this TA
    final assignResponse = await supabase
        .from('assignments')
        .select('scope_id, course_id, scope, role')
        .eq('user_id', userId)
        .eq('scope', 'section');

    final assignments = assignResponse.whereType<Map<String, dynamic>>().toList();
    if (assignments.isEmpty) {
      return [];
    }

    // Collect all unique section IDs and course IDs
    final sectionIds = assignments
        .map((a) => a['scope_id'])
        .whereType<String>()
        .toSet()
        .toList();
    
    final courseIds = assignments
        .map((a) => a['course_id'])
        .whereType<String>()
        .toSet()
        .toList();

    if (sectionIds.isEmpty || courseIds.isEmpty) {
      return [];
    }

    // Step 2: Fetch sections with their levels
    final sectionsResponse = await supabase
        .from('sections')
        .select('id, name, name_ar, level_id, level:levels(name, name_ar, "order")')
        .inFilter('id', sectionIds);

    final coursesResponse = await supabase
        .from('courses')
        .select('id, code, name, name_ar, semester, credit_hours')
        .inFilter('id', courseIds);

    // Build lookup maps
    final sectionsMap = <String, Map<String, dynamic>>{};
    for (final section in sectionsResponse.whereType<Map<String, dynamic>>()) {
      sectionsMap[section['id'] as String] = section;
    }

    final coursesMap = <String, Map<String, dynamic>>{};
    for (final course in coursesResponse.whereType<Map<String, dynamic>>()) {
      coursesMap[course['id'] as String] = course;
    }

    // Step 3: Build result list from assignments
    return assignments.map<_AssignedLabSection>((assignment) {
      final sectionId = assignment['scope_id'] as String?;
      final courseId = assignment['course_id'] as String?;

      final section = sectionId != null ? sectionsMap[sectionId] : null;
      final course = courseId != null ? coursesMap[courseId] : null;
      final level = section != null ? (section['level'] as Map<String, dynamic>?) : null;

      final courseName = course != null
          ? (course['name_ar'] as String?)?.trim().isNotEmpty == true
              ? course['name_ar'] as String
              : course['name'] as String? ?? 'Unknown Course'
          : 'Unknown Course';
      
      final sectionName = section != null
          ? (section['name_ar'] as String?)?.trim().isNotEmpty == true
              ? section['name_ar'] as String
              : section['name'] as String? ?? 'Section'
          : 'Section';
      
      final yearLabel = level != null
          ? 'Year ${level['name'] ?? level['name_ar'] ?? ''}'.trim()
          : 'Year ?';
      
      final courseCode = course?['code'] as String? ?? '';
      final sectionCode = (sectionId ?? '').isNotEmpty
          ? sectionId!.substring(0, 8)
          : '---';
      final semester = course?['semester'] as String? ?? 'Semester';
      final credits = course?['credit_hours']?.toString() ?? '0';

      return _AssignedLabSection(
        yearLabel: yearLabel,
        courseName: '$courseCode · $courseName',
        sectionName: sectionName,
        sectionCode: sectionCode,
        schedule: semester,
        location: 'Section ${sectionName.isNotEmpty ? sectionName : '---'}',
        studentCount: '–',
        status: 'Active',
        credits: credits,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Text(
          l10n.translate('labs'),
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<List<_AssignedLabSection>>(
            future: _loadAssignedSections(authState.userId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final sections = snapshot.data ?? [];

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24).copyWith(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('assigned_lab_sections'),
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('assistant_labs_description'),
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    if (sections.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          l10n.translate('no_assigned_lab_sections'),
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    else
                      Column(
                        children: sections.map((section) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ModernCard(
                              padding: const EdgeInsets.all(20),
                              onTap: () => _showComingSoon(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: colorScheme.primary.withOpacity(0.16),
                                        child: Icon(Icons.science_rounded, color: colorScheme.primary, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              section.courseName,
                                              style: textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              section.sectionName,
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, size: 26),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _buildLabel(context, label: section.yearLabel),
                                      _buildLabel(context, label: section.schedule),
                                      _buildLabel(context, label: section.location),
                                      _buildLabel(context, label: 'Code ${section.sectionCode}'),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Credits: ${section.credits}',
                                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                        ),
                                      ),
                                      Text(
                                        section.status,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: section.status == 'Active' ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLabel(BuildContext context, {required String label}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Section page coming soon'),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }
}

class _AssignedLabSection {
  final String yearLabel;
  final String courseName;
  final String sectionName;
  final String sectionCode;
  final String schedule;
  final String location;
  final String studentCount;
  final String status;
  final String credits;

  _AssignedLabSection({
    required this.yearLabel,
    required this.courseName,
    required this.sectionName,
    required this.sectionCode,
    required this.schedule,
    required this.location,
    required this.studentCount,
    required this.status,
    required this.credits,
  });
}
