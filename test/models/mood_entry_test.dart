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
        'emoji': '😄',
        'color': 'A8D5FF',
      };

      final entry = MoodEntry.fromJson(json);

      expect(entry.id, '123');
      expect(entry.date.year, 2023);
      expect(entry.moodLevel, 5);
      expect(entry.note, 'Feeling great');
      expect(entry.emoji, '😄');
      expect(entry.colorHex, 'A8D5FF');
    });

    test('fromJson uses computed emoji/color when not in JSON', () {
      final json = {
        'id': '456',
        'date': '2023-10-27T10:00:00.000',
        'moodLevel': 1,
        'note': 'Bad day',
      };

      final entry = MoodEntry.fromJson(json);

      expect(entry.emoji, '😢');
      expect(entry.colorHex, 'FFC1C1');
    });

    test('toJson creates correct map with emoji and color', () {
      final entry = MoodEntry(
        id: '123',
        date: DateTime(2023, 10, 27, 10, 0, 0),
        moodLevel: 5,
        note: 'Feeling great',
      );

      final json = entry.toJson();

      // id should NOT be in toJson (backend generates UUID)
      expect(json.containsKey('id'), false);
      expect(json['moodLevel'], 5);
      expect(json['note'], 'Feeling great');
      // emoji and color should be serialized
      expect(json['emoji'], '😄');
      expect(json['color'], 'A8D5FF');
    });

    test('toJson uses stored emoji/color when provided', () {
      final entry = MoodEntry(
        id: '789',
        date: DateTime(2023, 10, 27, 10, 0, 0),
        moodLevel: 3,
        note: 'OK day',
        emoji: '🤔',
        colorHex: 'CUSTOM1',
      );

      final json = entry.toJson();

      expect(json['emoji'], '🤔');
      expect(json['color'], 'CUSTOM1');
    });
  });
}
