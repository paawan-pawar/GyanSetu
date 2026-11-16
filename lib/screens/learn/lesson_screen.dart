import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/data_repository.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// A single recorded class: video launcher, bilingual notes, completion.
class LessonScreen extends StatelessWidget {
  final Json course;
  final int index;
  const LessonScreen({super.key, required this.course, required this.index});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final lessons = (course['lessons'] as List).cast<Json>();
    final l = lessons[index];
    final cat = DataRepository.instance.category(course['category']);
    final color = colorFrom(cat['color']);
    final done = s.isLessonDone(course['id'], l['id']);
    final hasNext = index < lessons.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('${index + 1}. ${context.tx(l['title'])}', overflow: TextOverflow.ellipsis), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Video "player" card
          GestureDetector(
            onTap: () {
              s.completeLesson(course['id'], l['id']);
              openLink(context, l['video']);
            },
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [const Color(0xFF0F172A), color.withValues(alpha: 0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Stack(
                  children: [
                    Positioned(right: -20, bottom: -20, child: Icon(iconFor(cat['icon']), size: 150, color: Colors.white10)),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 54),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 12,
                      child: Pill('▶ ${l['duration']} ${context.tr('minutes')}', color: Colors.white),
                    ),
                    Positioned(
                      left: 14,
                      top: 12,
                      child: Text(context.tr('watch_class'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 6),
              Expanded(child: Text(context.tr('video_hint'), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline))),
            ],
          ),
          SectionTitle(context.tr('lesson_notes')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    IconBadge(Icons.sticky_note_2_rounded, color: color, size: 38),
                    const SizedBox(width: 10),
                    Expanded(child: Text(context.tx(l['title']), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  ]),
                  const SizedBox(height: 14),
                  Text(context.tx(l['notes']), style: const TextStyle(fontSize: 16, height: 1.6)),
                  const Divider(height: 28),
                  // Show the other language too – great for building bilingual skills.
                  Text(
                    s.isHindi ? (l['notes'] as Map)['en'] : (l['notes'] as Map)['hi'],
                    style: TextStyle(fontSize: 14, height: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => s.toggleLesson(course['id'], l['id']),
                  icon: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: done ? AppColors.accent : null),
                  label: Text(done ? context.tr('completed') : context.tr('mark_complete')),
                ),
              ),
              if (hasNext) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      s.completeLesson(course['id'], l['id']);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LessonScreen(course: course, index: index + 1)));
                    },
                    icon: const Icon(Icons.skip_next_rounded),
                    label: Text(context.tr('next_lesson')),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
