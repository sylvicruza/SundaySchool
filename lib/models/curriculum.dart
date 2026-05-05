class CurriculumData {
  final List<MonthData> months;

  CurriculumData({required this.months});
}

class MonthData {
  final String month;
  final String topic;
  final String memoryVerse;
  final String centralTruth;
  final List<LessonOutline> lessonOutlines;
  final List<LessonData> lessons;

  final List<String> learningObjectives;
  final String introduction;

  MonthData({
    required this.month,
    required this.topic,
    required this.memoryVerse,
    required this.centralTruth,
    required this.lessonOutlines,
    required this.lessons,
    required this.learningObjectives,
    required this.introduction,
  });
}

class LessonOutline {
  final String date;
  final String title;
  final List<String> details;

  LessonOutline(this.date, this.title, this.details);
}

class LessonData {
  final String dateTitle; // e.g. "Be Born of the Spirit February 8th"
  final String content; // full markdown for that lesson

  LessonData({required this.dateTitle, required this.content});

  Map<String, dynamic> toJson() => {
        'dateTitle': dateTitle,
        'content': content,
      };

  factory LessonData.fromJson(Map<String, dynamic> json) => LessonData(
        dateTitle: json['dateTitle'],
        content: json['content'],
      );
}

class ReflectionNote {
  final String id;
  final String title;
  final String type; // 'personal', 'standard', etc.
  final String content;
  final DateTime date;

  ReflectionNote({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'content': content,
        'date': date.toIso8601String(),
      };

  factory ReflectionNote.fromJson(Map<String, dynamic> json) => ReflectionNote(
        id: json['id'],
        title: json['title'],
        type: json['type'],
        content: json['content'],
        date: DateTime.parse(json['date']),
      );
}

class LastOpenedLessonState {
  final String month;
  final String lessonTitle;

  const LastOpenedLessonState({
    required this.month,
    required this.lessonTitle,
  });

  Map<String, dynamic> toJson() => {
        'month': month,
        'lessonTitle': lessonTitle,
      };

  factory LastOpenedLessonState.fromJson(Map<String, dynamic> json) =>
      LastOpenedLessonState(
        month: json['month'],
        lessonTitle: json['lessonTitle'],
      );
}

class LastOpenedBibleState {
  final String reference;
  final String translationCode;
  final String bookName;
  final int chapter;

  const LastOpenedBibleState({
    required this.reference,
    required this.translationCode,
    required this.bookName,
    required this.chapter,
  });

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'translationCode': translationCode,
        'bookName': bookName,
        'chapter': chapter,
      };

  factory LastOpenedBibleState.fromJson(Map<String, dynamic> json) =>
      LastOpenedBibleState(
        reference: json['reference'],
        translationCode: json['translationCode'],
        bookName: json['bookName'],
        chapter: json['chapter'],
      );
}

class SavedBibleVerse {
  final String key;
  final String reference;
  final String translationCode;
  final String translationName;
  final String translationShortName;
  final String text;
  final DateTime savedAt;

  const SavedBibleVerse({
    required this.key,
    required this.reference,
    required this.translationCode,
    required this.translationName,
    required this.translationShortName,
    required this.text,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'reference': reference,
        'translationCode': translationCode,
        'translationName': translationName,
        'translationShortName': translationShortName,
        'text': text,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedBibleVerse.fromJson(Map<String, dynamic> json) =>
      SavedBibleVerse(
        key: json['key'],
        reference: json['reference'],
        translationCode: json['translationCode'],
        translationName: json['translationName'],
        translationShortName: json['translationShortName'],
        text: json['text'],
        savedAt: DateTime.parse(json['savedAt']),
      );
}

class SavedBiblePassageVerse {
  final String? bookName;
  final int? chapter;
  final int verse;
  final String text;

  const SavedBiblePassageVerse({
    this.bookName,
    this.chapter,
    required this.verse,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'bookName': bookName,
        'chapter': chapter,
        'verse': verse,
        'text': text,
      };

  factory SavedBiblePassageVerse.fromJson(Map<String, dynamic> json) =>
      SavedBiblePassageVerse(
        bookName: json['bookName'],
        chapter: json['chapter'],
        verse: json['verse'],
        text: json['text'],
      );
}

class SavedBiblePassage {
  final String key;
  final String reference;
  final String translationCode;
  final String translationName;
  final String translationShortName;
  final List<SavedBiblePassageVerse> verses;
  final DateTime savedAt;

  const SavedBiblePassage({
    required this.key,
    required this.reference,
    required this.translationCode,
    required this.translationName,
    required this.translationShortName,
    required this.verses,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'reference': reference,
        'translationCode': translationCode,
        'translationName': translationName,
        'translationShortName': translationShortName,
        'verses': verses.map((verse) => verse.toJson()).toList(),
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedBiblePassage.fromJson(Map<String, dynamic> json) =>
      SavedBiblePassage(
        key: json['key'],
        reference: json['reference'],
        translationCode: json['translationCode'],
        translationName: json['translationName'],
        translationShortName: json['translationShortName'],
        verses: (json['verses'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic item) => SavedBiblePassageVerse.fromJson(
                item as Map<String, dynamic>))
            .toList(),
        savedAt: DateTime.parse(json['savedAt']),
      );
}

class ResolvedLessonLocation {
  final MonthData month;
  final LessonData lesson;
  final int lessonIndex;

  const ResolvedLessonLocation({
    required this.month,
    required this.lesson,
    required this.lessonIndex,
  });
}
