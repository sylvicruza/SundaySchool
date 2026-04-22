import 'package:flutter/material.dart';

import '../services/bible_service.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final BibleService _bibleService = BibleService();
  final TextEditingController _searchController =
      TextEditingController(text: 'John 3');
  BibleBook _selectedBook = BibleService.books[42];
  BibleTranslation _selectedTranslation = BibleService.translations.first;
  int _selectedChapter = 3;
  String _activeReference = 'John 3';
  late Future<BiblePassage> _passageFuture;

  @override
  void initState() {
    super.initState();
    _passageFuture = _loadSelectedReference();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<BiblePassage> _loadSelectedReference() {
    return _bibleService.fetchPassage(
      _activeReference,
      translation: _selectedTranslation,
    );
  }

  void _setChapter(int chapter) {
    setState(() {
      _selectedChapter = chapter;
      _activeReference = '${_selectedBook.name} $_selectedChapter';
      _searchController.text = _activeReference;
      _passageFuture = _loadSelectedReference();
    });
  }

  void _setBook(BibleBook? book) {
    if (book == null) {
      return;
    }

    setState(() {
      _selectedBook = book;
      _selectedChapter = _selectedChapter.clamp(1, book.chapters);
      _activeReference = '${_selectedBook.name} $_selectedChapter';
      _searchController.text = _activeReference;
      _passageFuture = _loadSelectedReference();
    });
  }

  void _setTranslation(BibleTranslation? translation) {
    if (translation == null) {
      return;
    }

    setState(() {
      _selectedTranslation = translation;
      _passageFuture = _loadSelectedReference();
    });
  }

  void _searchPassage() {
    final String reference = _searchController.text.trim();
    if (reference.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _activeReference = reference;
      _passageFuture = _loadSelectedReference();
    });
  }

  void _openQuickPassage(String reference) {
    setState(() {
      _activeReference = reference;
      _searchController.text = reference;
      _passageFuture = _loadSelectedReference();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color accentColor = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Bible'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, primaryColor, accentColor),
                  const SizedBox(height: 20),
                  _buildReferenceControls(context, primaryColor),
                  const SizedBox(height: 16),
                  _buildQuickPassages(context, accentColor),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          FutureBuilder<BiblePassage>(
            future: _passageFuture,
            builder:
                (BuildContext context, AsyncSnapshot<BiblePassage> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(context, snapshot.error.toString()),
                );
              }

              final BiblePassage passage = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverList.separated(
                  itemCount: passage.verses.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return _buildPassageTitle(context, passage);
                    }

                    return _buildVerseCard(context, passage.verses[index - 1]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color primaryColor,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Icon(Icons.menu_book_rounded, color: accentColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Open Scripture',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Read along during class without leaving the study flow.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.78),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceControls(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<BibleBook>(
                  value: _selectedBook,
                  decoration: const InputDecoration(
                    labelText: 'Book',
                    border: OutlineInputBorder(),
                  ),
                  items: BibleService.books.map((BibleBook book) {
                    return DropdownMenuItem<BibleBook>(
                      value: book,
                      child: Text(book.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: _setBook,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  value: _selectedChapter,
                  decoration: const InputDecoration(
                    labelText: 'Chapter',
                    border: OutlineInputBorder(),
                  ),
                  items: List<int>.generate(
                    _selectedBook.chapters,
                    (int index) => index + 1,
                  ).map((int chapter) {
                    return DropdownMenuItem<int>(
                      value: chapter,
                      child: Text(chapter.toString()),
                    );
                  }).toList(),
                  onChanged: (int? chapter) {
                    if (chapter != null) {
                      _setChapter(chapter);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchPassage(),
                  decoration: const InputDecoration(
                    hintText: 'Search passage',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 52,
                child: IconButton.filled(
                  onPressed: _searchPassage,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  style: IconButton.styleFrom(backgroundColor: primaryColor),
                  tooltip: 'Open passage',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPassages(BuildContext context, Color accentColor) {
    const List<String> references = <String>[
      'Psalm 23',
      'Matthew 5',
      'Romans 8',
      'James 1',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: references.map((String reference) {
        return ActionChip(
          avatar:
              Icon(Icons.auto_stories_rounded, size: 18, color: accentColor),
          label: Text(reference),
          onPressed: () => _openQuickPassage(reference),
          backgroundColor: Colors.white,
          side: BorderSide(color: accentColor.withOpacity(0.28)),
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                letterSpacing: 0,
              ),
        );
      }).toList(),
    );
  }

  Widget _buildPassageTitle(BuildContext context, BiblePassage passage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              passage.reference,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton<BibleTranslation>(
              value: _selectedTranslation,
              alignment: AlignmentDirectional.centerEnd,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
              items: BibleService.translations.map((BibleTranslation version) {
                return DropdownMenuItem<BibleTranslation>(
                  value: version,
                  child: Text(version.name),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return BibleService.translations
                    .map((BibleTranslation version) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(version.name),
                  );
                }).toList();
              },
              onChanged: _setTranslation,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(BuildContext context, BibleVerse verse) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              verse.verse.toString(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0,
                  ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              verse.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF27212B),
                    height: 1.62,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 52,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 14),
          Text(
            'Passage unavailable',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _passageFuture = _loadSelectedReference();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
