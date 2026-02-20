import 'package:intl/intl.dart';
import '../models/mood_entry.dart';

/// Pure function to calculate the current daily streak from mood entries.
class StreakCalculator {
  /// Calculates consecutive days of mood logging.
  /// [entries] should be sorted descending by date (most recent first).
  /// Returns 0 if no entries or streak is broken.
  static int calculateStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    // Get unique days sorted descending
    final uniqueDays =
        entries
            .map((e) => DateFormat('yyyy-MM-dd').format(e.date))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(const Duration(days: 1)));

    // Streak must start from today or yesterday
    if (uniqueDays.first != today && uniqueDays.first != yesterday) {
      return 0;
    }

    int streak = 1;
    for (int i = 1; i < uniqueDays.length; i++) {
      final curr = DateTime.parse(uniqueDays[i - 1]);
      final prev = DateTime.parse(uniqueDays[i]);
      final diff = curr.difference(prev).inDays;

      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
