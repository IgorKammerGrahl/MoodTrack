import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../services/api_service.dart';
import 'sync_repository.dart';

/// Repository responsible for mood entry CRUD and per-user local cache.
class MoodRepository {
  static const String _baseMoodKey = 'mood_entries';

  final ApiService _api = ApiService();
  final SyncRepository _syncRepo = SyncRepository();

  // Singleton
  static final MoodRepository _instance = MoodRepository._internal();
  factory MoodRepository() => _instance;
  MoodRepository._internal();

  /// Per-user cache key
  String _keyForUser(String? userId) {
    if (userId == null || userId.isEmpty) return _baseMoodKey;
    return '${_baseMoodKey}_$userId';
  }

  /// Current userId helper (resolved externally before calls)
  String? _currentUserId;
  void setCurrentUserId(String? userId) => _currentUserId = userId;

  String get _key => _keyForUser(_currentUserId);

  /// Save a mood entry (one per day). Tries backend, queues on failure.
  Future<void> saveMoodEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllMoodEntries(forceLocal: true);

    final entryDate = DateFormat('yyyy-MM-dd').format(entry.date);
    entries.removeWhere((e) {
      final existingDate = DateFormat('yyyy-MM-dd').format(e.date);
      return existingDate == entryDate;
    });

    entries.add(entry);

    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));

    // Try backend, queue if offline
    try {
      await _api.post('/api/mood', entry.toJson());
      debugPrint('Registro salvo no backend com sucesso');
    } catch (e) {
      debugPrint('Erro ao salvar no backend (pode estar offline): $e');
      await _syncRepo.addPendingOperation({
        'type': 'mood_save',
        'data': entry.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Delete a mood entry by ID
  Future<void> deleteMoodEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllMoodEntries(forceLocal: true);

    entries.removeWhere((e) => e.id == id);

    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  /// Returns all mood entries, optionally syncing with backend.
  Future<List<MoodEntry>> getAllMoodEntries({bool forceLocal = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    List<MoodEntry> localEntries = [];
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      localEntries = jsonList.map((json) => MoodEntry.fromJson(json)).toList();
    }

    if (forceLocal) return localEntries;

    // Sync with backend via SyncRepository merge
    try {
      final dynamic response = await _api.get('/api/mood');
      if (response is List) {
        final backendEntries = response
            .map((json) => MoodEntry.fromJson(json))
            .toList();

        final mergedList = _syncRepo.mergeEntries(localEntries, backendEntries);

        final jsonList = mergedList.map((e) => e.toJson()).toList();
        await prefs.setString(_key, json.encode(jsonList));

        return mergedList;
      }
    } catch (e) {
      debugPrint('Erro ao buscar do backend (usando cache local): $e');
    }

    return localEntries;
  }

  /// Returns entries from the last N days
  Future<List<MoodEntry>> getRecentEntries(int days) async {
    final allEntries = await getAllMoodEntries();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return allEntries.where((entry) => entry.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Average mood for last N days
  Future<double> calculateAverageMood(int days) async {
    final entries = await getRecentEntries(days);
    if (entries.isEmpty) return 0.0;
    final sum = entries.fold<int>(0, (prev, entry) => prev + entry.moodLevel);
    return sum / entries.length;
  }

  /// Most frequent mood in last N days
  Future<int?> getMostFrequentMood(int days) async {
    final entries = await getRecentEntries(days);
    if (entries.isEmpty) return null;

    final frequency = <int, int>{};
    for (var entry in entries) {
      frequency[entry.moodLevel] = (frequency[entry.moodLevel] ?? 0) + 1;
    }
    return frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Check if there's an entry for today
  Future<MoodEntry?> getTodayEntry() async {
    final entries = await getAllMoodEntries();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      return entries.firstWhere((entry) {
        final entryDate = DateFormat('yyyy-MM-dd').format(entry.date);
        return entryDate == today;
      });
    } catch (e) {
      return null;
    }
  }

  /// Clear all mood data (used on logout)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
