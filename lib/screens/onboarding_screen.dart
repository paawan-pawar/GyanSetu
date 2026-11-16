import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

const kRoles = ['student', 'adult', 'farmer', 'jobseeker', 'teacher'];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  final _name = TextEditingController();
  final _village = TextEditingController();
  String _role = 'student';

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _village.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 4) {
      _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      if (_name.text.trim().isEmpty) {
        context.toast(context.trNow('enter_name'));
        return;
      }
      context.read<AppState>().saveProfile(name: _name.text.trim(), village: _village.text.trim(), role: _role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pages = [
      _LanguagePage(),
      _InfoPage(icon: Icons.play_lesson_rounded, title: context.tr('onb_title_1'), desc: context.tr('onb_desc_1'), color: const Color(0xFFEF6C00)),
      _InfoPage(icon: Icons.groups_rounded, title: context.tr('onb_title_2'), desc: context.tr('onb_desc_2'), color: const Color(0xFF8E24AA)),
      _InfoPage(icon: Icons.volunteer_activism_rounded, title: context.tr('onb_title_3'), desc: context.tr('onb_desc_3'), color: AppColors.accent),
      _profilePage(context),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  const AppLogo(size: 32),
                  const SizedBox(width: 10),
                  Text(context.tr('app_name'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const Spacer(),
                  const LanguageToggle(),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: i == _index ? cs.primary : cs.outlineVariant, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_index == 4 ? context.tr('get_started') : context.tr('continue')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePage(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(context.tr('tell_about_you'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        TextField(controller: _name, decoration: InputDecoration(labelText: context.tr('your_name'), prefixIcon: const Icon(Icons.person_rounded))),
        const SizedBox(height: 14),
        TextField(controller: _village, decoration: InputDecoration(labelText: context.tr('your_village'), prefixIcon: const Icon(Icons.location_on_rounded))),
        const SizedBox(height: 20),
        Text(context.tr('i_am_a'), style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kRoles
              .map((r) => ChoiceChip(label: Text(context.tr('role_$r')), selected: _role == r, onSelected: (_) => setState(() => _role = r)))
              .toList(),
        ),
      ],
    );
  }
}

class _LanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    Widget option(String code, String label, String sub) {
      final sel = s.lang == code;
      final cs = Theme.of(context).colorScheme;
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: sel ? cs.primary : cs.outlineVariant, width: sel ? 2 : 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          onTap: () => s.setLang(code),
          leading: CircleAvatar(backgroundColor: cs.primaryContainer, child: Text(code == 'en' ? 'A' : 'अ', style: const TextStyle(fontWeight: FontWeight.w800))),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          subtitle: Text(sub),
          trailing: Icon(sel ? Icons.check_circle_rounded : Icons.circle_outlined, color: sel ? cs.primary : cs.outline),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLogo(size: 128),
          const SizedBox(height: 14),
          Text(context.tr('app_name'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(height: 10),
          Text(context.tr('tagline'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(context.tr('choose_language'), style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 26),
          option('en', 'English', 'Continue in English'),
          const SizedBox(height: 12),
          option('hi', 'हिंदी', 'हिंदी में जारी रखें'),
        ],
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _InfoPage({required this.icon, required this.title, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 96, color: color),
          ),
          const SizedBox(height: 36),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.5, height: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
