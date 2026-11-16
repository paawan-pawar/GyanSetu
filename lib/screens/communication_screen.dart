import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'learn/learn_screen.dart';

/// Communication-skills module: phrasebook, vocabulary flashcards, courses.
class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('comm_title')),
          actions: const [LanguageToggle()],
          bottom: TabBar(tabs: [Tab(text: context.tr('phrasebook')), Tab(text: context.tr('vocabulary')), Tab(text: context.tr('practice'))]),
        ),
        body: const TabBarView(children: [_Phrasebook(), _Vocabulary(), _Practice()]),
      ),
    );
  }
}

class _Phrasebook extends StatelessWidget {
  const _Phrasebook();

  @override
  Widget build(BuildContext context) {
    final phrases = DataRepository.instance.phrases;
    const pink = Color(0xFFD81B60);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HeroHeader(title: context.tr('comm_title'), subtitle: context.tr('comm_sub'), icon: Icons.record_voice_over_rounded,
            colors: const [Color(0xFFAD1457), Color(0xFFEC407A)]),
        const SizedBox(height: 10),
        Card(
          child: ListTile(leading: const Icon(Icons.tips_and_updates_rounded, color: AppColors.secondary), title: Text(context.tr('speak_tip'), style: const TextStyle(fontSize: 13.5))),
        ),
        const SizedBox(height: 10),
        ...phrases.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(context.tx(p['situation']), color: pink),
                      const SizedBox(height: 10),
                      Text(p['english'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(p['hindi'], style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _Vocabulary extends StatefulWidget {
  const _Vocabulary();

  @override
  State<_Vocabulary> createState() => _VocabularyState();
}

class _VocabularyState extends State<_Vocabulary> {
  final Set<String> _revealed = {};

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final words = DataRepository.instance.words;
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Text('${s.knownWords.length}/${words.length} ${context.tr('words_known')}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const Spacer(),
          Text(context.tr('tap_reveal'), style: TextStyle(color: cs.outline, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        ...words.map((w) {
          final word = w['word'] as String;
          final shown = _revealed.contains(word);
          final known = s.knownWords.contains(word);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => setState(() => shown ? _revealed.remove(word) : _revealed.add(word)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(16),
                  color: shown ? cs.primaryContainer.withValues(alpha: 0.5) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        if (known) const Icon(Icons.verified_rounded, color: AppColors.accent),
                      ]),
                      if (shown) ...[
                        const SizedBox(height: 6),
                        Text(w['meaning'], style: TextStyle(fontSize: 18, color: cs.primary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('"${w['example']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.tonal(
                            onPressed: () => s.toggleWord(word),
                            child: Text(known ? context.tr('learn_again') : context.tr('i_know')),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Practice extends StatelessWidget {
  const _Practice();

  @override
  Widget build(BuildContext context) {
    final courses = DataRepository.instance.coursesIn('communication') + DataRepository.instance.coursesIn('literacy');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: courses.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: CourseCard(course: c))).toList(),
    );
  }
}
