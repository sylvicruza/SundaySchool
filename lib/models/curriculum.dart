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
}

class PrayerRequest {
  final String id;
  final String category;
  final String request;
  final String urgency;
  final bool isAnonymous;
  final DateTime date;

  PrayerRequest({
    required this.id,
    required this.category,
    required this.request,
    required this.urgency,
    required this.isAnonymous,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'request': request,
        'urgency': urgency,
        'isAnonymous': isAnonymous,
        'date': date.toIso8601String(),
      };

  factory PrayerRequest.fromJson(Map<String, dynamic> json) => PrayerRequest(
        id: json['id'],
        category: json['category'],
        request: json['request'],
        urgency: json['urgency'],
        isAnonymous: json['isAnonymous'],
        date: DateTime.parse(json['date']),
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
