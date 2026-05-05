import 'package:faithfoundation/models/curriculum.dart';
import 'package:faithfoundation/screens/onboarding_screen.dart';
import 'package:faithfoundation/screens/sunday_school_screen.dart';
import 'package:faithfoundation/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await DataService().init();
  });

  testWidgets('parses May central truth and corrected study lesson dates', (
    WidgetTester tester,
  ) async {
    await DataService().reloadCurriculum();

    final MonthData may = DataService().curriculum!.months.firstWhere(
      (MonthData month) => month.month == 'May',
    );

    expect(
      may.centralTruth,
      'Though people are mortal, they can have everlasting life through Jesus Christ.',
    );
    expect(
      may.lessons.map((LessonData lesson) => lesson.dateTitle).toList(),
      <String>[
        'Our Everlasting God May 10',
        'God is not Subject to Time May 17',
        'Human Frailty and Sinfulness May 24',
        'God Rewards Kingdom Work May 31',
      ],
    );
  });

  testWidgets('persists reflections in the data service', (
    WidgetTester tester,
  ) async {
    final ReflectionNote note = ReflectionNote(
      id: 'reflection-1',
      title: 'John 2',
      type: 'scripture',
      content: 'Jesus was there.',
      date: DateTime(2026, 5, 5),
    );

    await DataService().saveReflection(note);

    final List<ReflectionNote> notes = DataService().getReflections();
    expect(notes.any((ReflectionNote item) => item.id == 'reflection-1'), isTrue);
  });

  testWidgets('filters Sunday School months from the search box', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SundaySchoolScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Sinfulness',
    );
    await tester.pumpAndSettle();

    expect(find.text('May'), findsOneWidget);
    expect(find.text('February'), findsNothing);
  });

  testWidgets('shows onboarding content and opens the main app shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    expect(find.text('Faith Foundations Manual'), findsOneWidget);
    expect(find.text('Open Sunday School App'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Bible'), findsWidgets);
  });
}
