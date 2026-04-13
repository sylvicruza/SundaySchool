import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/curriculum.dart';
import '../services/data_service.dart';
import 'reflections_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonData lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool _isStudied = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    final dataService = DataService();
    _isStudied = dataService.isLessonStudied(widget.lesson);
    _isBookmarked = dataService.isLessonBookmarked(widget.lesson);
  }

  Widget _buildLogo(Color color) {
    return Image.asset(
      'assets/images/logo.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, stack) => Icon(Icons.church, size: 20, color: color),
    );
  }

  String get _shareText {
    return '${widget.lesson.dateTitle}\n\n${widget.lesson.content.trim()}';
  }

  Future<void> _toggleStudied() async {
    final bool value = await DataService().toggleLessonStudied(widget.lesson);
    if (!mounted) {
      return;
    }

    setState(() {
      _isStudied = value;
    });

    _showNotice(value ? 'Lesson marked as studied.' : 'Lesson removed from studied.');
  }

  Future<void> _toggleBookmark() async {
    final bool value = await DataService().toggleLessonBookmark(widget.lesson);
    if (!mounted) {
      return;
    }

    setState(() {
      _isBookmarked = value;
    });

    _showNotice(value ? 'Lesson saved to bookmarks.' : 'Lesson removed from bookmarks.');
  }

  Future<void> _copyLessonForShare() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    if (!mounted) {
      return;
    }
    _showNotice('Lesson copied. You can paste it into WhatsApp or another app.');
  }

  void _openReflections() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReflectionsScreen()));
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openMoreOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    _isStudied ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  ),
                  title: Text(_isStudied ? 'Remove studied mark' : 'Mark as studied'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleStudied();
                  },
                ),
                ListTile(
                  leading: Icon(
                    _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  ),
                  title: Text(_isBookmarked ? 'Remove bookmark' : 'Save bookmark'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleBookmark();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Copy lesson text'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyLessonForShare();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded),
                  title: const Text('Open reflections'),
                  onTap: () {
                    Navigator.pop(context);
                    _openReflections();
                  },
                ),
              ],
            ),
          ),
        );
      },
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
          // Premium Minimalist AppBar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(primaryColor),
                const SizedBox(width: 8),
                Text(
                  'LESSON STUDY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2.0),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined, color: primaryColor, size: 20),
                onPressed: () {
                  _copyLessonForShare();
                },
              ),
              IconButton(
                icon: Icon(Icons.more_vert_rounded, color: primaryColor, size: 20),
                onPressed: () {
                  _openMoreOptions();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Lesson Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '2026 MANUAL',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SPIRITUAL GROWTH',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.lesson.dateTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: primaryColor,
                      fontSize: 28,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Interactive Actions
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _toggleStudied();
                        },
                        icon: Icon(
                          _isStudied ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        label: Text(_isStudied ? 'Studied' : 'Mark as Studied'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 0,
                          backgroundColor: _isStudied ? accentColor : primaryColor,
                        ),
                      ),
                      _buildToolbarButton(context, Icons.edit_note_rounded, _openReflections),
                      _buildToolbarButton(
                        context,
                        _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        () {
                          _toggleBookmark();
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 40),
                  
                  _buildLessonContent(context, widget.lesson.content),
                  
                  const SizedBox(height: 60),
                  
                  // Reflection Section
                  _buildReflectionPrompt(context),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Icon(icon, size: 22, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildReflectionPrompt(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.secondary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Personal Reflection',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'What did you learn from this lesson? How can you apply this truth to your life today?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _openReflections,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: const Text(
                'Write your thoughts here...',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent(BuildContext context, String content) {
    final List<Widget> children = [];
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final TextStyle bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.7,
          color: const Color(0xFF2C2C2C),
        ) ??
        const TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF2C2C2C));

    for (final String rawLine in content.split('\n')) {
      final String line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 16));
        continue;
      }

      final String trimmed = line.trimLeft();
      if (trimmed.startsWith('#### ')) {
        children.add(_buildSelectableBlock(
          trimmed.substring(5),
          Theme.of(context).textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
        ));
        continue;
      }
      if (trimmed.startsWith('### ')) {
        children.add(_buildSelectableBlock(
          trimmed.substring(4),
          Theme.of(context).textTheme.titleLarge?.copyWith(
                color: primaryColor,
                fontSize: 20,
              ),
        ));
        continue;
      }
      if (trimmed.startsWith('## ')) {
        children.add(_buildSelectableBlock(
          trimmed.substring(3),
          Theme.of(context).textTheme.headlineMedium?.copyWith(color: primaryColor),
        ));
        continue;
      }
      if (trimmed.startsWith('# ')) {
        children.add(_buildSelectableBlock(
          trimmed.substring(2),
          Theme.of(context).textTheme.headlineLarge?.copyWith(color: primaryColor),
        ));
        continue;
      }
      if (trimmed.startsWith('> ')) {
        children.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: accentColor, width: 4)),
          ),
          child: SelectableText(
            trimmed.substring(2),
            style: bodyStyle.copyWith(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ));
        continue;
      }
      if (_isBullet(trimmed)) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 10),
                child: Text(
                  '•',
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: SelectableText(
                  _bulletText(trimmed),
                  style: bodyStyle,
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      children.add(_buildSelectableBlock(_stripInlineMarkdown(trimmed), bodyStyle));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildSelectableBlock(String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SelectableText(
        _stripInlineMarkdown(text),
        style: style,
      ),
    );
  }

  bool _isBullet(String line) {
    return line.startsWith('- ') ||
        line.startsWith('* ') ||
        RegExp(r'^\d+\.\s').hasMatch(line);
  }

  String _bulletText(String line) {
    if (line.startsWith('- ') || line.startsWith('* ')) {
      return _stripInlineMarkdown(line.substring(2));
    }
    return _stripInlineMarkdown(line.replaceFirst(RegExp(r'^\d+\.\s'), ''));
  }

  String _stripInlineMarkdown(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '')
        .replaceAllMapped(RegExp(r'__(.*?)__'), (match) => match.group(1) ?? '')
        .replaceAllMapped(RegExp(r'`(.*?)`'), (match) => match.group(1) ?? '')
        .replaceAllMapped(RegExp(r'\[(.*?)\]\((.*?)\)'), (match) => match.group(1) ?? '')
        .trim();
  }
}
