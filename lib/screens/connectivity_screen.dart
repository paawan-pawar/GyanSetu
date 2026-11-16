import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class ConnectivityScreen extends StatelessWidget {
  const ConnectivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final cs = Theme.of(context).colorScheme;

    IconData hotspotIcon(String t) => switch (t) {
          'csc' => Icons.storefront_rounded,
          'library' => Icons.local_library_rounded,
          _ => Icons.wifi_rounded,
        };

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('f_connect')), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeroHeader(title: context.tr('connect_title'), subtitle: context.tr('connect_sub'), icon: Icons.wifi_tethering_rounded,
              colors: const [Color(0xFF283593), Color(0xFF5C6BC0)]),
          SectionTitle(context.tr('nearby_hotspots')),
          ...repo.hotspots.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: IconBadge(hotspotIcon(h['type']), color: const Color(0xFF3949AB), size: 42),
                    title: Text(context.tx(h['name']), style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('🕑 ${context.tx(h['timing'])}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${h['distance']} ${context.tr('km')}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Pill(h['free'] == true ? context.tr('free') : context.tr('paid'), color: h['free'] == true ? AppColors.accent : cs.outline),
                      ],
                    ),
                  ),
                ),
              )),
          SectionTitle(context.tr('free_data')),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: repo.dataPacks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = repo.dataPacks[i];
                final claimed = s.claimedPacks.contains(p['id']);
                return Container(
                  width: 200,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(colors: [const Color(0xFF3949AB), const Color(0xFF3949AB).withValues(alpha: 0.7)]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['data'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      Text(context.tx(p['validity']), style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Expanded(child: Text(context.tx(p['sponsor']), style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2)),
                      SizedBox(
                        height: 32,
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
                          onPressed: claimed
                              ? null
                              : () {
                                  s.claimPack(p['id']);
                                  context.toast(context.trNow('claim_ok'));
                                },
                          child: Text(claimed ? context.tr('claimed') : context.tr('claim')),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Card(
            color: AppColors.secondary.withValues(alpha: 0.13),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const IconBadge(Icons.phone_android_rounded, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('device_request'), style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(context.tr('device_request_desc'), style: const TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: s.deviceRequested ? null : () => _deviceForm(context),
                    child: Text(s.deviceRequested ? context.tr('applied') : context.tr('apply')),
                  ),
                ],
              ),
            ),
          ),
          SectionTitle(context.tr('gov_programs')),
          ...repo.programs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: IconBadge(iconFor(p['icon']), color: const Color(0xFF3949AB), size: 42),
                    title: Text(context.tx(p['name']), style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(context.tx(p['desc']))),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                    onTap: () => openLink(context, p['url']),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _deviceForm(BuildContext context) {
    final ctrl = TextEditingController();
    showAppSheet(
      context,
      (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ctx.tr('device_request'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(hintText: ctx.tr('reason'))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ctx.read<AppState>().requestDevice();
                  final msg = ctx.trNow('claim_ok');
                  Navigator.pop(ctx);
                  context.toast(msg);
                },
                child: Text(ctx.tr('submit')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
