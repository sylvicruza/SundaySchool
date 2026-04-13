import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../services/data_service.dart';
import 'month_detail_screen.dart';
import 'prayer_request_screen.dart';
import 'reflections_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  static const String _manualTitle = 'Faith Foundations Manual';

  Widget _buildLogo(Color color) {
    return Image.asset(
      'assets/images/ohc-logo.png',
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.church, color: color, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final accentColor = theme.colorScheme.secondary;
    final currentMonth = _currentMonth();
    final months = DataService().curriculum?.months ?? const <MonthData>[];
    final studiedCount = DataService().getStudiedLessons().length;
    final totalLessons = months.fold<int>(0, (sum, month) => sum + month.lessons.length);
    final remainingLessons = totalLessons > studiedCount ? totalLessons - studiedCount : 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 88,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildLogo(primaryColor),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_stories_rounded, size: 16, color: accentColor),
                          const SizedBox(width: 8),
                          Text(
                            'Home',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildWelcomePanel(
                    context,
                    currentMonth: currentMonth,
                    studiedCount: studiedCount,
                    totalLessons: totalLessons,
                    remainingLessons: remainingLessons,
                  ),
                  const SizedBox(height: 28),
                  _buildSectionHeading(
                    context,
                    eyebrow: 'Quick access',
                    title: 'Keep your study rhythm simple',
                    subtitle: 'Jump into your notes, prayer support, and this month\'s study path without hunting through the app.',
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildActionItem(
                        context,
                        icon: Icons.edit_note_rounded,
                        label: 'Reflections',
                        description: 'Write what God is teaching you.',
                        color: primaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReflectionsScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildActionItem(
                        context,
                        icon: Icons.volunteer_activism_rounded,
                        label: 'Prayer Requests',
                        description: 'Share requests and stay prayerful.',
                        color: accentColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PrayerRequestScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  _buildSectionHeading(
                    context,
                    eyebrow: 'Manual overview',
                    title: 'Move through the year with confidence',
                    subtitle: 'Each month opens into detailed lessons, memory verses, and practical study sessions.',
                  ),
                  const SizedBox(height: 18),
                  _buildCurriculumSnapshot(context),
                  const SizedBox(height: 34),
                  _buildGuidancePanel(context, currentMonth: currentMonth, remainingLessons: remainingLessons),
                  const SizedBox(height: 34),
                  _buildSectionHeading(
                    context,
                    eyebrow: 'About this app',
                    title: 'A digital companion to the 2026 Bible Study Manual',
                    subtitle: 'Built to present the manual in a clean, accessible format for personal study, class preparation, reflection, and prayer.',
                  ),
                  const SizedBox(height: 16),
                  _buildPurposeCard(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  MonthData? _currentMonth() {
    final curriculum = DataService().curriculum;
    if (curriculum == null || curriculum.months.isEmpty) {
      return null;
    }

    const monthOrder = <String>[
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];

    final now = DateTime.now();
    final target = monthOrder[now.month - 1];

    for (final month in curriculum.months) {
      if (month.month.toLowerCase() == target) {
        return month;
      }
    }

    return curriculum.months.first;
  }

  Widget _buildHeroCard(BuildContext context, MonthData? currentMonth) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final accentColor = theme.colorScheme.secondary;

    if (currentMonth == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Text(
          'The 2026 manual is not available yet.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MonthDetailScreen(month: currentMonth)),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E0048), Color(0xFF59307B), Color(0xFF7D5BA6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -8,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 120,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Positioned(
              bottom: -10,
              right: 18,
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'CURRENT MONTH',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  currentMonth.month,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentMonth.topic,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  currentMonth.centralTruth,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        '${currentMonth.lessons.length} lesson${currentMonth.lessons.length == 1 ? '' : 's'} ready',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePanel(
    BuildContext context, {
    required MonthData? currentMonth,
    required int studiedCount,
    required int totalLessons,
    required int remainingLessons,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final accentColor = theme.colorScheme.secondary;
    final progress = totalLessons == 0 ? 0.0 : (studiedCount / totalLessons).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF7F2FC),
            Colors.white,
            const Color(0xFFFFF8E1),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: primaryColor.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: primaryColor.withOpacity(0.08)),
            ),
            child: Text(
              'Sunday School Manual 2026',
              style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.1),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _manualTitle,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 34,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A clearer place to start your week: open the current month, keep track of studied lessons, and stay anchored in prayer and reflection.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 24),
          _buildHeroCard(context, currentMonth),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  value: '$studiedCount',
                  label: 'Lessons studied',
                  icon: Icons.check_circle_rounded,
                  accent: const Color(0xFF0F8F5A),
                  background: const Color(0xFFF1FBF6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  context,
                  value: '$remainingLessons',
                  label: 'Still to open',
                  icon: Icons.menu_book_rounded,
                  accent: primaryColor,
                  background: const Color(0xFFF6F1FB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights_rounded, color: accentColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your current study progress',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress,
                    backgroundColor: const Color(0xFFF0ECF4),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentMonth == null
                      ? 'Load the manual to begin your study journey.'
                      : 'This month is ${currentMonth.month}. Open it to continue with ${currentMonth.lessons.length} lesson${currentMonth.lessons.length == 1 ? '' : 's'}.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(
    BuildContext context, {
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: theme.textTheme.labelSmall),
        const SizedBox(height: 6),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color accent,
    required Color background,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF1C1B1F),
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Open',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurriculumSnapshot(BuildContext context) {
    final months = DataService().curriculum?.months ?? const <MonthData>[];
    final visibleMonths = months.take(5).toList();

    return Column(
      children: visibleMonths.map((month) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MonthDetailScreen(month: month)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      month.month.substring(0, 3).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          month.month,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          month.topic,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          month.centralTruth.isNotEmpty ? month.centralTruth : '${month.lessons.length} lessons',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuidancePanel(
    BuildContext context, {
    required MonthData? currentMonth,
    required int remainingLessons,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A better way to use this dashboard',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            currentMonth == null
                ? 'Start by opening the Sunday School tab, then choose a month and begin with the first available lesson.'
                : 'Start with ${currentMonth.month}, read the current lesson, mark it as studied when you finish, then capture what stood out in reflections.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.88),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.track_changes_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    remainingLessons == 0
                        ? 'You are fully caught up on the lessons that have been opened.'
                        : '$remainingLessons lesson${remainingLessons == 1 ? '' : 's'} still waiting for your attention.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.6,
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

  Widget _buildPurposeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              Text(
                'About FaithFoundation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'FaithFoundation is the digital edition of the Opened Heavens Chapel Bible Study Manual 2026. It presents the Sunday School Department publication in a simple and orderly experience, helping members and teachers move through each month, follow every lesson outline, reflect on key truths, and stay engaged in prayer.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 14),
          Text(
            'The app is designed to support consistent Bible study with clarity and reverence, while keeping the emphasis on Scripture, spiritual growth, and faithful participation in the life of the church.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.08)),
            ),
            child: Text(
              'THIS PUBLICATION IS THE PRODUCT OF THE SUNDAY SCHOOL DEPARTMENT, ASSEMBLIES OF GOD NIGERIA.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
