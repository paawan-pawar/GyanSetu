import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

const _avatarColors = [Color(0xFFEF6C00), Color(0xFF1E88E5), Color(0xFF43A047), Color(0xFF8E24AA), Color(0xFF00897B), Color(0xFF6D4C41), Color(0xFFC62828)];

class MentorsScreen extends StatelessWidget {
  const MentorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository.instance;
    final s = context.watch<AppState>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('mentors_title')),
          actions: const [LanguageToggle()],
          bottom: TabBar(tabs: [Tab(text: context.tr('f_mentors')), Tab(text: '${context.tr('my_sessions')} (${s.bookings.length + s.doubts.length})')]),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                HeroHeader(title: context.tr('mentors_title'), subtitle: context.tr('mentors_sub'), icon: Icons.support_agent_rounded,
                    colors: const [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
                const SizedBox(height: 16),
                ...List.generate(repo.mentors.length, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MentorCard(mentor: repo.mentors[i], color: _avatarColors[i % _avatarColors.length]),
                    )),
              ],
            ),
            _MySessions(),
          ],
        ),
      ),
    );
  }
}

class MentorCard extends StatelessWidget {
  final Json mentor;
  final Color color;
  const MentorCard({super.key, required this.mentor, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final available = mentor['available'] == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: color.withValues(alpha: 0.15), child: Text(mentor['initials'], style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18))),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(color: available ? AppColors.accent : cs.outline, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tx(mentor['name']), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(context.tx(mentor['expertise']), style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('⭐ ${mentor['rating']}  •  ${mentor['experience']} ${context.tr('years_exp')}  •  ${mentor['sessions']} ${context.tr('sessions')}',
                          style: TextStyle(fontSize: 12, color: cs.outline)),
                    ],
                  ),
                ),
                Pill(available ? context.tr('available') : context.tr('busy'), color: available ? AppColors.accent : cs.outline),
              ],
            ),
            const SizedBox(height: 10),
            Text(context.tx(mentor['bio']), style: const TextStyle(height: 1.4, fontSize: 13.5)),
            const SizedBox(height: 6),
            Text('🗣 ${context.tr('speaks')}: ${context.tx(mentor['languages'])}', style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showAskDoubtSheet(context, mentor),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: Text(context.tr('ask_doubt')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showBooking(context, mentor),
                    icon: const Icon(Icons.event_available_rounded, size: 18),
                    label: Text(context.tr('book_session')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBooking(BuildContext context, Json mentor) {
    showAppSheet(context, (ctx) => _BookingSheet(mentor: mentor));
  }
}

class _BookingSheet extends StatefulWidget {
  final Json mentor;
  const _BookingSheet({required this.mentor});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _day = 0;
  String _slot = '10:00 AM';
  String _mode = 'mode_call';
  static const _slots = ['10:00 AM', '11:30 AM', '2:00 PM', '4:00 PM', '6:00 PM'];

  @override
  Widget build(BuildContext context) {
    final days = [context.tr('tomorrow'), context.tr('day_after'), '+3']; // simple demo schedule
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${context.tr('book_session')} – ${context.tx(widget.mentor['name'])}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Text(context.tr('choose_slot'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: List.generate(3, (i) => ButtonSegment(value: i, label: Text(days[i]))),
            selected: {_day},
            onSelectionChanged: (v) => setState(() => _day = v.first),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _slots.map((t) => ChoiceChip(label: Text(t), selected: _slot == t, onSelected: (_) => setState(() => _slot = t))).toList(),
          ),
          const SizedBox(height: 16),
          Text(context.tr('session_mode'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['mode_call', 'mode_video', 'mode_visit']
                .map((m) => ChoiceChip(label: Text(context.tr(m)), selected: _mode == m, onSelected: (_) => setState(() => _mode = m)))
                .toList(),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final date = DateTime.now().add(Duration(days: _day + 1));
                context.read<AppState>().addBooking({
                  'mentor': widget.mentor['name'],
                  'date': '${date.day}/${date.month}/${date.year}',
                  'slot': _slot,
                  'mode': _mode,
                });
                final msg = context.trNow('booked_ok');
                Navigator.pop(context);
                context.toast(msg);
              },
              child: Text(context.tr('book_session')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared "ask a doubt" sheet, also used from the course page.
void showAskDoubtSheet(BuildContext context, Json mentor, {Json? course}) {
  final ctrl = TextEditingController();
  showAppSheet(
    context,
    (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${ctx.tr('ask_doubt')} – ${ctx.tx(mentor['name'])}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          if (course != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(ctx.tx(course['title']), style: TextStyle(color: Theme.of(ctx).colorScheme.outline))),
          const SizedBox(height: 14),
          TextField(controller: ctrl, autofocus: true, maxLines: 4, decoration: InputDecoration(hintText: ctx.tr('type_doubt'))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.send_rounded),
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                ctx.read<AppState>().addDoubt({'mentor': mentor['name'], 'text': ctrl.text.trim(), 'course': course?['title']});
                final msg = ctx.trNow('doubt_sent');
                Navigator.pop(ctx);
                context.toast(msg);
              },
              label: Text(ctx.tr('submit')),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MySessions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.bookings.isEmpty && s.doubts.isEmpty) return EmptyState(context.tr('no_sessions'), icon: Icons.event_busy_rounded);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...s.bookings.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: const IconBadge(Icons.event_available_rounded, color: Color(0xFF8E24AA)),
                  title: Text(context.tx(b['mentor']), style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${b['date']} • ${b['slot']} • ${context.tr(b['mode'])}'),
                ),
              ),
            )),
        ...s.doubts.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: const IconBadge(Icons.chat_rounded, color: Color(0xFF1E88E5)),
                  title: Text(d['text'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('→ ${context.tx(d['mentor'])}'),
                ),
              ),
            )),
      ],
    );
  }
}
