import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/data_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String _cat = 'all';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final repo = DataRepository.instance;
    final list = repo.resources.where((r) => _cat == 'all' || r['category'] == _cat).toList();
    const green = Color(0xFF43A047);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('resources_title')), actions: const [LanguageToggle()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionTitle(context.tr('e_library')),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: repo.eLibrary.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final e = repo.eLibrary[i];
                return SizedBox(
                  width: 210,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => openLink(context, e['url']),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.local_library_rounded, color: green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(context.tx(e['name']), style: const TextStyle(fontWeight: FontWeight.w800))),
                              const Icon(Icons.open_in_new_rounded, size: 16),
                            ]),
                            const SizedBox(height: 8),
                            Text(context.tx(e['desc']), maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, height: 1.3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SectionTitle(context.tr('physical_resources')),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['all', 'books', 'devices', 'kits', 'stationery']
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(label: Text(c == 'all' ? context.tr('all') : context.tr('cat_$c')), selected: _cat == c, onSelected: (_) => setState(() => _cat = c)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          ...list.map((r) {
            final requested = s.requestedResources.contains(r['id']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(iconFor(r['icon']), color: green, size: 50),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tx(r['name']), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(context.tx(r['desc']), style: const TextStyle(fontSize: 13, height: 1.35)),
                            const SizedBox(height: 8),
                            Wrap(spacing: 6, runSpacing: 6, children: [
                              Pill('${r['available']} ${context.tr('in_stock')}', color: AppColors.accent, icon: Icons.inventory_rounded),
                              Pill('${context.tr('pickup')}: ${context.tx(r['location'])}', color: const Color(0xFF1E88E5), icon: Icons.place_rounded),
                            ]),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonalIcon(
                                onPressed: requested
                                    ? null
                                    : () {
                                        s.requestResource(r['id']);
                                        context.toast(context.trNow('request_ok'));
                                      },
                                icon: Icon(requested ? Icons.check_rounded : Icons.add_shopping_cart_rounded, size: 18),
                                label: Text(requested ? context.tr('requested') : context.tr('request')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
