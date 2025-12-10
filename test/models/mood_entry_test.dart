import 'package:flutter_test/flutter_test.dart';
import 'package:moodtrack/models/mood_entry.dart';

void main() {
  group('MoodEntry', () {
    test('fromJson creates correct MoodEntry object', () {
      final json = {
        'id': '123',
        'date': '2023-10-27T10:00:00.000',
        'moodLevel': 5,
        'note': 'Feeling great',
      };

      final entry = MoodEntry.fromJson(json);

      expect(entry.id, '123');
      expect(entry.date.year, 2023);
      expect(entry.moodLevel, 5);
      expect(entry.note, 'Feeling great');
    });

    test('toJson creates correct map', () {
      final entry = MoodEntry(
        id: '123',
        date: DateTime(2023, 10, 27, 10, 0, 0),
        moodLevel: 5,
        note: 'Feeling great',
      );

      final json = entry.toJson();

      expect(json['id'], '123');
      expect(json['moodLevel'], 5);
      expect(json['note'], 'Feeling great');
    });
  });
}
