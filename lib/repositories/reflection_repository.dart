import 'package:flutter/foundation.dart';
import '../repositories/mood_repository.dart';

/// Repository responsible for AI reflection polling.
class ReflectionRepository {
  final MoodRepository _moodRepo = MoodRepository();

  // Singleton
  static final ReflectionRepository _instance =
      ReflectionRepository._internal();
  factory ReflectionRepository() => _instance;
  ReflectionRepository._internal();

  /// Polls the backend for AI reflection by re-fetching today's entry.
  /// Returns true if a reflection was found.
  Future<bool> pollForReflection({
    int maxAttempts = 5,
    Duration delay = const Duration(seconds: 3),
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(delay);

      final today = await _moodRepo.getTodayEntry();
      if (today != null &&
          today.aiReflection != null &&
          today.aiReflection!.isNotEmpty) {
        debugPrint('AI reflection received after ${attempt + 1} poll(s).');
        return true;
      }
    }
    debugPrint('AI reflection not received after $maxAttempts polls.');
    return false;
  }

  /// Check if today's entry already has a reflection.
  Future<bool> hasReflectionToday() async {
    final today = await _moodRepo.getTodayEntry();
    return today?.aiReflection != null && today!.aiReflection!.isNotEmpty;
  }
}
