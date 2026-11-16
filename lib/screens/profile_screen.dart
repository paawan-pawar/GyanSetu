import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'jobs_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final cs = Theme.of(context).colorScheme;

    String names(List<Json> src, Set<String> ids, String field) =>
        src.where((x) => ids.contains(x['id'])).map((x) => context.tx(x[field])).join(', ');

    final apps = <(IconData, String, String)>[
      (Icons.work_rounded, context.tr('jobs_title'), names(repo.jobs, s.appliedJobs, 'title')),
      (Icons.bookmark_rounded, context.tr('saved_schemes'), names(repo.schemes, s.savedSchemes, 'name')),
      (Icons.inventory_2_rounded, context.tr('f_resources'), names(repo.resources, s.requestedResources, 'name')),
      (Icons.event_available_rounded, context.tr('my_sessions'), s.bookings.isEmpty ? '' : '${s.bookings.length} ${context.tr('sessions')}'),
      (Icons.wifi_rounded, context.tr('free_data'), s.claimedPacks.isEmpty ? '' : '${s.claimedPacks.length} ${context.tr('items')}'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile_title')), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(s.userName.isEmpty ? '?' : s.userName.characters.first.toUpperCase(),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      Text('${context.tr('role_${s.role}')}${s.village.isEmpty ? '' : ' • ${s.village}'}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editProfile(context),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  tooltip: context.tr('edit_profile'),
                ),
              ],
            ),
          ),
          SectionTitle(context.tr('language')),
          Card(
            child: RadioGroup<String>(
              groupValue: s.lang,
              onChanged: (v) => s.setLang(v!),
              child: const Column(
                children: [
                  RadioListTile(value: 'en', title: Text('English'), secondary: Text('A', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
                  RadioListTile(value: 'hi', title: Text('हिंदी'), secondary: Text('अ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(value: s.darkMode, onChanged: s.setDark, secondary: const Icon(Icons.dark_mode_rounded), title: Text(context.tr('dark_mode'))),
                SwitchListTile(value: s.lowData, onChanged: s.setLowData, secondary: const Icon(Icons.data_saver_on_rounded), title: Text(context.tr('low_data_mode'))),
                ListTile(
                  leading: const Icon(Icons.badge_rounded),
                  title: Text(context.tr('resume')),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResumeScreen())),
                ),
              ],
            ),
          ),
          SectionTitle(context.tr('my_applications')),
          Card(
            child: Column(
              children: apps
                  .map((a) => ListTile(
                        leading: Icon(a.$1, color: cs.primary),
                        title: Text(a.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(a.$3.isEmpty ? context.tr('nothing_yet') : a.$3),
                      ))
                  .toList(),
            ),
          ),
          SectionTitle(context.tr('about_app')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const AppLogo(size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(context.tr('app_name'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text(context.tr('tagline'), style: TextStyle(fontSize: 12.5, color: cs.outline)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(context.tr('about_text'), style: const TextStyle(height: 1.45)),
                  const SizedBox(height: 10),
                  Text(context.tr('data_sources'), style: TextStyle(fontSize: 12, color: cs.outline, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(context.tr('offline_ready'), style: TextStyle(fontSize: 12, color: cs.outline)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: cs.error),
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(context.tr('reset_progress')),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(ctx.tr('reset_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(ctx.tr('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(ctx.tr('continue'))),
        ],
      ),
    );
    if (ok == true && context.mounted) await context.read<AppState>().resetAll();
  }

  void _editProfile(BuildContext context) {
    final s = context.read<AppState>();
    final name = TextEditingController(text: s.userName);
    final village = TextEditingController(text: s.village);
    var role = s.role;
    showAppSheet(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ctx.tr('edit_profile'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              TextField(controller: name, decoration: InputDecoration(labelText: ctx.tr('your_name'))),
              const SizedBox(height: 12),
              TextField(controller: village, decoration: InputDecoration(labelText: ctx.tr('your_village'))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kRoles.map((r) => ChoiceChip(label: Text(ctx.tr('role_$r')), selected: role == r, onSelected: (_) => setSt(() => role = r))).toList(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (name.text.trim().isEmpty) return;
                    s.saveProfile(name: name.text.trim(), village: village.text.trim(), role: role);
                    Navigator.pop(ctx);
                  },
                  child: Text(ctx.tr('save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
