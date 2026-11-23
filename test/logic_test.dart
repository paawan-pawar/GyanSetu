import 'package:flutter_test/flutter_test.dart';
import 'package:major/core/app_state.dart';
import 'package:major/core/data_repository.dart';
import 'package:major/screens/progress_screen.dart';
import 'package:major/screens/schemes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(DataRepository.instance.load);

  group('Loan EMI calculator', () {
    test('Rs 1,00,000 at 12% for 1 year is about Rs 8,885 per month', () {
      expect(monthlyEmi(100000, 12, 1), closeTo(8884.88, 0.01));
    });
    test('zero interest splits the amount equally', () {
      expect(monthlyEmi(120000, 0, 1), 10000);
    });
  });

  group('Scheme eligibility check', () {
    test('low-income student matches scholarships and education loan', () {
      final m = matchSchemes(income: 200000, student: true, farmer: false, business: false);
      expect(m, containsAll(['s1', 's2', 's3', 's7', 's8', 's9']));
      expect(m, isNot(contains('s6')));
    });
    test('higher income excludes PM YASASVI (Rs 2.5 lakh limit)', () {
      final m = matchSchemes(income: 500000, student: true, farmer: false, business: false);
      expect(m, isNot(contains('s2')));
      expect(m, contains('s3'));
    });
    test('farmer who wants a business gets PM-KISAN and MUDRA', () {
      final m = matchSchemes(income: 100000, student: false, farmer: true, business: true);
      expect(m, containsAll(['s6', 's4', 's5', 's10']));
    });
  });

  group('Skill progress', () {
    test('all skills start at 0%', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load();
      expect(computeSkills(s).values.every((v) => v == 0), isTrue);
    });

    test('finishing every reading lesson with 100% quizzes gives 100% reading', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load();
      for (final c in DataRepository.instance.courses.where((c) => c['skill'] == 'reading')) {
        for (final l in c['lessons'] as List) {
          s.completeLesson(c['id'], l['id']);
        }
        s.recordQuiz(c['id'], 100);
      }
      final skills = computeSkills(s);
      expect(skills['reading'], 1.0);
      expect(skills['numeracy'], 0);
    });
  });
}
