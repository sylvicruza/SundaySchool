import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../services/data_service.dart';
import 'month_detail_screen.dart';

class SundaySchoolScreen extends StatefulWidget {
  const SundaySchoolScreen({super.key});

  @override
  State<SundaySchoolScreen> createState() => _SundaySchoolScreenState();
}

class _SundaySchoolScreenState extends State<SundaySchoolScreen> {
  static const String _manualTitle = 'Faith Foundations Manual';

  Widget _buildLogo(Color color) {
    return Image.asset(
      'assets/images/ohc-logo.png',
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.church, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final accentColor = theme.colorScheme.secondary;
    final curriculum = DataService().curriculum;
    final months = (curriculum?.months ?? const <MonthData>[])
        .where((month) => month.topic.trim().isNotEmpty || month.lessons.isNotEmpty)
        .toList();
    final loadError = DataService().curriculumLoadError;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/class_hero.png',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: primaryColor),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.12),
                          primaryColor.withOpacity(0.58),
                          primaryColor,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 180,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Positioned(
                    top: 92,
                    left: 24,
                    right: 24,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 96,
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: _buildLogo(primaryColor),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.menu_book_rounded, size: 16, color: accentColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Sunday School',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '2026 SUNDAY SCHOOL SERIES',
                              style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _manualTitle,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 38,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'A beautiful place to move through each month, open every lesson, and stay rooted in Scripture with clarity.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.88),
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeading(
                    context,
                    eyebrow: 'Study path',
                    title: 'Monthly journeys through the Word',
                    subtitle:
                        'Each month has a clear topic, supporting lessons, and a direct path into deeper study.',
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          if (months.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final month = months[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildMonthCard(context, month, index),
                    );
                  },
                  childCount: months.length,
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(loadError ?? 'Manual data not found.'),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

  Widget _buildMonthCard(BuildContext context, MonthData month, int index) {
    final theme = Theme.of(context);
    final colorSet = _cardPalette(index);
    final color = colorSet.$1;
    final soft = colorSet.$2;
    final lessonsLabel = '${month.lessons.length} lesson${month.lessons.length == 1 ? '' : 's'}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MonthDetailScreen(month: month)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 132,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, Color.lerp(color, Colors.white, 0.35)!],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -10,
                    right: -12,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 120,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    top: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                month.month.substring(0, 3).toUpperCase(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                lessonsLabel.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          month.month,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month.topic,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: soft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_rounded, size: 18, color: color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            month.centralTruth.isNotEmpty
                                ? month.centralTruth
                                : 'Open this month to explore the lesson details and Scripture focus.',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF2F2B36),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildInfoChip(
                        context,
                        icon: Icons.menu_book_rounded,
                        label: lessonsLabel,
                        background: color.withOpacity(0.08),
                        foreground: color,
                      ),
                      _buildInfoChip(
                        context,
                        icon: Icons.stars_rounded,
                        label: month.memoryVerse.isNotEmpty ? 'Memory verse included' : 'Monthly topic',
                        background: const Color(0xFFF6F2FA),
                        foreground: theme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        'Open month',
                        style: theme.textTheme.labelMedium?.copyWith(color: color),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _cardPalette(int index) {
    final palettes = <(Color, Color)>[
      (const Color(0xFF4E0078), const Color(0xFFF5ECFB)),
      (const Color(0xFF0D47A1), const Color(0xFFEDF4FF)),
      (const Color(0xFF1B5E20), const Color(0xFFEFF9F1)),
      (const Color(0xFF8D5A00), const Color(0xFFFFF7E7)),
      (const Color(0xFFAD1457), const Color(0xFFFFEEF5)),
      (const Color(0xFF5D4037), const Color(0xFFF7F1EF)),
    ];

    return palettes[index % palettes.length];
  }
}
