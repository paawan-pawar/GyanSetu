import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'features.dart';
import 'learn/course_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final cs = Theme.of(context).colorScheme;

    // Continue-learning: first course started but not finished, else the first course.
    Json resume = repo.courses.first;
    for (final c in repo.courses) {
      final done = s.doneCount(c['id']);
      if (done > 0 && done < (c['lessons'] as List).length) {
        resume = c;
        break;
      }
    }
    final resumeTotal = (resume['lessons'] as List).length;
    final resumeDone = s.doneCount(resume['id']);
    final word = repo.words[DateTime.now().day % repo.words.length];
    final popular = [...repo.courses]..sort((a, b) => (b['learners'] as int).compareTo(a['learners'] as int));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: cs.primaryContainer,
                  child: Text(s.userName.isEmpty ? '?' : s.userName.characters.first.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w800, color: cs.onPrimaryContainer, fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${context.tr('hello')}, ${s.userName} 👋', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                      Text(context.tr('home_sub'), style: TextStyle(color: cs.outline, fontSize: 13)),
                    ],
                  ),
                ),
                const LanguageToggle(),
              ],
            ),
            const SizedBox(height: 18),
            // Stats + continue learning hero
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _stat('🔥 ${s.streak}', context.tr('day_streak')),
                      const SizedBox(width: 10),
                      _stat('📘 ${s.completedLessons.length}', context.tr('lessons_done')),
                      const SizedBox(width: 10),
                      _stat('🏅 ${s.quizScores.length}', context.tr('quizzes_taken')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(context.tr('continue_learning'), style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Text(context.tx(resume['title']), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: resumeTotal == 0 ? 0 : resumeDone / resumeTotal,
                      minHeight: 7,
                      backgroundColor: Colors.white24,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('$resumeDone/$resumeTotal ${context.tr('lessons')}', style: const TextStyle(color: Colors.white)),
                      const Spacer(),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: resume))),
                        child: Text(context.tr('start_now')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SectionTitle(context.tr('explore')),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kFeatures.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.92),
              itemBuilder: (_, i) {
                final f = kFeatures[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      // Learn & progress live in the bottom nav, jump there instead of pushing.
                      if (f.key == 'f_study') return onNavigate(1);
                      if (f.key == 'f_progress') return onNavigate(2);
                      openFeature(context, f);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconBadge(f.icon, color: f.color, size: 48),
                          const SizedBox(height: 10),
                          Text(context.tr(f.key), textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.2)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SectionTitle(context.tr('word_of_day')),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                leading: const IconBadge(Icons.translate_rounded, color: Color(0xFFD81B60)),
                title: Text('${word['word']}  •  ${word['meaning']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text('"${word['example']}"', style: const TextStyle(fontStyle: FontStyle.italic))),
                onTap: () => openFeature(context, featureByKey('f_communication')),
              ),
            ),
            SectionTitle(context.tr('popular_courses'), action: context.tr('see_all'), onAction: () => onNavigate(1)),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => CourseMiniCard(course: popular[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}

class CourseMiniCard extends StatelessWidget {
  final Json course;
  const CourseMiniCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final cat = DataRepository.instance.category(course['category']);
    final color = colorFrom(cat['color']);
    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 78,
                width: double.infinity,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)])),
                child: Stack(
                  children: [
                    Positioned(right: -10, bottom: -14, child: Icon(iconFor(cat['icon']), size: 80, color: Colors.white24)),
                    Padding(padding: const EdgeInsets.all(12), child: Icon(Icons.play_circle_fill_rounded, color: Colors.white.withValues(alpha: 0.95), size: 30)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tx(course['title']), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                        Text(' ${course['rating']}  ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('${(course['lessons'] as List).length} ${context.tr('lessons')}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
