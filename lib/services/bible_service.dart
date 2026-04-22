import 'dart:convert';

import 'package:http/http.dart' as http;

class BibleBook {
  final String name;
  final int chapters;

  const BibleBook(this.name, this.chapters);
}

class BibleTranslation {
  final String code;
  final String name;
  final String shortName;

  const BibleTranslation({
    required this.code,
    required this.name,
    required this.shortName,
  });
}

class BibleVerse {
  final String? bookName;
  final int? chapter;
  final int verse;
  final String text;

  const BibleVerse({
    this.bookName,
    this.chapter,
    required this.verse,
    required this.text,
  });
}

class BiblePassage {
  final String reference;
  final BibleTranslation translation;
  final List<BibleVerse> verses;

  const BiblePassage({
    required this.reference,
    required this.translation,
    required this.verses,
  });
}

class BibleService {
  static const BibleTranslation kingJamesVersion = BibleTranslation(
    code: 'kjv',
    name: 'King James Version',
    shortName: 'KJV',
  );

  static const List<BibleTranslation> translations = <BibleTranslation>[
    kingJamesVersion,
    BibleTranslation(
      code: 'web',
      name: 'World English Bible',
      shortName: 'WEB',
    ),
    BibleTranslation(
      code: 'asv',
      name: 'American Standard Version',
      shortName: 'ASV',
    ),
    BibleTranslation(
      code: 'bbe',
      name: 'Bible in Basic English',
      shortName: 'BBE',
    ),
    BibleTranslation(
      code: 'ylt',
      name: "Young's Literal Translation",
      shortName: 'YLT',
    ),
    BibleTranslation(
      code: 'wbs',
      name: 'Webster Bible',
      shortName: 'WBS',
    ),
  ];

  static const List<BibleBook> books = <BibleBook>[
    BibleBook('Genesis', 50),
    BibleBook('Exodus', 40),
    BibleBook('Leviticus', 27),
    BibleBook('Numbers', 36),
    BibleBook('Deuteronomy', 34),
    BibleBook('Joshua', 24),
    BibleBook('Judges', 21),
    BibleBook('Ruth', 4),
    BibleBook('1 Samuel', 31),
    BibleBook('2 Samuel', 24),
    BibleBook('1 Kings', 22),
    BibleBook('2 Kings', 25),
    BibleBook('1 Chronicles', 29),
    BibleBook('2 Chronicles', 36),
    BibleBook('Ezra', 10),
    BibleBook('Nehemiah', 13),
    BibleBook('Esther', 10),
    BibleBook('Job', 42),
    BibleBook('Psalms', 150),
    BibleBook('Proverbs', 31),
    BibleBook('Ecclesiastes', 12),
    BibleBook('Song of Solomon', 8),
    BibleBook('Isaiah', 66),
    BibleBook('Jeremiah', 52),
    BibleBook('Lamentations', 5),
    BibleBook('Ezekiel', 48),
    BibleBook('Daniel', 12),
    BibleBook('Hosea', 14),
    BibleBook('Joel', 3),
    BibleBook('Amos', 9),
    BibleBook('Obadiah', 1),
    BibleBook('Jonah', 4),
    BibleBook('Micah', 7),
    BibleBook('Nahum', 3),
    BibleBook('Habakkuk', 3),
    BibleBook('Zephaniah', 3),
    BibleBook('Haggai', 2),
    BibleBook('Zechariah', 14),
    BibleBook('Malachi', 4),
    BibleBook('Matthew', 28),
    BibleBook('Mark', 16),
    BibleBook('Luke', 24),
    BibleBook('John', 21),
    BibleBook('Acts', 28),
    BibleBook('Romans', 16),
    BibleBook('1 Corinthians', 16),
    BibleBook('2 Corinthians', 13),
    BibleBook('Galatians', 6),
    BibleBook('Ephesians', 6),
    BibleBook('Philippians', 4),
    BibleBook('Colossians', 4),
    BibleBook('1 Thessalonians', 5),
    BibleBook('2 Thessalonians', 3),
    BibleBook('1 Timothy', 6),
    BibleBook('2 Timothy', 4),
    BibleBook('Titus', 3),
    BibleBook('Philemon', 1),
    BibleBook('Hebrews', 13),
    BibleBook('James', 5),
    BibleBook('1 Peter', 5),
    BibleBook('2 Peter', 3),
    BibleBook('1 John', 5),
    BibleBook('2 John', 1),
    BibleBook('3 John', 1),
    BibleBook('Jude', 1),
    BibleBook('Revelation', 22),
  ];

  static BibleBook? findBook(String name) {
    final String normalized = _normalizeBookName(name);
    for (final BibleBook book in books) {
      if (_normalizeBookName(book.name) == normalized) {
        return book;
      }
    }
    return null;
  }

  static String _normalizeBookName(String name) {
    final String normalized = name.trim().toLowerCase();
    return normalized == 'psalm' ? 'psalms' : normalized;
  }

  final Map<String, BiblePassage> _cache = <String, BiblePassage>{};

  Future<BiblePassage> fetchPassage(
    String reference, {
    BibleTranslation translation = kingJamesVersion,
  }) async {
    final String normalized = reference.trim();
    if (normalized.isEmpty) {
      throw const BibleServiceException('Enter a Bible reference.');
    }

    final String cacheKey = '${translation.code}:${normalized.toLowerCase()}';
    final BiblePassage? cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final Uri uri = Uri.parse(
      'https://bible-api.com/${Uri.encodeComponent(normalized)}?translation=${translation.code}',
    );
    final http.Response response = await http.get(uri);

    if (response.statusCode != 200) {
      throw const BibleServiceException('That passage could not be loaded.');
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    if (body['error'] != null) {
      throw BibleServiceException(body['error'].toString());
    }

    final List<dynamic> rawVerses =
        body['verses'] as List<dynamic>? ?? const <dynamic>[];
    final BiblePassage passage = BiblePassage(
      reference: body['reference']?.toString() ?? normalized,
      translation: translation,
      verses: rawVerses.map((dynamic item) {
        final Map<String, dynamic> verse = item as Map<String, dynamic>;
        return BibleVerse(
          bookName: verse['book_name']?.toString(),
          chapter: verse['chapter'] as int?,
          verse: verse['verse'] as int,
          text: verse['text']?.toString().trim() ?? '',
        );
      }).toList(),
    );

    _cache[cacheKey] = passage;
    return passage;
  }
}

class BibleServiceException implements Exception {
  final String message;

  const BibleServiceException(this.message);

  @override
  String toString() => message;
}
