import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/widgets.dart';

const kSchemeColors = {
  'scholarship': Color(0xFF1E88E5),
  'loan': Color(0xFFC62828),
  'grant': Color(0xFF43A047),
  'incentive': Color(0xFFF59E0B),
};

const kSchemeIcons = {
  'scholarship': Icons.school_rounded,
  'loan': Icons.account_balance_rounded,
  'grant': Icons.card_giftcard_rounded,
  'incentive': Icons.workspace_premium_rounded,
};

/// Monthly EMI for a loan: P·r·(1+r)^n / ((1+r)^n − 1), r = monthly rate.
double monthlyEmi(double principal, double yearlyRatePercent, int years) {
  final r = yearlyRatePercent / 12 / 100;
  final n = years * 12;
  if (r == 0) return principal / n;
  return principal * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
}

/// Scheme ids that may suit a learner, used by the quick eligibility check.
Set<String> matchSchemes({required double income, required bool student, required bool farmer, required bool business}) {
  final m = <String>{'s9', 's8'}; // Jan Dhan & PMKVY are open to nearly everyone
  if (student) {
    m.add('s1');
    if (income <= 250000) m.add('s2');
    if (income <= 800000) m.add('s3');
    m.add('s7');
  }
  if (farmer) m.add('s6');
  if (business) m.addAll(['s4', 's5', 's10']);
  return m;
}

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String _type = 'all';
  Set<String>? _matches; // result of eligibility check

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final list = repo.schemes.where((x) {
      if (_matches != null) return _matches!.contains(x['id']);
      if (_type == 'saved') return s.savedSchemes.contains(x['id']);
      return _type == 'all' || x['type'] == _type;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('schemes_title')), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _tool(context, Icons.fact_check_rounded, context.tr('eligibility_check'), const Color(0xFF1E88E5), _openEligibility)),
              const SizedBox(width: 12),
              Expanded(child: _tool(context, Icons.calculate_rounded, context.tr('loan_calc'), const Color(0xFFC62828), _openEmi)),
            ],
          ),
          const SizedBox(height: 14),
          if (_matches != null)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.check_circle_rounded),
                title: Text('${_matches!.length} ${context.tr('matches_found')}', style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _matches = null)),
              ),
            )
          else
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['all', 'scholarship', 'loan', 'grant', 'incentive', 'saved'].map((t) {
                  final label = t == 'all' ? context.tr('all') : t == 'saved' ? '${context.tr('saved_schemes')} (${s.savedSchemes.length})' : context.tr('type_$t');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(label), selected: _type == t, onSelected: (_) => setState(() => _type = t)),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 14),
          if (list.isEmpty) EmptyState(context.tr('no_results')),
          ...list.map((x) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _SchemeCard(scheme: x))),
        ],
      ),
    );
  }

  Widget _tool(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            IconBadge(icon, color: color, size: 40),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          ]),
        ),
      ),
    );
  }

  void _openEligibility() async {
    final res = await showAppSheet<Set<String>>(context, (ctx) => const _EligibilitySheet());
    if (res != null) setState(() => _matches = res);
  }

  void _openEmi() => showAppSheet(context, (ctx) => const _EmiSheet());
}

class _SchemeCard extends StatelessWidget {
  final Json scheme;
  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final type = scheme['type'] as String;
    final color = kSchemeColors[type]!;
    final saved = s.savedSchemes.contains(scheme['id']);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _details(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(kSchemeIcons[type]!, color: color, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tx(scheme['name']), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 4),
                        Pill(context.tr('type_$type'), color: color),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => s.toggleScheme(scheme['id']),
                    icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: saved ? color : null),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(context.tx(scheme['benefit']), style: const TextStyle(height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }

  void _details(BuildContext context) {
    showAppSheet(
      context,
      (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ctx.tx(scheme['name']), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            InfoBlock(label: ctx.tr('provider'), value: ctx.tx(scheme['provider']), icon: Icons.apartment_rounded),
            InfoBlock(label: ctx.tr('benefits'), value: ctx.tx(scheme['benefit']), icon: Icons.redeem_rounded),
            InfoBlock(label: ctx.tr('eligibility'), value: ctx.tx(scheme['eligibility']), icon: Icons.how_to_reg_rounded),
            InfoBlock(label: ctx.tr('documents'), value: ctx.tx(scheme['documents']), icon: Icons.description_rounded),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => openLink(ctx, scheme['url']),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(ctx.tr('open_website')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EligibilitySheet extends StatefulWidget {
  const _EligibilitySheet();

  @override
  State<_EligibilitySheet> createState() => _EligibilitySheetState();
}

class _EligibilitySheetState extends State<_EligibilitySheet> {
  double _income = 200000;
  bool _student = true;
  bool _farmer = false;
  bool _business = false;

  Set<String> _compute() => matchSchemes(income: _income, student: _student, farmer: _farmer, business: _business);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('eligibility_check'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Text('${context.tr('annual_income')}: ₹${(_income / 1000).round()}k', style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(value: _income, min: 0, max: 1000000, divisions: 40, onChanged: (v) => setState(() => _income = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: _student, onChanged: (v) => setState(() => _student = v), title: Text(context.tr('is_student'))),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: _farmer, onChanged: (v) => setState(() => _farmer = v), title: Text(context.tr('is_farmer'))),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: _business, onChanged: (v) => setState(() => _business = v), title: Text(context.tr('want_business'))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () => Navigator.pop(context, _compute()), child: Text(context.tr('show_matches'))),
          ),
        ],
      ),
    );
  }
}

class _EmiSheet extends StatefulWidget {
  const _EmiSheet();

  @override
  State<_EmiSheet> createState() => _EmiSheetState();
}

class _EmiSheetState extends State<_EmiSheet> {
  double _amount = 100000;
  double _rate = 9;
  double _years = 3;

  @override
  Widget build(BuildContext context) {
    final n = (_years * 12).round();
    final emi = monthlyEmi(_amount, _rate, _years.round());
    final interest = emi * n - _amount;
    final cs = Theme.of(context).colorScheme;
    String rupee(num v) => '₹${v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (m) => '${m[1]},')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('loan_calc'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text('${context.tr('loan_amount')}: ${rupee(_amount)}'),
          Slider(value: _amount, min: 10000, max: 1000000, divisions: 99, onChanged: (v) => setState(() => _amount = v)),
          Text('${context.tr('interest_rate')}: ${_rate.toStringAsFixed(1)}%'),
          Slider(value: _rate, min: 1, max: 24, divisions: 46, onChanged: (v) => setState(() => _rate = v)),
          Text('${context.tr('tenure_years')}: ${_years.round()}'),
          Slider(value: _years, min: 1, max: 15, divisions: 14, onChanged: (v) => setState(() => _years = v)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(child: _out(context.tr('monthly_emi'), rupee(emi))),
                Expanded(child: _out(context.tr('total_interest'), rupee(interest))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _out(String l, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(l, style: const TextStyle(fontSize: 12.5)), Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))],
      );
}
