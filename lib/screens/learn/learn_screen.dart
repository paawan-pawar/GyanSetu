import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/data_repository.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'course_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  final bool standalone;
  const LearnScreen({super.key, this.standalone = false});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _cat = 'all';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository.instance;
    final s = context.watch<AppState>();
    final q = _query.toLowerCase();
    final list = repo.courses.where((c) {
      if (_cat != 'all' && c['category'] != _cat) return false;
      if (q.isEmpty) return true;
      final t = c['title'] as Map;
      return '${t['en']} ${t['hi']}'.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.standalone,
        title: Text(context.tr('learn_title')),
        actions: const [LanguageToggle()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(hintText: context.tr('search'), prefixIcon: const Icon(Icons.search_rounded)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip('all', context.tr('all'), Icons.apps_rounded, Theme.of(context).colorScheme.primary),
                ...repo.categories.map((c) => _chip(c['id'], context.tx(c['name']), iconFor(c['icon']), colorFrom(c['color']))),
              ],
            ),
          ),
          if (s.lowData) ...[
            const SizedBox(height: 12),
            Pill(context.tr('low_data_mode'), color: AppColors.accent, icon: Icons.data_saver_on_rounded),
          ],
          SectionTitle('${context.tr('recorded_classes')} (${list.length})'),
          if (list.isEmpty) EmptyState(context.tr('no_results')),
          ...list.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: CourseCard(course: c))),
        ],
      ),
    );
  }

  Widget _chip(String id, String label, IconData icon, Color color) {
    final sel = _cat == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: sel,
        showCheckmark: false,
        avatar: Icon(icon, size: 18, color: sel ? Colors.white : color),
        label: Text(label),
        labelStyle: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w600),
        selectedColor: color,
        onSelected: (_) => setState(() => _cat = id),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Json course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cat = DataRepository.instance.category(course['category']);
    final color = colorFrom(cat['color']);
    final total = (course['lessons'] as List).length;
    final done = s.doneCount(course['id']);
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Icon(iconFor(cat['icon']), color: Colors.white, size: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Pill(context.tx(cat['name']), color: color),
                      const SizedBox(width: 6),
                      Pill(context.tr(course['level']), color: cs.outline),
                    ]),
                    const SizedBox(height: 6),
                    Text(context.tx(course['title']), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.25)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                        Text(' ${course['rating']}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Icon(Icons.people_alt_rounded, size: 15, color: cs.outline),
                        Text(' ${course['learners']} ${context.tr('learners')}', style: TextStyle(fontSize: 12, color: cs.outline)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(value: done / total, minHeight: 6, color: color, backgroundColor: color.withValues(alpha: 0.15)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$done/$total', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
