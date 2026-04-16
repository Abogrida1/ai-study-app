import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';

class SubjectDetailsScreen extends StatefulWidget {
  const SubjectDetailsScreen({super.key});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  int _selectedTab = 0; // 0: Lectures, 1: Materials, 2: AI Tutor

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.menu_book, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.translate('academic_luminary'),
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.notifications, color: colorScheme.onSurfaceVariant),
              onPressed: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        // Using onPrimaryContainer or black for better contrast if primary is light in dark mode
        foregroundColor: isDark ? colorScheme.onPrimaryContainer : colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.forum),
        label: Text(
          l10n.translate('chat_with_doctor'), 
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? colorScheme.onPrimaryContainer : colorScheme.onPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [colorScheme.primaryContainer, colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : colorScheme.secondaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.translate('core_curriculum'),
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : colorScheme.secondaryContainer,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Advanced Quantum Mechanics',
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 32,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB46u7z4Gtyn5s-X_KdqFuprea8_mD_pl_6WXow-Hq6tE30h4Z0O_OkFNaXciUIMJUZSJJn4ol2erCJaCUHHwmL8ieZDt8WGYeGSpGDJWwYAziScvZMvS6aENgZ_oiH86LrcGSb963un0-LJKcmT17uMfzz9H9qwOe3vCwYMFgt3uM1lJIK9h9to5dxj-q_4ToLYGc8tliIbbVv_m5CHJ2ranNKeagBlb7NHPBKctgUrvoYktREKHe1xCLz17bvoEDr82Fx4dM1QEtn'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('lead_instructor'),
                            style: textTheme.labelLarge?.copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                          Text(
                            'Dr. Alistair Thorne, PhD',
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Dynamic Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.2))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTab(context, 0, l10n.translate('lectures_tab')),
                    const SizedBox(width: 24),
                    _buildTab(context, 1, l10n.translate('materials_tab')),
                    const SizedBox(width: 24),
                    _buildTab(context, 2, l10n.translate('ai_tutor_tab'), isAi: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Below Tabs Content
            Text(
              '${l10n.translate('curriculum_progress')} (12/24)',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Video List
            _buildLectureCard(
              context,
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMvoFgP8N4t4bw954PUqJga0BzAht6uOCqJH4uLclXPTavk0Py1jgs-ElPTOsaceZCH6tyRHL2tlwnq4lrCLTM1WyvnROX6MFfX9zxRTY9KUNGbXPssprd2vPb6S847zq0XjgZESl-yxDsmpRWNAm91pkmNp1ZnVozQ85QS98kBLpqrPOyfyaVBosSxv4GQ_Xf0u_diw1CQie-VWrd41gw7Sv3zhsuWElUcLrzkkpWA1VA0Zb-lhaPBslzQYtuagLr1Q3bSl0Yh-yA',
              module: 'MODULE 04',
              title: 'Wave-Particle Duality Principles',
              meta: '45 mins • Published 2 days ago',
            ),
            const SizedBox(height: 16),
            _buildLectureCard(
              context,
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDe3O_eb5muLVTNa_iWNYrcl6bGAjTbD_wjLRxxCGH0CCL00bc5t1XsItJlChAZGW3KccaE7unf-IBLmeNBtAHK674cvbAjoBO5vI_YfAl8_PDIpJdlo33SaMoJLai7df-ItUkYjSU-5cagpvCh2FWZwYHcLuwQcRNQVYOQ5AW46aU3UM6thCc1kTVzecrK-WtYB391pOVywW6aorEwLVGaNgNygm0-HcTUf1pIrJfWAYbi3JEluVZa0pkZ1Tgl4tsNgefBVFHrGN3K',
              module: 'MODULE 05',
              title: 'The Heisenberg Uncertainty Principle',
              meta: '52 mins • Published 1 week ago',
            ),
            const SizedBox(height: 48),

            // Materials list
            Text(
              l10n.translate('subject_materials'),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildMaterialCard(context, 'Lecture_Notes_W4.pdf', '2.4 MB • Last modified Aug 24'),
            const SizedBox(height: 16),
            _buildMaterialCard(context, 'Quantum_Final_Review.pdf', '1.1 MB • Last modified Aug 20'),
            const SizedBox(height: 48),

            // AI Tutor Sidebar (Bento Style)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [colorScheme.secondary, colorScheme.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.translate('ai_tutor_title'),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "\"I've analyzed your latest quiz. You should focus on **Schrödinger Equations** before the midterm next week.\"",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildQuickAction(context, 'Generate Flashcards'),
                  const SizedBox(height: 12),
                  _buildQuickAction(context, 'Summarize Week 4'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subject Performance
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('subject_performance'),
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onInverseSurface),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'A-',
                        style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.secondaryContainer),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Top 5% of class',
                        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onInverseSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: 0.88,
                      minHeight: 6,
                      backgroundColor: colorScheme.onInverseSurface.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondaryContainer),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '88% ${l10n.translate('syllabus_completed')}',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onInverseSurface.withOpacity(0.7)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String title, {bool isAi = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
            if (isAi) ...[
              const SizedBox(width: 6),
              Icon(Icons.auto_awesome, size: 16, color: colorScheme.secondary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLectureCard(BuildContext context, {required String imageUrl, required String module, required String title, required String meta}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A191C1D), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module,
                  style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_ios, color: colorScheme.primary, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, String title, String meta) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.picture_as_pdf, color: colorScheme.error),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: colorScheme.onTertiaryContainer),
                    const SizedBox(width: 6),
                    Text(
                      'AI Summarize',
                      style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onTertiaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            meta,
            style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('quick_action'),
              style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
