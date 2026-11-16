import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'learn/learn_screen.dart';

class DigitalLiteracyScreen extends StatelessWidget {
  const DigitalLiteracyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final checklist = repo.digitalChecklist;
    final doneCount = checklist.where((c) => s.digitalChecklist.contains(c['id'])).length;
    final courses = repo.courses.where((c) => c['category'] == 'digital' || c['category'] == 'finance').toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('f_digital')), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeroHeader(
            title: context.tr('digital_title'),
            subtitle: context.tr('digital_sub'),
            icon: Icons.devices_rounded,
            colors: const [Color(0xFF00695C), Color(0xFF26A69A)],
            trailing: Pill('$doneCount/${checklist.length} ✓', color: Colors.white),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: s.lowData,
              onChanged: s.setLowData,
              secondary: const IconBadge(Icons.data_saver_on_rounded, color: AppColors.accent, size: 40),
              title: Text(context.tr('low_data_mode'), style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(context.tr('low_data_desc')),
            ),
          ),
          SectionTitle(context.tr('my_checklist')),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: doneCount / checklist.length, minHeight: 8, color: AppColors.accent),
                  ),
                ),
                ...checklist.map((c) => CheckboxListTile(
                      value: s.digitalChecklist.contains(c['id']),
                      onChanged: (_) => s.toggleChecklist(c['id']),
                      title: Text(context.tx(c['text'])),
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
              ],
            ),
          ),
          SectionTitle(context.tr('digital_courses')),
          ...courses.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: CourseCard(course: c))),
          SectionTitle(context.tr('safety_tips')),
          Card(
            color: Colors.red.withValues(alpha: 0.07),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...repo.safetyTips.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_rounded, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(context.tx(t), style: const TextStyle(height: 1.4))),
                          ],
                        ),
                      )),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () => openLink(context, 'tel:1930'),
                      icon: const Icon(Icons.call_rounded),
                      label: Text(context.tr('helpline')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
