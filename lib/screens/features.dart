import 'package:flutter/material.dart';

import 'communication_screen.dart';
import 'connectivity_screen.dart';
import 'digital_literacy_screen.dart';
import 'jobs_screen.dart';
import 'learn/learn_screen.dart';
import 'mentors_screen.dart';
import 'progress_screen.dart';
import 'research_screen.dart';
import 'resources_screen.dart';
import 'schemes_screen.dart';

/// Every service of the platform, mapped to the project requirements.
class Feature {
  final String key;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  const Feature(this.key, this.icon, this.color, this.builder);
}

final List<Feature> kFeatures = [
  Feature('f_study', Icons.play_lesson_rounded, const Color(0xFFEF6C00), (_) => const LearnScreen(standalone: true)),
  Feature('f_mentors', Icons.support_agent_rounded, const Color(0xFF8E24AA), (_) => const MentorsScreen()),
  Feature('f_progress', Icons.insights_rounded, const Color(0xFF1E88E5), (_) => const ProgressScreen(standalone: true)),
  Feature('f_digital', Icons.devices_rounded, const Color(0xFF00897B), (_) => const DigitalLiteracyScreen()),
  Feature('f_schemes', Icons.account_balance_rounded, const Color(0xFFC62828), (_) => const SchemesScreen()),
  Feature('f_connect', Icons.wifi_rounded, const Color(0xFF3949AB), (_) => const ConnectivityScreen()),
  Feature('f_jobs', Icons.work_rounded, const Color(0xFF6D4C41), (_) => const JobsScreen()),
  Feature('f_research', Icons.lightbulb_rounded, const Color(0xFFF9A825), (_) => const ResearchScreen()),
  Feature('f_resources', Icons.inventory_2_rounded, const Color(0xFF43A047), (_) => const ResourcesScreen()),
  Feature('f_communication', Icons.record_voice_over_rounded, const Color(0xFFD81B60), (_) => const CommunicationScreen()),
];

void openFeature(BuildContext context, Feature f) {
  Navigator.of(context).push(MaterialPageRoute(builder: f.builder));
}

Feature featureByKey(String key) => kFeatures.firstWhere((f) => f.key == key);
