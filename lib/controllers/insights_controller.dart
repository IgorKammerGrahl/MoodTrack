import 'package:get/get.dart';
import '../models/mood_entry.dart';
import '../models/activity_correlation.dart';
import '../services/database_service.dart';

class InsightsController extends GetxController {
  final DatabaseService _db = DatabaseService();

  final RxList<MoodEntry> monthlyEntries = <MoodEntry>[].obs;
  final RxMap<int, int> moodDistribution = <int, int>{}.obs;
  final RxBool isLoading = false.obs;

  // Computed insights
  final RxDouble averageMood = 0.0.obs;
  final Rx<String?> bestDayOfWeek = Rx<String?>(null);
  final Rx<String?> bestTimeOfDay = Rx<String?>(null);
  final Rx<int?> emotionalCycleDays = Rx<int?>(null);
  final RxList<ActivityCorrelation> activityCorrelations =
      <ActivityCorrelation>[].obs;

  // Activity keyword definitions
  final Map<String, Map<String, String>> _activityDefinitions = {
    'caminhar': {'name': 'Caminhar', 'emoji': '🚶'},
    'caminhada': {'name': 'Caminhar', 'emoji': '🚶'},
    'exercício': {'name': 'Exerc\u00edcio', 'emoji': '💪'},
    'exercicio': {'name': 'Exerc\u00edcio', 'emoji': '💪'},
    'academia': {'name': 'Exerc\u00edcio', 'emoji': '💪'},
    'treino': {'name': 'Exerc\u00edcio', 'emoji': '💪'},
    'ler': {'name': 'Ler', 'emoji': '📚'},
    'leitura': {'name': 'Ler', 'emoji': '📚'},
    'livro': {'name': 'Ler', 'emoji': '📚'},
    'música': {'name': 'M\u00fasica', 'emoji': '🎵'},
    'musica': {'name': 'M\u00fasica', 'emoji': '🎵'},
    'ouvir': {'name': 'M\u00fasica', 'emoji': '🎵'},
    'amigos': {'name': 'Amigos', 'emoji': '👥'},
    'amigo': {'name': 'Amigos', 'emoji': '👥'},
    'trabalho': {'name': 'Trabalho', 'emoji': '💼'},
    'trabalhar': {'name': 'Trabalho', 'emoji': '💼'},
    'dormir': {'name': 'Dormir', 'emoji': '😴'},
    'sono': {'name': 'Dormir', 'emoji': '😴'},
    'meditar': {'name': 'Meditar', 'emoji': '🧘'},
    'meditação': {'name': 'Meditar', 'emoji': '🧘'},
    'meditacao': {'name': 'Meditar', 'emoji': '🧘'},
  };

  @override
  void onInit() {
    super.onInit();
    loadInsights();
  }

  Future<void> loadInsights() async {
    isLoading.value = true;
    try {
      // Load last 30 days from database
      final entries = await _db.getRecentEntries(30);
      monthlyEntries.value = entries;

      if (entries.isEmpty) {
        isLoading.value = false;
        return;
      }

      // Calculate all insights
      _calculateDistribution(entries);
      _calculateAverageMood(entries);
      _calculateBestDayOfWeek(entries);
      _calculateBestTimeOfDay(entries);
      _calculateEmotionalCycle(entries);
      _calculateActivityCorrelations(entries);
    } catch (e) {
      print('Erro ao carregar insights: $e');
      Get.snackbar('Erro', 'Falha ao carregar insights');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateDistribution(List<MoodEntry> entries) {
    final dist = <int, int>{};
    for (var entry in entries) {
      dist[entry.moodLevel] = (dist[entry.moodLevel] ?? 0) + 1;
    }
    moodDistribution.value = dist;
  }

  void _calculateAverageMood(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      averageMood.value = 0.0;
      return;
    }
    final sum = entries.fold<int>(0, (prev, entry) => prev + entry.moodLevel);
    averageMood.value = sum / entries.length;
  }

  void _calculateBestDayOfWeek(List<MoodEntry> entries) {
    if (entries.length < 7) {
      bestDayOfWeek.value = null;
      return;
    }

    // Group by weekday
    final weekdayMoods = <int, List<int>>{};
    for (var entry in entries) {
      final weekday = entry.date.weekday; // 1 = Monday, 7 = Sunday
      weekdayMoods[weekday] = (weekdayMoods[weekday] ?? [])
        ..add(entry.moodLevel);
    }

    // Calculate average for each weekday
    double bestAverage = 0;
    int bestDay = 1;
    weekdayMoods.forEach((weekday, moods) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      if (avg > bestAverage) {
        bestAverage = avg;
        bestDay = weekday;
      }
    });

    final dayNames = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    bestDayOfWeek.value =
        '${dayNames[bestDay - 1]} (${bestAverage.toStringAsFixed(1)}/5)';
  }

