import 'package:flutter_test/flutter_test.dart';
import 'package:major/core/strings.dart';

void main() {
  test('every UI string has English and Hindi text', () {
    for (final e in kStrings.entries) {
      expect(e.value['en'], isNotNull, reason: e.key);
      expect(e.value['hi'], isNotNull, reason: e.key);
    }
  });
}
