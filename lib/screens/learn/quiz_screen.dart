import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/data_repository.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class QuizScreen extends StatefulWidget {
  final Json course;
  const QuizScreen({super.key, required this.course});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _i = 0;
  int? _selected;
  int _correct = 0;
  bool _finished = false;

  List<Json> get _qs => (widget.course['quiz'] as List).cast<Json>();

  void _next() {
    if (_selected == _qs[_i]['answer']) _correct++;
    if (_i == _qs.length - 1) {
      final pct = (_correct * 100 / _qs.length).round();
      context.read<AppState>().recordQuiz(widget.course['id'], pct);
      setState(() => _finished = true);
    } else {
      setState(() {
        _i++;
        _selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('take_quiz')), actions: const [LanguageToggle()]),
      body: _finished ? _result(context) : _question(context, cs),
    );
  }

  Widget _question(BuildContext context, ColorScheme cs) {
    final q = _qs[_i];
    final opts = (q['options'] as List);
    final answered = _selected != null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${context.tr('question')} ${_i + 1} ${context.tr('of')} ${_qs.length}', style: TextStyle(color: cs.outline, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: (_i + 1) / _qs.length, minHeight: 7),
          ),
          const SizedBox(height: 24),
          Text(context.tx(q['q']), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, height: 1.35)),
          const SizedBox(height: 22),
          ...List.generate(opts.length, (o) {
            Color border = cs.outlineVariant;
            Color? fill;
            if (answered) {
              if (o == q['answer']) {
                border = AppColors.accent;
                fill = AppColors.accent.withValues(alpha: 0.12);
              } else if (o == _selected) {
                border = cs.error;
                fill = cs.error.withValues(alpha: 0.1);
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: fill ?? Theme.of(context).cardTheme.color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: border, width: 1.5)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: answered ? null : () => setState(() => _selected = o),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 14, backgroundColor: cs.primaryContainer, child: Text(String.fromCharCode(65 + o), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(context.tx(opts[o]), style: const TextStyle(fontSize: 16))),
                        if (answered && o == q['answer']) const Icon(Icons.check_circle_rounded, color: AppColors.accent),
                        if (answered && o == _selected && o != q['answer']) Icon(Icons.cancel_rounded, color: cs.error),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: answered ? _next : null,
              child: Text(_i == _qs.length - 1 ? context.tr('finish') : context.tr('next')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _result(BuildContext context) {
    final pct = (_correct * 100 / _qs.length).round();
    final pass = pct >= 60;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(value: pct / 100, strokeWidth: 12, color: pass ? AppColors.accent : AppColors.secondary, backgroundColor: Colors.black12),
                  Center(child: Text('$pct%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(context.tr('quiz_result'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('${context.tr('you_scored')} $_correct/${_qs.length}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(pass ? context.tr('great_job') : context.tr('try_again_msg'), textAlign: TextAlign.center),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _i = 0;
                      _selected = null;
                      _correct = 0;
                      _finished = false;
                    }),
                    child: Text(context.tr('retry')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('back_to_course')))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
