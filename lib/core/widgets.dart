import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_state.dart';
import 'strings.dart';
import 'theme.dart';

/// Localization helpers available on every BuildContext.
extension L10n on BuildContext {
  /// Static UI string by key, in the current language (rebuilds on change).
  String tr(String key) {
    final lang = watch<AppState>().lang;
    return kStrings[key]?[lang] ?? kStrings[key]?['en'] ?? key;
  }

  /// Same as [tr] but without subscribing (safe in callbacks).
  String trNow(String key) {
    final lang = read<AppState>().lang;
    return kStrings[key]?[lang] ?? kStrings[key]?['en'] ?? key;
  }

  /// Bilingual JSON field {"en": "...", "hi": "..."}.
  String tx(dynamic field) {
    if (field is! Map) return field?.toString() ?? '';
    final lang = watch<AppState>().lang;
    return (field[lang] ?? field['en'] ?? '').toString();
  }

  String txNow(dynamic field) {
    if (field is! Map) return field?.toString() ?? '';
    final lang = read<AppState>().lang;
    return (field[lang] ?? field['en'] ?? '').toString();
  }

  void toast(String msg) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }
}

Future<void> openLink(BuildContext context, String url) async {
  final msg = context.trNow('could_not_open');
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) context.toast(msg);
}

const Map<String, IconData> kIcons = {
  'menu_book': Icons.menu_book_rounded,
  'calculate': Icons.calculate_rounded,
  'science': Icons.science_rounded,
  'record_voice_over': Icons.record_voice_over_rounded,
  'smartphone': Icons.smartphone_rounded,
  'agriculture': Icons.agriculture_rounded,
  'savings': Icons.savings_rounded,
  'wifi': Icons.wifi_rounded,
  'cell_tower': Icons.cell_tower_rounded,
  'storefront': Icons.storefront_rounded,
  'tv': Icons.tv_rounded,
  'radio': Icons.radio_rounded,
  'auto_stories': Icons.auto_stories_rounded,
  'tablet_android': Icons.tablet_android_rounded,
  'biotech': Icons.biotech_rounded,
  'solar_power': Icons.solar_power_rounded,
  'edit': Icons.edit_rounded,
  'precision_manufacturing': Icons.precision_manufacturing_rounded,
};

IconData iconFor(String? name) => kIcons[name] ?? Icons.circle_outlined;
Color colorFrom(String hex) => Color(int.parse(hex));

/// The Gyan Setu logo (book + bridge + rising sun), see tool/make_logo.py.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/logo/logo.png', width: size, height: size, filterQuality: FilterQuality.medium);
}

/// Gradient header used at the top of feature screens.
class HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color>? colors;
  final Widget? trailing;
  const HeroHeader({super.key, required this.title, required this.subtitle, required this.icon, this.colors, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: colors ?? const [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13.5, height: 1.35)),
                if (trailing != null) ...[const SizedBox(height: 12), trailing!],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.text, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill(this.text, {super.key, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          Text(text, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge(this.icon, {super.key, required this.color, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(size * 0.3)),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

/// Small EN | हि switch shown in app bars.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    Widget seg(String code, String label) {
      final sel = s.lang == code;
      return GestureDetector(
        onTap: () => s.setLang(code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(color: sel ? cs.primary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: Text(label, style: TextStyle(color: sel ? cs.onPrimary : cs.onSurface, fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [seg('en', 'EN'), seg('hi', 'हि')]),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String text;
  final IconData icon;
  const EmptyState(this.text, {super.key, this.icon = Icons.inbox_rounded});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [Icon(icon, size: 40, color: c), const SizedBox(height: 8), Text(text, style: TextStyle(color: c))]),
    );
  }
}

/// Simple labelled detail row used in bottom sheets.
class InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const InfoBlock({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: cs.outline, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14.5, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<T?> showAppSheet<T>(BuildContext context, Widget Function(BuildContext) builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: builder(ctx),
    ),
  );
}
