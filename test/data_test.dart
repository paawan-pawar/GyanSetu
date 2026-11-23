import 'package:flutter_test/flutter_test.dart';
import 'package:major/core/data_repository.dart';

/// Walks every JSON value and collects bilingual {"en","hi"} maps.
void collectBilingual(dynamic node, List<Map> out) {
  if (node is Map) {
    if (node.containsKey('en') && node.containsKey('hi')) out.add(node);
    for (final v in node.values) {
      collectBilingual(v, out);
    }
  } else if (node is List) {
    for (final v in node) {
      collectBilingual(v, out);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = DataRepository.instance;
  setUpAll(repo.load);

  test('datasets load with expected sizes', () {
    expect(repo.courses.length, 12);
    expect(repo.categories.length, 7);
    expect(repo.mentors.length, 7);
    expect(repo.schemes.length, 10);
    expect(repo.jobs.length, 10);
    expect(repo.courses.expand((c) => c['lessons'] as List).length, 36);
  });

  test('every bilingual field has non-empty English and Hindi text', () {
    final all = <Map>[];
    for (final list in [
      repo.categories, repo.courses, repo.mentors, repo.schemes, repo.jobs, repo.programs, repo.hotspots,
      repo.dataPacks, repo.projects, repo.surveys, repo.resources, repo.eLibrary, repo.phrases,
      repo.digitalChecklist, repo.safetyTips,
    ]) {
      collectBilingual(list, all);
    }
    expect(all, isNotEmpty);
    for (final m in all) {
      expect((m['en'] as String).trim(), isNotEmpty, reason: '$m');
      expect((m['hi'] as String).trim(), isNotEmpty, reason: '$m');
    }
  });

  test('every course links to a valid category and mentor', () {
    for (final c in repo.courses) {
      expect(repo.categories.any((k) => k['id'] == c['category']), isTrue, reason: c['id']);
      expect(repo.mentor(c['mentorId']), isNotNull, reason: c['id']);
    }
  });

  test('every quiz answer points to an existing option', () {
    for (final c in repo.courses) {
      for (final q in c['quiz'] as List) {
        final answer = q['answer'] as int;
        expect(answer, inInclusiveRange(0, (q['options'] as List).length - 1), reason: c['id']);
      }
    }
  });

  test('every lesson has a video link and a positive duration', () {
    for (final c in repo.courses) {
      for (final l in c['lessons'] as List) {
        expect((l['video'] as String).startsWith('https://'), isTrue);
        expect(l['duration'] as int, greaterThan(0));
      }
    }
  });

  test('scheme, program and e-library links use https', () {
    for (final x in [...repo.schemes, ...repo.programs, ...repo.eLibrary]) {
      expect((x['url'] as String).startsWith('https://'), isTrue, reason: x['id']);
    }
  });
}
