import 'package:flutter_test/flutter_test.dart';
import 'package:moodtrack/domain/streak_calculator.dart';
import 'package:moodtrack/models/mood_entry.dart';

void main() {
  group('StreakCalculator', () {
    MoodEntry entry(DateTime date) =>
        MoodEntry(id: date.toIso8601String(), date: date, moodLevel: 3);

    test('returns 0 for empty list', () {
      expect(StreakCalculator.calculateStreak([]), 0);
    });

    test('returns 1 for a single entry today', () {
      final entries = [entry(DateTime.now())];
      expect(StreakCalculator.calculateStreak(entries), 1);
    });

    test('returns 1 for a single entry yesterday', () {
      final entries = [
        entry(DateTime.now().subtract(const Duration(days: 1))),
      ];
      expect(StreakCalculator.calculateStreak(entries), 1);
    });

    test('returns 0 for a single entry 2 days ago (streak broken)', () {
      final entries = [
        entry(DateTime.now().subtract(const Duration(days: 2))),
      ];
      expect(StreakCalculator.calculateStreak(entries), 0);
    });

    test('counts consecutive days correctly', () {
      final now = DateTime.now();
      final entries = [
        entry(now),
        entry(now.subtract(const Duration(days: 1))),
        entry(now.subtract(const Duration(days: 2))),
        entry(now.subtract(const Duration(days: 3))),
      ];
      expect(StreakCalculator.calculateStreak(entries), 4);
    });

    test('stops at gap', () {
      final now = DateTime.now();
      final entries = [
        entry(now),
        entry(now.subtract(const Duration(days: 1))),
        // gap at day 2
        entry(now.subtract(const Duration(days: 3))),
        entry(now.subtract(const Duration(days: 4))),
      ];
      expect(StreakCalculator.calculateStreak(entries), 2);
    });

    test('handles multiple entries on the same day', () {
      final now = DateTime.now();
      final entries = [
        entry(now),
        entry(now.subtract(const Duration(hours: 3))), // same day
        entry(now.subtract(const Duration(days: 1))),
      ];
      expect(StreakCalculator.calculateStreak(entries), 2);
    });

    test('streak from yesterday without today still counts', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final entries = [
        entry(yesterday),
        entry(yesterday.subtract(const Duration(days: 1))),
        entry(yesterday.subtract(const Duration(days: 2))),
      ];
      expect(StreakCalculator.calculateStreak(entries), 3);
    });
  });
}
