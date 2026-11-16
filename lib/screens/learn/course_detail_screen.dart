import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/data_repository.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../mentors_screen.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Json course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final cat = repo.category(course['category']);
    final color = colorFrom(cat['color']);
    final lessons = (course['lessons'] as List).cast<Json>();
    final done = s.doneCount(course['id']);
    final mentor = repo.mentor(course['mentorId']);
    final best = s.quizScores[course['id']];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
            backgroundColor: color,
            foregroundColor: Colors.white,
            actions: const [LanguageToggle()],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.65)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                child: Stack(
                  children: [
                    Positioned(right: -20, bottom: -30, child: Icon(iconFor(cat['icon']), size: 160, color: Colors.white12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(context.tx(course['title']), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('⭐ ${course['rating']}  •  ${lessons.length} ${context.tr('lessons')}  •  ${context.tr(course['level'])}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('about_course'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(context.tx(course['description']), style: const TextStyle(height: 1.45)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(context.tr('course_progress'), style: TextStyle(color: cs.outline, fontSize: 12.5)),
                            const Spacer(),
                            Text('${(done * 100 / lessons.length).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(value: done / lessons.length, minHeight: 8, color: color, backgroundColor: color.withValues(alpha: 0.15)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (mentor != null) ...[
                  SectionTitle(context.tr('your_mentor')),
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Text(mentor['initials'], style: TextStyle(color: color, fontWeight: FontWeight.w800))),
                      title: Text(context.tx(mentor['name']), style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(context.tx(mentor['expertise'])),
                      trailing: FilledButton.tonal(
                        onPressed: () => showAskDoubtSheet(context, mentor, course: course),
                        child: Text(context.tr('ask_doubt')),
                      ),
                    ),
                  ),
                ],
                SectionTitle(context.tr('recorded_classes')),
                ...List.generate(lessons.length, (i) {
                  final l = lessons[i];
                  final isDone = s.isLessonDone(course['id'], l['id']);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(course: course, index: i))),
                        leading: CircleAvatar(
                          backgroundColor: isDone ? AppColors.accent : color.withValues(alpha: 0.15),
                          child: isDone
                              ? const Icon(Icons.check_rounded, color: Colors.white)
                              : Text('${i + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                        ),
                        title: Text(context.tx(l['title']), style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('▶ ${l['duration']} ${context.tr('minutes')}'),
                        trailing: Icon(Icons.play_circle_fill_rounded, color: color, size: 32),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const IconBadge(Icons.quiz_rounded, color: AppColors.secondary),
                    title: Text(context.tr('take_quiz'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(best == null
                        ? '${(course['quiz'] as List).length} ${context.tr('question')}'
                        : '${context.tr('best_score')}: $best%'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(course: course))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
