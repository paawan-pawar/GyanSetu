import 'package:flutter_test/flutter_test.dart';
import 'package:major/core/app_state.dart';
import 'package:major/core/data_repository.dart';
import 'package:major/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final s = AppState();
  await tester.runAsync(() async {
    await s.load();
    await DataRepository.instance.load();
  });
  await tester.pumpWidget(ChangeNotifierProvider.value(value: s, child: const GyanSetuApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first launch shows onboarding and switches to Hindi', (tester) async {
    await pumpApp(tester, {});
    expect(find.text('Choose your language'), findsOneWidget);
    await tester.tap(find.text('हि'));
    await tester.pumpAndSettle();
    expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
  });

  testWidgets('returning learner lands on the home dashboard', (tester) async {
    await pumpApp(tester, {'onboarded': true, 'userName': 'Ravi', 'lang': 'en'});
    expect(find.textContaining('Namaste, Ravi'), findsOneWidget);
    expect(find.text('Explore services'), findsOneWidget);
  });
}
