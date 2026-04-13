import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import 'lesson_detail_screen.dart';

class MonthDetailScreen extends StatelessWidget {
  final MonthData month;
  const MonthDetailScreen({super.key, required this.month});

  Widget _buildLogo(Color color) {
    return Image.asset(
      'assets/images/logo.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, stack) => Icon(Icons.church, size: 20, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Premium Header with Logo
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Row(
                children: [
                  _buildLogo(primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'MONTHLY STUDY',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 16),
                  // Theme Intro
                  Text(
                    month.month.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: accentColor, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    month.topic,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: primaryColor,
                      fontSize: 30,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Central Truth & Memory Verse (Premium Cards)
                  _buildStatementCard(
                    context, 
                    'CENTRAL TRUTH', 
                    month.centralTruth, 
                    Icons.auto_awesome_rounded,
                    const Color(0xFFFDF0CD),
                  ),
                  const SizedBox(height: 16),
                  _buildStatementCard(
                    context, 
                    'MEMORY VERSE', 
                    month.memoryVerse, 
                    Icons.menu_book_rounded,
                    const Color(0xFFE0F2F1),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Introduction / Learning Objectives
                  if (month.introduction.isNotEmpty) ...[
                    Text('Introduction', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Text(
                      month.introduction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 40),
                  ],
                  
                  if (month.learningObjectives.isNotEmpty) ...[
                    Text('Learning Objectives', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ...month.learningObjectives.map((obj) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(obj, style: const TextStyle(fontSize: 16, height: 1.4))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 40),
                  ],
                  
                  const Divider(height: 1),
                  const SizedBox(height: 40),
                  
                  // Lessons List
                  Text(
                    'STUDY SESSIONS',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final lesson = month.lessons[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildLessonItem(context, lesson, index + 1),
                  );
                },
                childCount: month.lessons.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatementCard(BuildContext context, String label, String text, IconData icon, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: label.contains('VERSE') ? FontStyle.italic : FontStyle.normal,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context, LessonData lesson, int weekNum) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'W$weekNum',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.dateTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore the weekly study deep-dive.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
