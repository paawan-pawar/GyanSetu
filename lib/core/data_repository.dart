import 'dart:convert';

import 'package:flutter/services.dart';

typedef Json = Map<String, dynamic>;

/// Loads the bundled bilingual demo datasets from assets/data.
class DataRepository {
  DataRepository._();
  static final DataRepository instance = DataRepository._();

  late List<Json> categories;
  late List<Json> courses;
  late List<Json> mentors;
  late List<Json> schemes;
  late List<Json> jobs;
  late List<Json> programs;
  late List<Json> hotspots;
  late List<Json> dataPacks;
  late List<Json> projects;
  late List<Json> surveys;
  late List<Json> resources;
  late List<Json> eLibrary;
  late List<Json> phrases;
  late List<Json> words;
  late List<Json> digitalChecklist;
  late List<Json> safetyTips;

  bool _loaded = false;

  Future<Json> _read(String name) async =>
      jsonDecode(await rootBundle.loadString('assets/data/$name.json')) as Json;

  List<Json> _l(Json j, String k) => (j[k] as List).cast<Json>();

  Future<void> load() async {
    if (_loaded) return;
    final c = await _read('courses');
    categories = _l(c, 'categories');
    courses = _l(c, 'courses');
    mentors = _l(await _read('mentors'), 'mentors');
    schemes = _l(await _read('schemes'), 'schemes');
    jobs = _l(await _read('jobs'), 'jobs');
    final con = await _read('connectivity');
    programs = _l(con, 'programs');
    hotspots = _l(con, 'hotspots');
    dataPacks = _l(con, 'dataPacks');
    final r = await _read('research');
    projects = _l(r, 'projects');
    surveys = _l(r, 'surveys');
    final res = await _read('resources');
    resources = _l(res, 'resources');
    eLibrary = _l(res, 'eLibrary');
    final com = await _read('communication');
    phrases = _l(com, 'phrases');
    words = _l(com, 'words');
    digitalChecklist = _l(com, 'digitalChecklist');
    safetyTips = _l(com, 'safetyTips');
    _loaded = true;
  }

  Json? mentor(String id) => mentors.where((m) => m['id'] == id).firstOrNull;
  Json? course(String id) => courses.where((m) => m['id'] == id).firstOrNull;
  Json category(String id) => categories.firstWhere((m) => m['id'] == id);
  List<Json> coursesIn(String cat) => courses.where((c) => c['category'] == cat).toList();
}
