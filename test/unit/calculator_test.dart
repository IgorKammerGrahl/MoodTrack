import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Logic Test', () {
    test('Calculator addition test', () {
      expect(1 + 1, 2);
    });

    test('String manipulation', () {
      String name = 'MoodTrack';
      expect(name.toLowerCase(), 'moodtrack');
    });
  });
}
