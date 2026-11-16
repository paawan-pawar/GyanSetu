import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global app state: language, user profile, and every piece of
/// learner activity. Persisted locally so the app works offline.
class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool ready = false;

  String lang = 'en';
  bool darkMode = false;
  bool lowData = false;
  bool onboarded = false;
  String userName = '';
  String village = '';
  String role = 'student';
  String phone = '';
  String education = '';

  Set<String> completedLessons = {}; // "courseId:lessonId"
  Map<String, int> quizScores = {}; // courseId -> best %
  Set<String> savedSchemes = {};
  Set<String> appliedJobs = {};
  Set<String> requestedResources = {};
  Set<String> claimedPacks = {};
  Set<String> digitalChecklist = {};
  Set<String> joinedProjects = {};
  Set<String> knownWords = {};
  Map<String, int> surveyAnswers = {};
  Set<String> activeDays = {}; // yyyy-MM-dd
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> doubts = [];
  List<Map<String, dynamic>> ideas = [];
  bool deviceRequested = false;

  bool get isHindi => lang == 'hi';

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    lang = p.getString('lang') ?? 'en';
    darkMode = p.getBool('dark') ?? false;
    lowData = p.getBool('lowData') ?? false;
    onboarded = p.getBool('onboarded') ?? false;
    userName = p.getString('userName') ?? '';
    village = p.getString('village') ?? '';
    role = p.getString('role') ?? 'student';
    phone = p.getString('phone') ?? '';
    education = p.getString('education') ?? '';
    deviceRequested = p.getBool('deviceRequested') ?? false;
    completedLessons = _set('completedLessons');
    savedSchemes = _set('savedSchemes');
    appliedJobs = _set('appliedJobs');
    requestedResources = _set('requestedResources');
    claimedPacks = _set('claimedPacks');
    digitalChecklist = _set('digitalChecklist');
    joinedProjects = _set('joinedProjects');
    knownWords = _set('knownWords');
    activeDays = _set('activeDays');
    quizScores = _intMap('quizScores');
    surveyAnswers = _intMap('surveyAnswers');
    bookings = _list('bookings');
    doubts = _list('doubts');
    ideas = _list('ideas');
    if (ideas.isEmpty) {
      ideas = [
        {'name': 'Kavita', 'text': 'Evening reading circle for women at the Panchayat Bhawan', 'likes': 24},
        {'name': 'Arjun', 'text': 'Share one old smartphone per lane for children\'s online classes', 'likes': 17},
      ];
    }
    ready = true;
    notifyListeners();
  }

  Set<String> _set(String k) => (_prefs!.getStringList(k) ?? []).toSet();
  Map<String, int> _intMap(String k) {
    final s = _prefs!.getString(k);
    if (s == null) return {};
    return (jsonDecode(s) as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int));
  }

  List<Map<String, dynamic>> _list(String k) {
    final s = _prefs!.getString(k);
    if (s == null) return [];
    return (jsonDecode(s) as List).cast<Map<String, dynamic>>();
  }

  void _saveSet(String k, Set<String> v) => _prefs?.setStringList(k, v.toList());
  void _saveJson(String k, Object v) => _prefs?.setString(k, jsonEncode(v));

  void _touch() {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (activeDays.add(key)) _saveSet('activeDays', activeDays);
  }

  // ---------- Settings & profile ----------
  void setLang(String l) {
    lang = l;
    _prefs?.setString('lang', l);
    notifyListeners();
  }

  void toggleLang() => setLang(isHindi ? 'en' : 'hi');

  void setDark(bool v) {
    darkMode = v;
    _prefs?.setBool('dark', v);
    notifyListeners();
  }

  void setLowData(bool v) {
    lowData = v;
    _prefs?.setBool('lowData', v);
    notifyListeners();
  }

  void saveProfile({required String name, required String village, required String role, String? phone, String? education}) {
    userName = name;
    this.village = village;
    this.role = role;
    if (phone != null) this.phone = phone;
    if (education != null) this.education = education;
    onboarded = true;
    final p = _prefs;
    p?.setString('userName', name);
    p?.setString('village', village);
    p?.setString('role', role);
    p?.setString('phone', this.phone);
    p?.setString('education', this.education);
    p?.setBool('onboarded', true);
    _touch();
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _prefs?.clear();
    final keepLang = lang;
    await load();
    setLang(keepLang);
  }

  // ---------- Learning ----------
  bool isLessonDone(String courseId, String lessonId) => completedLessons.contains('$courseId:$lessonId');

  int doneCount(String courseId) => completedLessons.where((e) => e.startsWith('$courseId:')).length;

  void toggleLesson(String courseId, String lessonId) {
    final k = '$courseId:$lessonId';
    if (!completedLessons.remove(k)) completedLessons.add(k);
    _saveSet('completedLessons', completedLessons);
    _touch();
    notifyListeners();
  }

  void completeLesson(String courseId, String lessonId) {
    if (completedLessons.add('$courseId:$lessonId')) {
      _saveSet('completedLessons', completedLessons);
      _touch();
      notifyListeners();
    }
  }

  void recordQuiz(String courseId, int percent) {
    final prev = quizScores[courseId] ?? 0;
    if (percent >= prev) quizScores[courseId] = percent;
    _saveJson('quizScores', quizScores);
    _touch();
    notifyListeners();
  }

  int get streak {
    int s = 0;
    var d = DateTime.now();
    while (true) {
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (!activeDays.contains(key)) break;
      s++;
      d = d.subtract(const Duration(days: 1));
    }
    return s;
  }

  // ---------- Generic toggles ----------
  bool toggleIn(Set<String> set, String key, String id) {
    final added = set.add(id);
    if (!added) set.remove(id);
    _saveSet(key, set);
    _touch();
    notifyListeners();
    return added;
  }

  void addTo(Set<String> set, String key, String id) {
    if (set.add(id)) {
      _saveSet(key, set);
      _touch();
      notifyListeners();
    }
  }

  void toggleScheme(String id) => toggleIn(savedSchemes, 'savedSchemes', id);
  void applyJob(String id) => addTo(appliedJobs, 'appliedJobs', id);
  void requestResource(String id) => addTo(requestedResources, 'requestedResources', id);
  void claimPack(String id) => addTo(claimedPacks, 'claimedPacks', id);
  void toggleChecklist(String id) => toggleIn(digitalChecklist, 'digitalChecklist', id);
  void joinProject(String id) => addTo(joinedProjects, 'joinedProjects', id);
  void toggleWord(String w) => toggleIn(knownWords, 'knownWords', w);

  void answerSurvey(String id, int option) {
    surveyAnswers[id] = option;
    _saveJson('surveyAnswers', surveyAnswers);
    _touch();
    notifyListeners();
  }

  void requestDevice() {
    deviceRequested = true;
    _prefs?.setBool('deviceRequested', true);
    notifyListeners();
  }

  void addBooking(Map<String, dynamic> b) {
    bookings.insert(0, b);
    _saveJson('bookings', bookings);
    _touch();
    notifyListeners();
  }

  void addDoubt(Map<String, dynamic> d) {
    doubts.insert(0, d);
    _saveJson('doubts', doubts);
    _touch();
    notifyListeners();
  }

  void addIdea(String text) {
    ideas.insert(0, {'name': userName.isEmpty ? 'You' : userName, 'text': text, 'likes': 0, 'mine': true});
    _saveJson('ideas', ideas);
    _touch();
    notifyListeners();
  }

  void likeIdea(int i) {
    ideas[i]['likes'] = (ideas[i]['likes'] as int) + 1;
    _saveJson('ideas', ideas);
    notifyListeners();
  }
}