  void _calculateBestTimeOfDay(List<MoodEntry> entries) {
    if (entries.length < 3) {
      bestTimeOfDay.value = null;
      return;
    }

    // Group by time period
    final timePeriodMoods = <String, List<int>>{
      'Manhã': [],
      'Tarde': [],
      'Noite': [],
      'Madrugada': [],
    };

    for (var entry in entries) {
      final hour = entry.date.hour;
      String period;
      if (hour >= 6 && hour < 12) {
        period = 'Manhã';
      } else if (hour >= 12 && hour < 18) {
        period = 'Tarde';
      } else if (hour >= 18 && hour < 24) {
        period = 'Noite';
      } else {
        period = 'Madrugada';
      }
      timePeriodMoods[period]!.add(entry.moodLevel);
    }

    // Find best period with data
    double bestAverage = 0;
    String bestPeriod = 'Manhã';
    timePeriodMoods.forEach((period, moods) {
      if (moods.isNotEmpty) {
        final avg = moods.reduce((a, b) => a + b) / moods.length;
        if (avg > bestAverage) {
          bestAverage = avg;
          bestPeriod = period;
        }
      }
    });

    bestTimeOfDay.value = '$bestPeriod (${bestAverage.toStringAsFixed(1)}/5)';
  }

  void _calculateEmotionalCycle(List<MoodEntry> entries) {
    if (entries.length < 14) {
      emotionalCycleDays.value = null;
      return;
    }

    // Sort by date (oldest first)
    final sorted = entries.toList()..sort((a, b) => a.date.compareTo(b.date));

    // Find peaks (local maxima)
    List<int> peakIndices = [];
    for (int i = 1; i < sorted.length - 1; i++) {
      if (sorted[i].moodLevel > sorted[i - 1].moodLevel &&
          sorted[i].moodLevel > sorted[i + 1].moodLevel &&
          sorted[i].moodLevel >= 4) {
        peakIndices.add(i);
      }
    }

    if (peakIndices.length < 2) {
      emotionalCycleDays.value = null;
      return;
    }

    // Calculate average days between peaks
    List<int> daysBetweenPeaks = [];
    for (int i = 1; i < peakIndices.length; i++) {
      final days = sorted[peakIndices[i]].date
          .difference(sorted[peakIndices[i - 1]].date)
          .inDays;
      daysBetweenPeaks.add(days);
    }

    final avgCycle =
        daysBetweenPeaks.reduce((a, b) => a + b) / daysBetweenPeaks.length;

    // Only report if cycle is between 3-14 days (sensible emotional cycle range)
    if (avgCycle >= 3 && avgCycle <= 14) {
      emotionalCycleDays.value = avgCycle.round();
    } else {
      emotionalCycleDays.value = null;
    }
  }

  void _calculateActivityCorrelations(List<MoodEntry> entries) {
    if (entries.isEmpty || averageMood.value == 0) {
      activityCorrelations.value = [];
      return;
    }

    final overallAverage = averageMood.value;
    final Map<String, List<int>> activityMoods = {};

    // Group entries by activity (using canonical name)
    for (var entry in entries) {
      final note = entry.note?.toLowerCase() ?? '';
      if (note.isEmpty) continue;

      // Check each keyword
      for (var keyword in _activityDefinitions.keys) {
        if (note.contains(keyword)) {
          final displayName = _activityDefinitions[keyword]!['name']!;
          activityMoods[displayName] = (activityMoods[displayName] ?? [])
            ..add(entry.moodLevel);
        }
      }
    }

    // Calculate correlations
    final correlations = <ActivityCorrelation>[];

    for (var entry in activityMoods.entries) {
      final activityName = entry.key;
      final moods = entry.value;

      // Require at least 3 occurrences for statistical significance
      if (moods.length < 3) continue;

      final avgMood = moods.reduce((a, b) => a + b) / moods.length;
      final impact = ((avgMood - overallAverage) / overallAverage) * 100;

      // Find emoji (from first matching keyword)
      String emoji = '📌';
      for (var keyword in _activityDefinitions.keys) {
        if (_activityDefinitions[keyword]!['name'] == activityName) {
          emoji = _activityDefinitions[keyword]!['emoji']!;
          break;
        }
      }

      correlations.add(
        ActivityCorrelation(
          keyword: activityName.toLowerCase(),
          displayName: activityName,
          emoji: emoji,
          occurrences: moods.length,
          averageMood: avgMood,
          impactPercentage: impact,
        ),
      );
    }

    // Sort by impact (highest positive first)
    correlations.sort(
      (a, b) => b.impactPercentage.compareTo(a.impactPercentage),
    );

    // Take top 5
    activityCorrelations.value = correlations.take(5).toList();
  }

  // Helper to get percentage for pie chart
  double getPercentage(int moodLevel) {
    final total = moodDistribution.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    if (total == 0) return 0;
    return ((moodDistribution[moodLevel] ?? 0) / total * 100);
  }
}
