import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'progress_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository.instance;
    final jobs = repo.jobs.where((j) => j['type'] == 'job').toList();
    final trainings = repo.jobs.where((j) => j['type'] == 'training').toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('jobs_title')),
          actions: [
            IconButton(tooltip: context.tr('resume'), icon: const Icon(Icons.badge_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResumeScreen()))),
            const LanguageToggle(),
          ],
          bottom: TabBar(tabs: [Tab(text: '${context.tr('jobs')} (${jobs.length})'), Tab(text: '${context.tr('trainings')} (${trainings.length})')]),
        ),
        body: TabBarView(children: [_JobList(items: jobs), _JobList(items: trainings)]),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  final List<Json> items;
  const _JobList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFF6D4C41).withValues(alpha: 0.1),
          child: ListTile(
            leading: const IconBadge(Icons.badge_rounded, color: Color(0xFF6D4C41), size: 42),
            title: Text(context.tr('resume_builder'), style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResumeScreen())),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((j) => Padding(padding: const EdgeInsets.only(bottom: 12), child: JobCard(job: j))),
        TextButton.icon(
          onPressed: () => openLink(context, 'https://www.ncs.gov.in'),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(context.tr('ncs_portal')),
        ),
      ],
    );
  }
}

class JobCard extends StatelessWidget {
  final Json job;
  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final applied = s.appliedJobs.contains(job['id']);
    final isTraining = job['type'] == 'training';
    final color = isTraining ? const Color(0xFF00897B) : const Color(0xFF6D4C41);
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(isTraining ? Icons.construction_rounded : Icons.work_rounded, color: color, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tx(job['title']), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(context.tx(job['org']), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Pill(context.tx(job['location']), color: const Color(0xFF1E88E5), icon: Icons.location_on_rounded),
                Pill(job['salary'], color: AppColors.accent, icon: Icons.payments_rounded),
                Pill('${job['posted']} ${context.tr(job['posted'] == 1 ? 'day_ago' : 'days_ago')}', color: cs.outline, icon: Icons.schedule_rounded),
              ],
            ),
            const SizedBox(height: 10),
            Text('${context.tr('requirements')}: ${context.tx(job['requirements'])}', style: const TextStyle(fontSize: 13, height: 1.35)),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(onPressed: () => openLink(context, job['url']), child: Text(context.tr('open_website'))),
                const Spacer(),
                FilledButton.icon(
                  onPressed: applied
                      ? null
                      : () {
                          s.applyJob(job['id']);
                          context.toast(context.trNow('apply_ok'));
                        },
                  icon: Icon(applied ? Icons.check_rounded : Icons.send_rounded, size: 18),
                  label: Text(applied ? context.tr('applied') : context.tr('apply')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Auto-generated simple resume using profile + completed courses.
class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  late final TextEditingController _phone;
  late final TextEditingController _edu;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _phone = TextEditingController(text: s.phone);
    _edu = TextEditingController(text: s.education);
  }

  @override
  void dispose() {
    _phone.dispose();
    _edu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final skills = computeSkills(s).entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    final courses = repo.courses.where((c) => s.doneCount(c['id']) > 0).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('resume')), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: context.tr('phone'), prefixIcon: const Icon(Icons.phone_rounded))),
          const SizedBox(height: 12),
          TextField(controller: _edu, decoration: InputDecoration(labelText: context.tr('education'), prefixIcon: const Icon(Icons.school_rounded))),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              s.saveProfile(name: s.userName, village: s.village, role: s.role, phone: _phone.text.trim(), education: _edu.text.trim());
              context.toast(context.trNow('saved'));
            },
            child: Text(context.tr('save')),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  Text('${context.tr('role_${s.role}')} • ${s.village}', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                  if (s.phone.isNotEmpty) Text('📞 ${s.phone}'),
                  const Divider(height: 28),
                  Text(context.tr('education'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(s.education.isEmpty ? '—' : s.education),
                  const SizedBox(height: 14),
                  Text(context.tr('skills_from_app'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  if (skills.isEmpty) const Text('—'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: skills.map((e) => Pill('${context.tr('skill_${e.key}')} ${(e.value * 100).round()}%', color: kSkillColors[e.key]!)).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(context.tr('recorded_classes'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  if (courses.isEmpty) const Text('—'),
                  ...courses.map((c) => Text('• ${context.tx(c['title'])}')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
