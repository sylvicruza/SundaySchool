import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/curriculum.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _manualAssetPath =
      'assets/data/bible_study_manual_2026.md';
  static const String _studiedLessonsKey = 'studied_lessons';
  static const String _bookmarkedLessonsKey = 'bookmarked_lessons';
  static const String _reflectionNotesKey = 'reflection_notes';
  static const String _savedBiblePassagesKey = 'saved_bible_passages';
  static const String _savedBibleVersesKey = 'saved_bible_verses';
  static const String _lastLessonStateKey = 'last_opened_lesson';
  static const String _lastBibleStateKey = 'last_opened_bible';

  SharedPreferences? _prefs;
  CurriculumData? curriculum;
  String? curriculumLoadError;

  Future<void> init() async {
    await _ensurePrefs();
    await _loadCurriculum();
  }

  Future<void> reloadCurriculum() async {
    await _loadCurriculum();
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadCurriculum() async {
    curriculumLoadError = null;

    try {
      final ByteData data = await rootBundle.load(_manualAssetPath);
      final String raw =
          utf8.decode(data.buffer.asUint8List(), allowMalformed: true);
      final CurriculumData parsed = _parseMarkdown(raw);

      if (parsed.months.isEmpty) {
        curriculumLoadError = 'Manual loaded, but no months were parsed.';
        curriculum = _buildTopicFallback(raw);
        return;
      }

      curriculum = parsed;
    } catch (e, stackTrace) {
      curriculumLoadError = 'Failed to load $_manualAssetPath: $e';
      debugPrint(curriculumLoadError);
      debugPrintStack(stackTrace: stackTrace);
      curriculum = CurriculumData(months: <MonthData>[]);
    }
  }

  CurriculumData _parseMarkdown(String content) {
    final List<MonthData> months = <MonthData>[];
    final RegExp monthPattern = RegExp(
      r'^##\s+(February|March|April|May|June|July|August|September|October|November|December)\s*$',
      multiLine: true,
    );

    final List<RegExpMatch> monthMatches =
        monthPattern.allMatches(content).toList();

    for (int i = 0; i < monthMatches.length; i++) {
      final RegExpMatch match = monthMatches[i];
      final String monthName = _cleanText(match.group(1)!.trim());
      final int start = match.end;
      final int end = i + 1 < monthMatches.length
          ? monthMatches[i + 1].start
          : content.length;
      final String section = content.substring(start, end).trim();

      final String topic = _cleanText(
        _extractSingleLine(
          section,
          RegExp(r'^###\s+TOPIC:\s*(.+)$', multiLine: true),
        ),
      );
      final String memoryVerse =
          _extractMultilineField(section, 'MEMORY VERSE');
      final String centralTruth =
          _extractMultilineField(section, 'CENTRAL TRUTH');
      final List<String> learningObjectives =
          _extractBulletSection(section, '#### Learning Objectives');
      final String introduction = _extractParagraphSection(
        section,
        const <String>[
          '#### lntroducing the Lesson',
          '#### Introducing The Lesson',
        ],
        '#### ',
      );
      final List<LessonOutline> outlines = _extractLessonOutline(section);
      final List<LessonData> lessons = _reconcileLessonDates(
        _extractLessons(section),
        outlines,
      );
      final List<LessonData> normalizedLessons =
          monthName == 'May' ? _fixMayLessonDates(lessons) : lessons;

      months.add(
        MonthData(
          month: monthName,
          topic: topic,
          memoryVerse: memoryVerse,
          centralTruth: centralTruth,
          lessonOutlines: outlines,
          lessons: normalizedLessons,
          learningObjectives: learningObjectives,
          introduction: introduction,
        ),
      );
    }

    return CurriculumData(months: months);
  }

  CurriculumData _buildTopicFallback(String content) {
    final List<MonthData> months = <MonthData>[];
    final RegExp rowPattern = RegExp(
      r'^\|\s*(February|March|April|May|June|July|August|September|October|November|December)\s*\|\s*(.+?)\s*\|$',
      multiLine: true,
    );

    for (final RegExpMatch match in rowPattern.allMatches(content)) {
      months.add(
        MonthData(
          month: _cleanText(match.group(1)!.trim()),
          topic: _cleanText(match.group(2)!.trim()),
          memoryVerse: '',
          centralTruth: '',
          lessonOutlines: <LessonOutline>[],
          lessons: <LessonData>[],
          learningObjectives: <String>[],
          introduction: '',
        ),
      );
    }

    return CurriculumData(months: months);
  }

  String _extractSingleLine(String section, RegExp pattern) {
    final Match? match = pattern.firstMatch(section);
    return match == null ? '' : match.group(1)!.trim();
  }

  String _extractMultilineField(String section, String label) {
    final String normalizedLabel = label.replaceAll("'", r"['â€™]");
    final RegExp pattern = RegExp(
      '^\\*\\*?$normalizedLabel[^\\n]*?[:\\-]\\s*(.+?)(?=^\\*\\*?|^####|^##|\\Z)',
      multiLine: true,
      dotAll: true,
      caseSensitive: false,
    );
    final Match? match = pattern.firstMatch(section);
    if (match == null) {
      return _extractWrappedField(section, label);
    }

    final String value = _cleanText(
      match
          .group(1)!
          .replaceAll('\r', ' ')
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim(),
    );
    return value.isEmpty ? _extractWrappedField(section, label) : value;
  }

  String _extractWrappedField(String section, String label) {
    final RegExp labelPattern = RegExp(
      '^\\*\\*?$label[^\\n]*?[:\\-]\\s*(.*)\$',
      multiLine: true,
      caseSensitive: false,
    );
    final Match? match = labelPattern.firstMatch(section);
    if (match == null) {
      return '';
    }

    final int start = match.end;
    final StringBuffer buffer = StringBuffer(match.group(1) ?? '');

    for (final String rawLine in section.substring(start).split('\n')) {
      final String line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }
      if (line.startsWith('####') ||
          line.startsWith('##') ||
          line.startsWith('**')) {
        break;
      }
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(line);
    }

    return _cleanText(buffer.toString());
  }

  List<LessonData> _reconcileLessonDates(
    List<LessonData> lessons,
    List<LessonOutline> outlines,
  ) {
    if (lessons.isEmpty || outlines.isEmpty) {
      return lessons;
    }

    final int count =
        lessons.length < outlines.length ? lessons.length : outlines.length;
    final List<LessonData> normalized = <LessonData>[];

    for (int i = 0; i < count; i++) {
      final LessonData lesson = lessons[i];
      final LessonOutline outline = outlines[i];
      final String cleanedOutlineDate = _cleanOutlineDate(outline.date);
      normalized.add(
        LessonData(
          dateTitle: cleanedOutlineDate.isEmpty
              ? lesson.dateTitle
              : '${_stripTrailingDate(lesson.dateTitle)} $cleanedOutlineDate',
          content: lesson.content,
        ),
      );
    }

    if (lessons.length > count) {
      normalized.addAll(lessons.skip(count));
    }

    return normalized;
  }

  String _cleanOutlineDate(String rawDate) {
    final Match? match = RegExp(
      r'(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2}(?:st|nd|rd|th)?',
      caseSensitive: false,
    ).firstMatch(rawDate);
    return match == null ? '' : _cleanText(match.group(0)!.trim());
  }

  String _stripTrailingDate(String title) {
    final RegExp trailingDatePattern = RegExp(
      r'\s+(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2}(?:st|nd|rd|th)?$',
      caseSensitive: false,
    );
    return title.replaceFirst(trailingDatePattern, '').trimRight();
  }

  List<LessonData> _fixMayLessonDates(List<LessonData> lessons) {
    if (lessons.length < 4) {
      return lessons;
    }

    final List<String> expectedDates = <String>[
      'May 10',
      'May 17',
      'May 24',
      'May 31',
    ];

    final List<LessonData> fixed = <LessonData>[];
    for (int i = 0; i < lessons.length; i++) {
      if (i >= expectedDates.length) {
        fixed.add(lessons[i]);
        continue;
      }

      fixed.add(
        LessonData(
          dateTitle:
              '${_stripTrailingDate(lessons[i].dateTitle)} ${expectedDates[i]}',
          content: lessons[i].content,
        ),
      );
    }

    return fixed;
  }

  List<String> _extractBulletSection(String section, String heading) {
    final String body = _extractSectionBody(section, heading, '#### ');
    if (body.isEmpty) {
      return <String>[];
    }

    return body
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.startsWith('- '))
        .map((String line) => _cleanText(line.replaceFirst('- ', '').trim()))
        .toList();
  }

  String _extractParagraphSection(
    String section,
    List<String> headings,
    String endPrefix,
  ) {
    for (final String heading in headings) {
      final String body = _extractSectionBody(section, heading, endPrefix);
      if (body.isNotEmpty) {
        return _cleanMarkdown(body.trim());
      }
    }
    return '';
  }

  String _extractSectionBody(
    String section,
    String heading,
    String nextHeadingPrefix,
  ) {
    final int startIndex = section.indexOf(heading);
    if (startIndex == -1) {
      return '';
    }

    final int contentStart = startIndex + heading.length;
    final String remainder = section.substring(contentStart).trimLeft();
    final int nextIndex = remainder.indexOf(nextHeadingPrefix);
    return (nextIndex == -1 ? remainder : remainder.substring(0, nextIndex))
        .trim();
  }

  List<LessonOutline> _extractLessonOutline(String section) {
    final String body =
        _extractSectionBody(section, '#### The Lesson Outline', '#### ');
    if (body.isEmpty) {
      return <LessonOutline>[];
    }

    final List<LessonOutline> outlines = <LessonOutline>[];
    String? currentDate;
    String? currentTitle;
    List<String> currentDetails = <String>[];

    for (final String rawLine in body.split('\n')) {
      final String line = rawLine.trim();
      if (!line.startsWith('- ')) {
        continue;
      }

      final String bullet = line.replaceFirst('- ', '').trim();
      final Match? headingMatch = RegExp(r'^(.+?):\s*(.+)$').firstMatch(bullet);

      if (headingMatch != null &&
          RegExp(r'\d').hasMatch(headingMatch.group(1)!)) {
        if (currentTitle != null) {
          outlines.add(
            LessonOutline(currentDate ?? '', currentTitle, currentDetails),
          );
        }
        currentDate = _cleanText(headingMatch.group(1)!.trim());
        currentTitle = _cleanText(headingMatch.group(2)!.trim());
        currentDetails = <String>[];
      } else if (currentTitle != null) {
        currentDetails.add(_cleanText(bullet));
      }
    }

    if (currentTitle != null) {
      outlines
          .add(LessonOutline(currentDate ?? '', currentTitle, currentDetails));
    }

    return outlines;
  }

  List<LessonData> _extractLessons(String section) {
    final List<LessonData> lessons = <LessonData>[];
    final RegExp lessonHeaderPattern = RegExp(
      r'^####\s+(?!The Lesson Outline|Learning Objectives|lntroducing the Lesson|Introducing The Lesson|Questions?\b)(.+)$',
      multiLine: true,
    );

    final List<RegExpMatch> matches =
        lessonHeaderPattern.allMatches(section).toList();
    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches[i];
      final String title = _cleanText(match.group(1)!.trim());
      final int start = match.end;
      final int end =
          i + 1 < matches.length ? matches[i + 1].start : section.length;
      final String body = _cleanMarkdown(section.substring(start, end).trim());
      lessons.add(LessonData(dateTitle: title, content: body));
    }

    return lessons;
  }

  String _cleanMarkdown(String value) {
    return _cleanText(value).replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  String _cleanText(String value) {
    return value
        .replaceAll('**', '')
        .replaceAll('Ã¢â‚¬â„¢', "'")
        .replaceAll('Ã¢â‚¬Ëœ', "'")
        .replaceAll('Ã¢â‚¬Å“', '"')
        .replaceAll('Ã¢â‚¬Â', '"')
        .replaceAll('Ã¢â‚¬â€œ', '-')
        .replaceAll('Ã¢â‚¬â€', '-')
        .replaceAll('Ã¢â‚¬Â¢', 'â€¢')
        .replaceAll('ÃƒÂ¥', 'a')
        .replaceAll('AImighty', 'Almighty')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(' .', '.')
        .trim();
  }

  Set<String> getStudiedLessons() {
    return (_prefs?.getStringList(_studiedLessonsKey) ?? const <String>[])
        .toSet();
  }

  bool isLessonStudied(LessonData lesson) {
    return getStudiedLessons().contains(lessonKey(lesson));
  }

  Future<bool> toggleLessonStudied(LessonData lesson) async {
    await _ensurePrefs();
    final Set<String> studied = getStudiedLessons();
    final String key = lessonKey(lesson);

    if (studied.contains(key)) {
      studied.remove(key);
    } else {
      studied.add(key);
    }

    await _prefs!.setStringList(_studiedLessonsKey, studied.toList());
    return studied.contains(key);
  }

  Set<String> getBookmarkedLessons() {
    return (_prefs?.getStringList(_bookmarkedLessonsKey) ?? const <String>[])
        .toSet();
  }

  bool isLessonBookmarked(LessonData lesson) {
    return getBookmarkedLessons().contains(lessonKey(lesson));
  }

  Future<bool> toggleLessonBookmark(LessonData lesson) async {
    await _ensurePrefs();
    final Set<String> bookmarked = getBookmarkedLessons();
    final String key = lessonKey(lesson);

    if (bookmarked.contains(key)) {
      bookmarked.remove(key);
    } else {
      bookmarked.add(key);
    }

    await _prefs!.setStringList(_bookmarkedLessonsKey, bookmarked.toList());
    return bookmarked.contains(key);
  }

  List<ReflectionNote> getReflections() {
    final String? notesJson = _prefs?.getString(_reflectionNotesKey);
    if (notesJson == null || notesJson.isEmpty) {
      return <ReflectionNote>[];
    }

    try {
      final Iterable<dynamic> decoded =
          json.decode(notesJson) as Iterable<dynamic>;
      return decoded
          .map(
            (dynamic item) =>
                ReflectionNote.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return <ReflectionNote>[];
    }
  }

  Future<void> saveReflection(ReflectionNote note) async {
    await _ensurePrefs();
    final List<ReflectionNote> list = getReflections()
      ..removeWhere((ReflectionNote item) => item.id == note.id);
    list.insert(0, note);
    await _prefs!.setString(
      _reflectionNotesKey,
      json.encode(list.map((ReflectionNote e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteReflection(String id) async {
    await _ensurePrefs();
    final List<ReflectionNote> list = getReflections()
      ..removeWhere((ReflectionNote item) => item.id == id);
    await _prefs!.setString(
      _reflectionNotesKey,
      json.encode(list.map((ReflectionNote e) => e.toJson()).toList()),
    );
  }

  Future<void> saveLastOpenedLesson({
    required MonthData month,
    required LessonData lesson,
  }) async {
    await _ensurePrefs();
    final LastOpenedLessonState state = LastOpenedLessonState(
      month: month.month,
      lessonTitle: lesson.dateTitle,
    );
    await _prefs!.setString(_lastLessonStateKey, json.encode(state.toJson()));
  }

  LastOpenedLessonState? getLastOpenedLessonState() {
    final String? raw = _prefs?.getString(_lastLessonStateKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return LastOpenedLessonState.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  ResolvedLessonLocation? resolveLastOpenedLesson() {
    final CurriculumData? currentCurriculum = curriculum;
    final LastOpenedLessonState? state = getLastOpenedLessonState();
    if (currentCurriculum == null || state == null) {
      return null;
    }

    for (final MonthData month in currentCurriculum.months) {
      if (month.month.toLowerCase() != state.month.toLowerCase()) {
        continue;
      }

      for (int i = 0; i < month.lessons.length; i++) {
        final LessonData lesson = month.lessons[i];
        if (lesson.dateTitle.toLowerCase() == state.lessonTitle.toLowerCase()) {
          return ResolvedLessonLocation(
            month: month,
            lesson: lesson,
            lessonIndex: i,
          );
        }
      }
    }

    return null;
  }

  Future<void> saveLastOpenedBibleState(LastOpenedBibleState state) async {
    await _ensurePrefs();
    await _prefs!.setString(_lastBibleStateKey, json.encode(state.toJson()));
  }

  LastOpenedBibleState? getLastOpenedBibleState() {
    final String? raw = _prefs?.getString(_lastBibleStateKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return LastOpenedBibleState.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  List<SavedBiblePassage> getSavedBiblePassages() {
    final String? raw = _prefs?.getString(_savedBiblePassagesKey);
    if (raw == null || raw.isEmpty) {
      return <SavedBiblePassage>[];
    }

    try {
      final Iterable<dynamic> decoded =
          json.decode(raw) as Iterable<dynamic>;
      return decoded
          .map(
            (dynamic item) =>
                SavedBiblePassage.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return <SavedBiblePassage>[];
    }
  }

  Future<bool> toggleSavedBiblePassage(SavedBiblePassage passage) async {
    await _ensurePrefs();
    final List<SavedBiblePassage> passages = getSavedBiblePassages();
    final int index =
        passages.indexWhere((SavedBiblePassage item) => item.key == passage.key);

    final bool isSaved;
    if (index >= 0) {
      passages.removeAt(index);
      isSaved = false;
    } else {
      passages.insert(0, passage);
      isSaved = true;
    }

    await _prefs!.setString(
      _savedBiblePassagesKey,
      json.encode(passages.map((SavedBiblePassage item) => item.toJson()).toList()),
    );
    return isSaved;
  }

  List<SavedBibleVerse> getSavedBibleVerses() {
    final String? raw = _prefs?.getString(_savedBibleVersesKey);
    if (raw == null || raw.isEmpty) {
      return <SavedBibleVerse>[];
    }

    try {
      final Iterable<dynamic> decoded =
          json.decode(raw) as Iterable<dynamic>;
      return decoded
          .map(
            (dynamic item) =>
                SavedBibleVerse.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return <SavedBibleVerse>[];
    }
  }

  Future<bool> toggleSavedBibleVerse(SavedBibleVerse verse) async {
    await _ensurePrefs();
    final List<SavedBibleVerse> verses = getSavedBibleVerses();
    final int index =
        verses.indexWhere((SavedBibleVerse item) => item.key == verse.key);

    final bool isSaved;
    if (index >= 0) {
      verses.removeAt(index);
      isSaved = false;
    } else {
      verses.insert(0, verse);
      isSaved = true;
    }

    await _prefs!.setString(
      _savedBibleVersesKey,
      json.encode(verses.map((SavedBibleVerse item) => item.toJson()).toList()),
    );
    return isSaved;
  }

  String lessonKey(LessonData lesson) {
    return lesson.dateTitle.trim().toLowerCase();
  }
}
