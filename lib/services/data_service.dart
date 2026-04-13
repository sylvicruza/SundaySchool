import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/curriculum.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _manualAssetPath = 'assets/data/bible_study_manual_2026.md';
  static const String _studiedLessonsKey = 'studied_lessons';
  static const String _bookmarkedLessonsKey = 'bookmarked_lessons';

  final Map<String, Object> _store = <String, Object>{};
  CurriculumData? curriculum;
  String? curriculumLoadError;

  Future<void> init() async {
    await _loadCurriculum();
  }

  Future<void> reloadCurriculum() async {
    await _loadCurriculum();
  }

  Future<void> _loadCurriculum() async {
    curriculumLoadError = null;

    try {
      final ByteData data = await rootBundle.load(_manualAssetPath);
      final String raw = utf8.decode(data.buffer.asUint8List(), allowMalformed: true);
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

    final List<RegExpMatch> monthMatches = monthPattern.allMatches(content).toList();

    for (int i = 0; i < monthMatches.length; i++) {
      final RegExpMatch match = monthMatches[i];
      final String monthName = _cleanText(match.group(1)!.trim());
      final int start = match.end;
      final int end = i + 1 < monthMatches.length ? monthMatches[i + 1].start : content.length;
      final String section = content.substring(start, end).trim();

      final String topic = _cleanText(
        _extractSingleLine(section, RegExp(r'^###\s+TOPIC:\s*(.+)$', multiLine: true)),
      );
      final String memoryVerse = _extractMultilineField(section, 'MEMORY VERSE');
      final String centralTruth = _extractMultilineField(section, 'CENTRAL TRUTH');
      final List<String> learningObjectives = _extractBulletSection(section, '#### Learning Objectives');
      final String introduction = _extractParagraphSection(
        section,
        const <String>['#### lntroducing the Lesson', '#### Introducing The Lesson'],
        '#### ',
      );
      final List<LessonOutline> outlines = _extractLessonOutline(section);
      final List<LessonData> lessons = _extractLessons(section);

      months.add(
        MonthData(
          month: monthName,
          topic: topic,
          memoryVerse: memoryVerse,
          centralTruth: centralTruth,
          lessonOutlines: outlines,
          lessons: lessons,
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
    final String normalizedLabel = label.replaceAll("'", r"['’]");
    final RegExp pattern = RegExp(
      '^\\*\\*?$normalizedLabel[^\\n]*?[:\\-]\\s*(.+?)(?=^\\*\\*?|^####|^##|\\Z)',
      multiLine: true,
      dotAll: true,
      caseSensitive: false,
    );
    final Match? match = pattern.firstMatch(section);
    if (match == null) {
      return '';
    }

    return _cleanText(
      match.group(1)!.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
    );
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

  String _extractParagraphSection(String section, List<String> headings, String endPrefix) {
    for (final String heading in headings) {
      final String body = _extractSectionBody(section, heading, endPrefix);
      if (body.isNotEmpty) {
        return _cleanMarkdown(body.trim());
      }
    }
    return '';
  }

  String _extractSectionBody(String section, String heading, String nextHeadingPrefix) {
    final int startIndex = section.indexOf(heading);
    if (startIndex == -1) {
      return '';
    }

    final int contentStart = startIndex + heading.length;
    final String remainder = section.substring(contentStart).trimLeft();
    final int nextIndex = remainder.indexOf(nextHeadingPrefix);
    return (nextIndex == -1 ? remainder : remainder.substring(0, nextIndex)).trim();
  }

  List<LessonOutline> _extractLessonOutline(String section) {
    final String body = _extractSectionBody(section, '#### The Lesson Outline', '#### ');
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

      if (headingMatch != null && RegExp(r'\d').hasMatch(headingMatch.group(1)!)) {
        if (currentTitle != null) {
          outlines.add(LessonOutline(currentDate ?? '', currentTitle, currentDetails));
        }
        currentDate = _cleanText(headingMatch.group(1)!.trim());
        currentTitle = _cleanText(headingMatch.group(2)!.trim());
        currentDetails = <String>[];
      } else if (currentTitle != null) {
        currentDetails.add(_cleanText(bullet));
      }
    }

    if (currentTitle != null) {
      outlines.add(LessonOutline(currentDate ?? '', currentTitle, currentDetails));
    }

    return outlines;
  }

  List<LessonData> _extractLessons(String section) {
    final List<LessonData> lessons = <LessonData>[];
    final RegExp lessonHeaderPattern = RegExp(
      r'^####\s+(?!The Lesson Outline|Learning Objectives|lntroducing the Lesson|Introducing The Lesson|Questions?\b)(.+)$',
      multiLine: true,
    );

    final List<RegExpMatch> matches = lessonHeaderPattern.allMatches(section).toList();
    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches[i];
      final String title = _cleanText(match.group(1)!.trim());
      final int start = match.end;
      final int end = i + 1 < matches.length ? matches[i + 1].start : section.length;
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
        .replaceAll('â€™', "'")
        .replaceAll('â€˜', "'")
        .replaceAll('â€œ', '"')
        .replaceAll('â€', '"')
        .replaceAll('â€“', '-')
        .replaceAll('â€”', '-')
        .replaceAll('â€¢', '•')
        .replaceAll('Ã¥', 'a')
        .replaceAll('AImighty', 'Almighty')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(' .', '.')
        .trim();
  }

  List<PrayerRequest> getPrayerRequests() {
    final String? prayersJson = _store['prayer_requests'] as String?;
    if (prayersJson == null) {
      return <PrayerRequest>[];
    }

    try {
      final Iterable<dynamic> decoded = json.decode(prayersJson) as Iterable<dynamic>;
      return decoded
          .map((dynamic item) => PrayerRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <PrayerRequest>[];
    }
  }

  Future<void> savePrayerRequest(PrayerRequest request) async {
    final List<PrayerRequest> list = getPrayerRequests();
    list.insert(0, request);
    _store['prayer_requests'] = json.encode(
      list.map((PrayerRequest e) => e.toJson()).toList(),
    );
  }

  List<ReflectionNote> getReflections() {
    final String? notesJson = _store['reflection_notes'] as String?;
    if (notesJson == null) {
      return <ReflectionNote>[];
    }

    try {
      final Iterable<dynamic> decoded = json.decode(notesJson) as Iterable<dynamic>;
      return decoded
          .map((dynamic item) => ReflectionNote.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <ReflectionNote>[];
    }
  }

  Future<void> saveReflection(ReflectionNote note) async {
    final List<ReflectionNote> list = getReflections();
    list.insert(0, note);
    _store['reflection_notes'] = json.encode(
      list.map((ReflectionNote e) => e.toJson()).toList(),
    );
  }

  String lessonKey(LessonData lesson) {
    return lesson.dateTitle.trim().toLowerCase();
  }

  Set<String> getStudiedLessons() {
    return List<String>.from(_store[_studiedLessonsKey] as List<String>? ?? const <String>[])
        .toSet();
  }

  bool isLessonStudied(LessonData lesson) {
    return getStudiedLessons().contains(lessonKey(lesson));
  }

  Future<bool> toggleLessonStudied(LessonData lesson) async {
    final Set<String> studied = getStudiedLessons();
    final String key = lessonKey(lesson);

    if (studied.contains(key)) {
      studied.remove(key);
    } else {
      studied.add(key);
    }

    _store[_studiedLessonsKey] = studied.toList();
    return studied.contains(key);
  }

  Set<String> getBookmarkedLessons() {
    return List<String>.from(_store[_bookmarkedLessonsKey] as List<String>? ?? const <String>[])
        .toSet();
  }

  bool isLessonBookmarked(LessonData lesson) {
    return getBookmarkedLessons().contains(lessonKey(lesson));
  }

  Future<bool> toggleLessonBookmark(LessonData lesson) async {
    final Set<String> bookmarked = getBookmarkedLessons();
    final String key = lessonKey(lesson);

    if (bookmarked.contains(key)) {
      bookmarked.remove(key);
    } else {
      bookmarked.add(key);
    }

    _store[_bookmarkedLessonsKey] = bookmarked.toList();
    return bookmarked.contains(key);
  }
}
