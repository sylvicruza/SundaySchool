import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../services/data_service.dart';
import 'bible_screen.dart';

class SavedScripturesScreen extends StatelessWidget {
  const SavedScripturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SavedBiblePassage> passages =
        DataService().getSavedBiblePassages();
    final List<SavedBibleVerse> verses = DataService().getSavedBibleVerses();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFE),
      appBar: AppBar(
        title: const Text('Saved Scriptures'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (passages.isEmpty && verses.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Your saved passages and verses will appear here.',
              ),
            ),
          if (passages.isNotEmpty) ...[
            Text(
              'Saved Passages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            ...passages.map((SavedBiblePassage passage) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _PassageCard(passage: passage),
              );
            }),
            const SizedBox(height: 24),
          ],
          if (verses.isNotEmpty) ...[
            Text(
              'Saved Verses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            ...verses.map((SavedBibleVerse verse) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _VerseCard(verse: verse),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _PassageCard extends StatelessWidget {
  final SavedBiblePassage passage;

  const _PassageCard({required this.passage});

  @override
  Widget build(BuildContext context) {
    final String preview = passage.verses
        .take(2)
        .map((SavedBiblePassageVerse verse) => verse.text)
        .join(' ');

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BibleScreen(
              initialReference: passage.reference,
              initialTranslationCode: passage.translationCode,
              initialPassageSnapshot: passage,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              passage.reference,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              passage.translationName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  final SavedBibleVerse verse;

  const _VerseCard({required this.verse});

  SavedBiblePassage _toPassage() {
    return SavedBiblePassage(
      key: verse.key,
      reference: verse.reference,
      translationCode: verse.translationCode,
      translationName: verse.translationName,
      translationShortName: verse.translationShortName,
      verses: <SavedBiblePassageVerse>[
        SavedBiblePassageVerse(
          verse: _extractVerseNumber(),
          text: verse.text,
          bookName: _extractBookName(),
          chapter: _extractChapter(),
        ),
      ],
      savedAt: verse.savedAt,
    );
  }

  String? _extractBookName() {
    final RegExp match = RegExp(r'^(.*)\s+\d+:\d+$');
    final Match? found = match.firstMatch(verse.reference);
    return found?.group(1);
  }

  int? _extractChapter() {
    final Match? found = RegExp(r'^\D*.*?(\d+):\d+$').firstMatch(verse.reference);
    return found == null ? null : int.tryParse(found.group(1)!);
  }

  int _extractVerseNumber() {
    final Match? found = RegExp(r':(\d+)$').firstMatch(verse.reference);
    return found == null ? 1 : int.tryParse(found.group(1)!) ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BibleScreen(
              initialReference: verse.reference,
              initialTranslationCode: verse.translationCode,
              initialPassageSnapshot: _toPassage(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              verse.reference,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              verse.translationName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              verse.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
