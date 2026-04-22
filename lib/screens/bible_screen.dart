import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/curriculum.dart';
import '../services/data_service.dart';
import '../services/bible_service.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final BibleService _bibleService = BibleService();
  final TextEditingController _searchController =
      TextEditingController(text: 'John 2');
  BibleBook _selectedBook = BibleService.books[42];
  BibleTranslation _selectedTranslation = BibleService.translations.first;
  int _selectedChapter = 2;
  String _activeReference = 'John 2';
  final Set<String> _bookmarkedPassages = <String>{};
  final Set<String> _bookmarkedVerses = <String>{};
  late Future<BiblePassage> _passageFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _passageFuture = _loadSelectedReference();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<BiblePassage> _loadSelectedReference() {
    return _bibleService
        .fetchPassage(
      _activeReference,
      translation: _selectedTranslation,
    )
        .then((BiblePassage passage) {
      _syncSelectionFromPassage(passage);
      return passage;
    });
  }

  void _syncSelectionFromPassage(BiblePassage passage) {
    if (passage.verses.isEmpty) {
      return;
    }

    final BibleVerse firstVerse = passage.verses.first;
    final BibleBook? book =
        BibleService.findBook(firstVerse.bookName ?? _selectedBook.name);
    if (book == null) {
      return;
    }

    _selectedBook = book;
    _selectedChapter = (firstVerse.chapter ?? _selectedChapter).clamp(
      1,
      book.chapters,
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

  void _goToAdjacentChapter(int offset) {
    final int currentBookIndex = BibleService.books.indexOf(_selectedBook);
    if (currentBookIndex == -1) {
      return;
    }

    BibleBook targetBook = _selectedBook;
    int targetChapter = _selectedChapter + offset;

    if (targetChapter < 1) {
      if (currentBookIndex == 0) {
        return;
      }
      targetBook = BibleService.books[currentBookIndex - 1];
      targetChapter = targetBook.chapters;
    } else if (targetChapter > _selectedBook.chapters) {
      if (currentBookIndex == BibleService.books.length - 1) {
        return;
      }
      targetBook = BibleService.books[currentBookIndex + 1];
      targetChapter = 1;
    }

    final String reference = '${targetBook.name} $targetChapter';
    setState(() {
      _selectedBook = targetBook;
      _selectedChapter = targetChapter;
      _activeReference = reference;
      _searchController.text = reference;
      _passageFuture = _loadSelectedReference();
    });
  }

  bool get _canGoPreviousChapter {
    return _selectedChapter > 1 ||
        BibleService.books.indexOf(_selectedBook) > 0;
  }

  bool get _canGoNextChapter {
    final int currentBookIndex = BibleService.books.indexOf(_selectedBook);
    return _selectedChapter < _selectedBook.chapters ||
        (currentBookIndex != -1 &&
            currentBookIndex < BibleService.books.length - 1);
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

  String _verseReference(BibleVerse verse) {
    final String book = verse.bookName ?? _selectedBook.name;
    final int chapter = verse.chapter ?? _selectedChapter;
    return '$book $chapter:${verse.verse}';
  }

  String _verseKey(BibleVerse verse) {
    return '${_selectedTranslation.code}:${_verseReference(verse).toLowerCase()}';
  }

  String get _passageKey {
    return '${_selectedTranslation.code}:${_activeReference.toLowerCase()}';
  }

  String _verseShareText(BibleVerse verse) {
    return '${_verseReference(verse)} (${_selectedTranslation.shortName})\n${verse.text}';
  }

  void _togglePassageBookmark() {
    final bool willBookmark = !_bookmarkedPassages.contains(_passageKey);

    setState(() {
      if (willBookmark) {
        _bookmarkedPassages.add(_passageKey);
      } else {
        _bookmarkedPassages.remove(_passageKey);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willBookmark
              ? '$_activeReference bookmarked.'
              : '$_activeReference removed from bookmarks.',
        ),
      ),
    );
  }

  void _toggleBookmark(BibleVerse verse) {
    final String key = _verseKey(verse);
    final bool willBookmark = !_bookmarkedVerses.contains(key);

    setState(() {
      if (willBookmark) {
        _bookmarkedVerses.add(key);
      } else {
        _bookmarkedVerses.remove(key);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willBookmark
              ? '${_verseReference(verse)} bookmarked.'
              : '${_verseReference(verse)} removed from bookmarks.',
        ),
      ),
    );
  }

  Future<void> _copyVerse(BibleVerse verse) async {
    await Clipboard.setData(ClipboardData(text: _verseShareText(verse)));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_verseReference(verse)} copied.')),
    );
  }

  Future<void> _shareVerse(BibleVerse verse) async {
    await Share.share(_verseShareText(verse));
  }

  Future<void> _saveVerseAsReflection(BibleVerse verse) async {
    final ReflectionNote note = ReflectionNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _verseReference(verse),
      type: 'scripture',
      content: '${verse.text}\n\n${_selectedTranslation.name}',
      date: DateTime.now(),
    );

    await DataService().saveReflection(note);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${_verseReference(verse)} saved to Reflections.')),
    );
  }

  void _showVerseMenu(BibleVerse verse) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _verseReference(verse),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.ios_share_rounded),
                  title: const Text('Share verse'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _shareVerse(verse);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copy verse'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _copyVerse(verse);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded),
                  title: const Text('Save to reflections'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _saveVerseAsReflection(verse);
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
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color accentColor = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFE),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context, primaryColor),
                    const SizedBox(height: 26),
                    _buildHeader(context, primaryColor, accentColor),
                    const SizedBox(height: 18),
                    _buildReferenceControls(context, primaryColor),
                    const SizedBox(height: 26),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return _buildPassageTitle(context, passage);
                      }

                      return _buildVerseCard(
                          context, passage.verses[index - 1]);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Color primaryColor) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bible',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: primaryColor,
                  fontSize: 40,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "God's Word for your journey.",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF8D8993),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(29),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color primaryColor,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      height: 146,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.96),
                    const Color(0xFF5B2678),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/bible_hero.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.auto_stories_rounded,
                color: Colors.white.withOpacity(0.12),
                size: 190,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: accentColor.withOpacity(0.75)),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: accentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open Scripture',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Read along during class without leaving the study flow.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.86),
                              height: 1.45,
                            ),
                      ),
                    ],
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
    final ThemeData theme = Theme.of(context);
    final bool hasSearchText = _searchController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchPassage(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF2E2933),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Search by passage',
                    hintText: 'John 2',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: hasSearchText
                        ? IconButton(
                            onPressed: () => _searchController.clear(),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Clear search',
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE7E3EA)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE7E3EA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 58,
                child: FilledButton.icon(
                  onPressed: hasSearchText ? _searchPassage : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primaryColor.withOpacity(0.35),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: const Text('Open'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _chapterButtonStyle(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      disabledForegroundColor: primaryColor.withOpacity(0.35),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      side: BorderSide(color: primaryColor.withOpacity(0.24)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildChapterNavigation(BuildContext context) {
    final bool isPassageBookmarked = _bookmarkedPassages.contains(_passageKey);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                _canGoPreviousChapter ? () => _goToAdjacentChapter(-1) : null,
            style: _chapterButtonStyle(context),
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            label: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 54,
          height: 54,
          child: OutlinedButton(
            onPressed: _togglePassageBookmark,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
              side: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.18),
              ),
              foregroundColor: Theme.of(context).primaryColor,
            ),
            child: Icon(
              isPassageBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _canGoNextChapter ? () => _goToAdjacentChapter(1) : null,
            style: _chapterButtonStyle(context),
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildPassageTitle(BuildContext context, BiblePassage passage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  items:
                      BibleService.translations.map((BibleTranslation version) {
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
          const SizedBox(height: 22),
          _buildChapterNavigation(context),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildVerseCard(BuildContext context, BibleVerse verse) {
    final bool isBookmarked = _bookmarkedVerses.contains(_verseKey(verse));
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0ECF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              verse.verse.toString(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0,
                  ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              verse.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF27212B),
                    height: 1.68,
                    fontSize: 17,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              IconButton(
                onPressed: () => _toggleBookmark(verse),
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                color: primaryColor.withOpacity(0.85),
                tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark verse',
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () => _showVerseMenu(verse),
                icon: const Icon(Icons.more_horiz_rounded),
                color: const Color(0xFF8D8993),
                tooltip: 'More verse actions',
              ),
            ],
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
