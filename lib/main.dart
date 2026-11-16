import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_state.dart';
import 'core/data_repository.dart';
import 'core/theme.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await Future.wait([state.load(), DataRepository.instance.load()]);
  runApp(ChangeNotifierProvider.value(value: state, child: const GyanSetuApp()));
}

class GyanSetuApp extends StatelessWidget {
  const GyanSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return MaterialApp(
      title: s.isHindi ? 'ज्ञान सेतु' : 'Gyan Setu',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: s.darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(s.lang),
      home: s.onboarded ? const HomeShell() : const OnboardingScreen(),
    );
  }
}
