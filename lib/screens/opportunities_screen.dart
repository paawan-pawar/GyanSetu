import 'package:flutter/material.dart';

import '../core/data_repository.dart';
import '../core/widgets.dart';
import 'features.dart';
import 'jobs_screen.dart';

/// Hub for everything beyond classes: schemes, jobs, connectivity, resources, R&D.
class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final keys = ['f_schemes', 'f_jobs', 'f_connect', 'f_resources', 'f_research', 'f_mentors', 'f_digital'];
    final latestJobs = DataRepository.instance.jobs.where((j) => j['type'] == 'job').toList()
      ..sort((a, b) => (a['posted'] as int).compareTo(b['posted'] as int));
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('nav_opportunities')), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          ...keys.map((k) {
            final f = featureByKey(k);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: IconBadge(f.icon, color: f.color),
                  title: Text(context.tr(k), style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(_subtitle(context, k)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => openFeature(context, f),
                ),
              ),
            );
          }),
          SectionTitle(context.tr('jobs'), action: context.tr('see_all'), onAction: () => openFeature(context, featureByKey('f_jobs'))),
          ...latestJobs.take(2).map((j) => Padding(padding: const EdgeInsets.only(bottom: 12), child: JobCard(job: j))),
        ],
      ),
    );
  }

  String _subtitle(BuildContext context, String k) {
    return switch (k) {
      'f_schemes' => context.tr('schemes_title'),
      'f_jobs' => context.tr('jobs_title'),
      'f_connect' => context.tr('connect_sub'),
      'f_resources' => context.tr('physical_resources'),
      'f_research' => context.tr('research_sub'),
      'f_mentors' => context.tr('mentors_sub'),
      _ => context.tr('digital_sub'),
    };
  }
}
