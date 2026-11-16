import 'package:flutter/material.dart';

import '../core/widgets.dart';
import 'home_screen.dart';
import 'learn/learn_screen.dart';
import 'opportunities_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int index = 0;

  void goTo(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: goTo),
      const LearnScreen(),
      const ProgressScreen(),
      const OpportunitiesScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: goTo,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: context.tr('nav_home')),
          NavigationDestination(icon: const Icon(Icons.play_lesson_outlined), selectedIcon: const Icon(Icons.play_lesson_rounded), label: context.tr('nav_learn')),
          NavigationDestination(icon: const Icon(Icons.insights_outlined), selectedIcon: const Icon(Icons.insights_rounded), label: context.tr('nav_progress')),
          NavigationDestination(icon: const Icon(Icons.work_outline_rounded), selectedIcon: const Icon(Icons.work_rounded), label: context.tr('nav_opportunities')),
          NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded), label: context.tr('nav_profile')),
        ],
      ),
    );
  }
}
