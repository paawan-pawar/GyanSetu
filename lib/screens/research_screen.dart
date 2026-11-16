import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('research_title')),
          actions: const [LanguageToggle()],
          bottom: TabBar(tabs: [Tab(text: context.tr('projects')), Tab(text: context.tr('surveys')), Tab(text: context.tr('ideas'))]),
        ),
        body: const TabBarView(children: [_Projects(), _Surveys(), _Ideas()]),
      ),
    );
  }
}

class _Projects extends StatelessWidget {
  const _Projects();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final cs = Theme.of(context).colorScheme;
    Color statusColor(String st) => switch (st) {
          'completed' => AppColors.accent,
          'open' => const Color(0xFF1E88E5),
          _ => AppColors.secondary,
        };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HeroHeader(title: context.tr('research_title'), subtitle: context.tr('research_sub'), icon: Icons.biotech_rounded,
            colors: const [Color(0xFFF57F17), Color(0xFFFBC02D)]),
        const SizedBox(height: 14),
        ...repo.projects.map((p) {
          final joined = s.joinedProjects.contains(p['id']);
          final color = statusColor(p['status']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Pill(context.tr('status_${p['status']}'), color: color),
                      const Spacer(),
                      Icon(Icons.groups_rounded, size: 16, color: cs.outline),
                      Text(' ${(p['participants'] as int) + (joined ? 1 : 0)} ${context.tr('participants')}', style: TextStyle(fontSize: 12, color: cs.outline)),
                    ]),
                    const SizedBox(height: 10),
                    Text(context.tx(p['title']), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(context.tx(p['lead']), style: TextStyle(fontSize: 12.5, color: cs.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(context.tx(p['summary']), style: const TextStyle(height: 1.4)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: (p['progress'] as num).toDouble(), minHeight: 7, color: color, backgroundColor: color.withValues(alpha: 0.15)),
                    ),
                    if (p['status'] != 'completed') ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: joined ? null : () => s.joinProject(p['id']),
                          icon: Icon(joined ? Icons.check_rounded : Icons.volunteer_activism_rounded, size: 18),
                          label: Text(joined ? context.tr('joined') : context.tr('join_project')),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Surveys extends StatelessWidget {
  const _Surveys();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: repo.surveys.map((sv) {
        final answer = s.surveyAnswers[sv['id']];
        final opts = sv['options'] as List;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const IconBadge(Icons.poll_rounded, color: Color(0xFFF9A825), size: 38),
                    const SizedBox(width: 10),
                    Expanded(child: Text(context.tx(sv['title']), style: const TextStyle(fontWeight: FontWeight.w800))),
                    Pill(answer == null ? '${sv['minutes']} ${context.tr('minutes_survey')}' : context.tr('answered'), color: answer == null ? const Color(0xFFF9A825) : AppColors.accent),
                  ]),
                  const SizedBox(height: 12),
                  Text(context.tx(sv['question']), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  RadioGroup<int>(
                    groupValue: answer,
                    onChanged: (v) {
                      if (v == null) return;
                      s.answerSurvey(sv['id'], v);
                      context.toast(context.trNow('survey_done'));
                    },
                    child: Column(
                      children: List.generate(opts.length, (i) => RadioListTile<int>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            value: i,
                            title: Text(context.tx(opts[i])),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Ideas extends StatefulWidget {
  const _Ideas();

  @override
  State<_Ideas> createState() => _IdeasState();
}

class _IdeasState extends State<_Ideas> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(context.tr('submit_idea'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(controller: _ctrl, maxLines: 3, decoration: InputDecoration(hintText: context.tr('idea_hint'))),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () {
              if (_ctrl.text.trim().isEmpty) return;
              s.addIdea(_ctrl.text.trim());
              _ctrl.clear();
              FocusScope.of(context).unfocus();
              context.toast(context.trNow('idea_ok'));
            },
            icon: const Icon(Icons.lightbulb_rounded),
            label: Text(context.tr('submit')),
          ),
        ),
        SectionTitle(context.tr('my_ideas')),
        ...List.generate(s.ideas.length, (i) {
          final idea = s.ideas[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(child: Text((idea['name'] as String).characters.first)),
                title: Text(idea['text']),
                subtitle: Text(idea['name']),
                trailing: TextButton.icon(
                  onPressed: () => s.likeIdea(i),
                  icon: const Icon(Icons.thumb_up_alt_rounded, size: 18),
                  label: Text('${idea['likes']}'),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
