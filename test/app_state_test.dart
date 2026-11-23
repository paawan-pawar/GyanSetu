import 'package:flutter_test/flutter_test.dart';
import 'package:major/core/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> freshState([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final s = AppState();
  await s.load();
  return s;
}

void main() {
  test('defaults: English, not onboarded, no progress', () async {
    final s = await freshState();
    expect(s.lang, 'en');
    expect(s.onboarded, isFalse);
    expect(s.completedLessons, isEmpty);
    expect(s.streak, 0);
  });

  test('profile and language are saved and restored', () async {
    final s = await freshState();
    s.setLang('hi');
    s.saveProfile(name: 'Ravi', village: 'Sitapur', role: 'farmer');
    final restored = AppState();
    await restored.load();
    expect(restored.lang, 'hi');
    expect(restored.onboarded, isTrue);
    expect(restored.userName, 'Ravi');
    expect(restored.role, 'farmer');
  });

  test('lesson completion toggles and is counted per course', () async {
    final s = await freshState();
    s.toggleLesson('c_lit_1', 'l1');
    s.completeLesson('c_lit_1', 'l2');
    s.completeLesson('c_math_1', 'l1');
    expect(s.doneCount('c_lit_1'), 2);
    s.toggleLesson('c_lit_1', 'l1');
    expect(s.isLessonDone('c_lit_1', 'l1'), isFalse);
    expect(s.doneCount('c_lit_1'), 1);
  });

  test('quiz keeps only the best score', () async {
    final s = await freshState();
    s.recordQuiz('c_lit_1', 67);
    s.recordQuiz('c_lit_1', 33);
    expect(s.quizScores['c_lit_1'], 67);
    s.recordQuiz('c_lit_1', 100);
    expect(s.quizScores['c_lit_1'], 100);
  });

  test('learning activity today starts a 1-day streak', () async {
    final s = await freshState();
    s.completeLesson('c_lit_1', 'l1');
    expect(s.streak, 1);
  });

  test('applications, bookings and requests are stored', () async {
    final s = await freshState();
    s.applyJob('j1');
    s.applyJob('j1');
    s.requestResource('res1');
    s.toggleScheme('s1');
    s.addBooking({'mentor': 'm1', 'slot': '10:00 AM'});
    expect(s.appliedJobs, {'j1'});
    expect(s.requestedResources, {'res1'});
    expect(s.savedSchemes, {'s1'});
    expect(s.bookings.length, 1);
    s.toggleScheme('s1');
    expect(s.savedSchemes, isEmpty);
  });

  test('reset clears progress but keeps the chosen language', () async {
    final s = await freshState();
    s.setLang('hi');
    s.saveProfile(name: 'Asha', village: 'Rampur', role: 'student');
    s.completeLesson('c_lit_1', 'l1');
    await s.resetAll();
    expect(s.onboarded, isFalse);
    expect(s.completedLessons, isEmpty);
    expect(s.lang, 'hi');
  });
}
