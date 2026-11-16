import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'learn/course_detail_screen.dart';

const kSkillColors = {
  'reading': Color(0xFFEF6C00),
  'numeracy': Color(0xFF1E88E5),
  'knowledge': Color(0xFF43A047),
  'communication': Color(0xFF8E24AA),
  'digital': Color(0xFF00897B),
  'vocational': Color(0xFF6D4C41),
  'finance': Color(0xFFC62828),
};

/// Skill level = 70% lesson completion + 30% best quiz score, per skill area.
Map<String, double> computeSkills(AppState s) {
  final repo = DataRepository.instance;
  final result = <String, double>{};
  for (final skill in kSkillColors.keys) {
    final courses = repo.courses.where((c) => c['skill'] == skill).toList();
    int total = 0, done = 0;
    double quiz = 0;
    for (final c in courses) {
      total += (c['lessons'] as List).length;
      done += s.doneCount(c['id']);
      quiz += (s.quizScores[c['id']] ?? 0) / 100;
    }
    final lessonPart = total == 0 ? 0 : done / total;
    final quizPart = courses.isEmpty ? 0 : quiz / courses.length;
    double v = 0.7 * lessonPart + 0.3 * quizPart;
    if (skill == 'digital') {
      // Digital checklist also counts toward digital skills.
      final cl = s.digitalChecklist.length / DataRepository.instance.digitalChecklist.length;
      v = (v + cl) / 2;
    }
    result[skill] = v.clamp(0, 1).toDouble();
  }
  return result;
}

class ProgressScreen extends StatelessWidget {
  final bool standalone;
  const ProgressScreen({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final skills = computeSkills(s);
    final overall = skills.values.reduce((a, b) => a + b) / skills.length;
    final avgQuiz = s.quizScores.isEmpty ? 0 : (s.quizScores.values.reduce((a, b) => a + b) / s.quizScores.length).round();
    final cs = Theme.of(context).colorScheme;

    final certified = repo.courses.where((c) => s.doneCount(c['id']) == (c['lessons'] as List).length && (s.quizScores[c['id']] ?? 0) >= 60).toList();

    final badges = <(String, IconData, bool)>[
      ('b_first_step', Icons.flag_rounded, s.completedLessons.isNotEmpty),
      ('b_reader', Icons.menu_book_rounded, s.completedLessons.length >= 5),
      ('b_quiz_star', Icons.emoji_events_rounded, s.quizScores.values.any((v) => v == 100)),
      ('b_digital', Icons.devices_rounded, s.digitalChecklist.length >= 5),
      ('b_streak', Icons.local_fire_department_rounded, s.streak >= 3),
      ('b_helper', Icons.campaign_rounded, s.surveyAnswers.isNotEmpty || s.ideas.any((i) => i['mine'] == true)),
    ];

    // Last 7 days activity
    final now = DateTime.now();
    final week = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return (d, s.activeDays.contains(key));
    });
    const daysEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const daysHi = ['सो', 'मं', 'बु', 'गु', 'शु', 'श', 'र'];

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: standalone, title: Text(context.tr('progress_title')), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(value: overall, strokeWidth: 11, strokeCap: StrokeCap.round, backgroundColor: cs.primaryContainer),
                        Center(child: Text('${(overall * 100).round()}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('overall'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                        const SizedBox(height: 10),
                        _kv('📘', '${s.completedLessons.length} ${context.tr('lessons_done')}'),
                        _kv('📝', '${s.quizScores.length} ${context.tr('quizzes_taken')} • $avgQuiz% ${context.tr('avg_score')}'),
                        _kv('🔥', '${s.streak} ${context.tr('day_streak')}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionTitle(context.tr('weekly_activity')),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: week.map((e) {
                  final (d, active) = e;
                  return Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 30,
                        height: active ? 54 : 18,
                        decoration: BoxDecoration(color: active ? AppColors.accent : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 6),
                      Text((s.isHindi ? daysHi : daysEn)[d.weekday - 1], style: TextStyle(fontSize: 12, color: cs.outline, fontWeight: FontWeight.w600)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SectionTitle(context.tr('skills')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: skills.entries.map((e) {
                  final color = kSkillColors[e.key]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Row(children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(context.tr('skill_${e.key}'), style: const TextStyle(fontWeight: FontWeight.w600))),
                          Text('${(e.value * 100).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                        ]),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(value: e.value, minHeight: 9, color: color, backgroundColor: color.withValues(alpha: 0.13)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SectionTitle(context.tr('badges')),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
            children: badges.map((b) {
              final (key, icon, earned) = b;
              return Card(
                child: Opacity(
                  opacity: earned ? 1 : 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: earned ? AppColors.secondary : cs.surfaceContainerHighest,
                        child: Icon(icon, color: earned ? Colors.white : cs.outline),
                      ),
                      const SizedBox(height: 8),
                      Text(context.tr(key), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SectionTitle(context.tr('certificate')),
          if (certified.isEmpty)
            Card(child: ListTile(leading: const Icon(Icons.workspace_premium_outlined), title: Text(context.tr('no_certs')), subtitle: Text(context.tr('cert_hint'))))
          else
            ...certified.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    child: ListTile(
                      leading: const Icon(Icons.workspace_premium_rounded, color: AppColors.secondary, size: 36),
                      title: Text(context.tx(c['title']), style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${s.userName} • ${context.tr('best_score')}: ${s.quizScores[c['id']]}%'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c))),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _kv(String emoji, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text('$emoji  $text', style: const TextStyle(fontSize: 13)),
      );
}
