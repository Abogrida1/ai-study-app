import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/auth_state.dart';
import '../../../../core/supabase_client.dart';

class AssistantHomeScreen extends StatefulWidget {
  const AssistantHomeScreen({super.key});

  @override
  State<AssistantHomeScreen> createState() => _AssistantHomeScreenState();
}

class _AssistantHomeScreenState extends State<AssistantHomeScreen> {
  late Future<List<Map<String, dynamic>>> _assignedSectionsFuture;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.userId != null) {
      _assignedSectionsFuture = _loadAssignedSections(authState.userId!);
    } else {
      _assignedSectionsFuture = Future.value([]);
    }
  }

  Future<List<Map<String, dynamic>>> _loadAssignedSections(String userId) async {
    // Step 1: Get assignments for this TA
    final assignResponse = await supabase
        .from('assignments')
        .select('scope_id, course_id, scope, role')
        .eq('user_id', userId)
        .eq('scope', 'section')
        .limit(2); // Only show first 2 on home screen

    final assignments = assignResponse.whereType<Map<String, dynamic>>().toList();
    if (assignments.isEmpty) {
      return [];
    }

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
    return assignments.map((assignment) {
      final sectionId = assignment['scope_id'] as String?;
      final courseId = assignment['course_id'] as String?;

      final section = sectionId != null ? sectionsMap[sectionId] : null;
      final course = courseId != null ? coursesMap[courseId] : null;

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

      return {
        'courseName': courseName,
        'sectionName': sectionName,
        'courseCode': course?['code'] as String? ?? '',
      };
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            floating: true,
            backgroundColor: colorScheme.surface.withOpacity(0.8),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.menu, color: colorScheme.primary),
              onPressed: () {},
            ),
            title: Text(
              'Assisting Ledger',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBVpYTwWcIGt--gDfzg0fBRzlMUNg1ESTVWhB6zmw_jWaaBZ0X03cs2Ob-zODk1DaJ7X_Q7dZoai5aXcLFbrRYZ1ZKXUR9Oy-mDak-BNXY1QxOVDIe7VlDsEGpgiHkFXA_q2VGjRgOzJ9EY7s_MpMNLQJZ6HAm9My0LqH_lyjp8rkNA7aiOZStvtJg2UbX7nsS7xx5yDuv77sOCSoJQnwqz9rTTsxFDHH6TyZjPYED8CE2cA1lAkNGUU8UOywrhED2uZrzNOvnc6FyQ',
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero Section
                _buildHeroSection(context),
                const SizedBox(height: 32),

                // My Assigned Sections
                _buildSectionTitle(
                  context,
                  title: 'Assigned Lab Sections',
                  subtitle: 'معامل التدريس المعينة لي',
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _assignedSectionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                          ),
                        ),
                      );
                    }

                    final sections = snapshot.data ?? [];
                    if (sections.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No assigned lab sections',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: sections.map((section) {
                        final colors = [Colors.blue.shade50, Colors.amber.shade50];
                        final icons = [Icons.code_rounded, Icons.memory_rounded];
                        final iconColors = [colorScheme.primary, Colors.amber.shade900];
                        final idx = sections.indexOf(section);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildCourseCard(
                            context,
                            title: section['courseName'] as String,
                            subtitle: section['sectionName'] as String,
                            icon: icons[idx % icons.length],
                            color: colors[idx % colors.length],
                            iconColor: iconColors[idx % iconColors.length],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Grading Tasks
                _buildSectionTitle(
                  context,
                  title: 'Grading Tasks',
                  subtitle: 'مهام التصحيح',
                  trailing: 'View All',
                ),
                const SizedBox(height: 16),
                _buildGradingTaskCard(context),
                const SizedBox(height: 40),

                // System Status
                _buildSectionTitle(
                  context,
                  title: 'System Status',
                  subtitle: 'حالة النظام',
                ),
                const SizedBox(height: 16),
                _buildStatusCard(context),
                const SizedBox(height: 120), // Bottom padding for Nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.support_agent_rounded,
                size: 140,
                color: colorScheme.primary,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,\nAsst. Demo',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                  height: 1.2,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'The Assistant portal is ready for your tasks',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'UPCOMING LAB',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF000666), Color(0xFF1A237E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A237E).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.computer_rounded, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enter Lab Session',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Operating Systems Lab - CS Year 3',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, {required String title, required String subtitle, String? trailing}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildCourseCard(BuildContext context,
      {required String title, required String subtitle, required IconData icon, required Color color, required Color iconColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            letterSpacing: 0.5,
            fontSize: 9,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: colorScheme.outlineVariant,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildGradingTaskCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAB ASSIGNMENT 04',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Memory Management',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDF9E),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Color(0xFF584411), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'URGENT',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF584411),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoBadge(context, Icons.people_outline, '42 Submissions'),
              const SizedBox(width: 24),
              _buildInfoBadge(context, Icons.event_available, 'Due Today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Grading Assistant',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Analyzing Code Year 2',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Active',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.85,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Batch analysis of 150 scripts at 85%',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
