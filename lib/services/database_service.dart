import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import 'api_service.dart';

/// Serviço responsável por salvar e recuperar dados localmente e sincronizar com o backend
class DatabaseService {
  static const String _keyMoodEntries = 'mood_entries';

  // API Service integration
  final ApiService _api = ApiService();

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Salva um novo registro de humor (apenas 1 por dia)
  Future<void> saveMoodEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();

    // Busca registros existentes
    final entries = await getAllMoodEntries(forceLocal: true);

    // Formata a data do novo registro (sem hora)
    final entryDate = DateFormat('yyyy-MM-dd').format(entry.date);

    // Remove qualquer registro do mesmo dia (se existir)
    entries.removeWhere((e) {
      final existingDate = DateFormat('yyyy-MM-dd').format(e.date);
      return existingDate == entryDate;
    });

    // Adiciona o novo registro
    entries.add(entry);

    // Converte para JSON e salva localmente
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_keyMoodEntries, json.encode(jsonList));

    // Tenta salvar no backend também
    try {
      await _api.post('/api/mood', entry.toJson());
      debugPrint('Registro salvo no backend com sucesso');
    } catch (e) {
      debugPrint('Erro ao salvar no backend (pode estar offline): $e');
    }
  }

  /// Deleta um registro de humor pelo ID
  Future<void> deleteMoodEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllMoodEntries(forceLocal: true);

    entries.removeWhere((e) => e.id == id);

    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_keyMoodEntries, json.encode(jsonList));
  }

  /// Retorna todos os registros de humor
  /// [forceLocal] se true, não tenta buscar do backend (útil para operações internas)
  Future<List<MoodEntry>> getAllMoodEntries({bool forceLocal = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMoodEntries);

    // Lista local
    List<MoodEntry> localEntries = [];
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      localEntries = jsonList.map((json) => MoodEntry.fromJson(json)).toList();
    }

    if (forceLocal) return localEntries;

    // Tenta buscar do backend para sincronizar
    try {
      final dynamic response = await _api.get('/api/mood');
      if (response is List) {
        // Mapeia resposta do backend
        final backendEntries = response
            .map((json) => MoodEntry.fromJson(json))
            .toList();

        // Timestamp-based merge: newer updated_at wins
        final Map<String, MoodEntry> mergedMap = {};

        for (var entry in localEntries) {
          mergedMap[entry.id] = entry;
        }

        for (var entry in backendEntries) {
          final existing = mergedMap[entry.id];
          if (existing == null) {
            mergedMap[entry.id] = entry;
          } else if (entry.updatedAt != null && existing.updatedAt != null) {
            // Newer timestamp wins
            if (entry.updatedAt!.isAfter(existing.updatedAt!)) {
              mergedMap[entry.id] = entry;
            }
          } else {
            // Fallback: backend wins if no timestamps
            mergedMap[entry.id] = entry;
          }
        }

        final mergedList = mergedMap.values.toList();

        // Always persist merged result to keep local cache in sync
        // (e.g., backend may have added aiReflection to an existing entry)
        final jsonList = mergedList.map((e) => e.toJson()).toList();
        await prefs.setString(_keyMoodEntries, json.encode(jsonList));

        return mergedList;
      }
    } catch (e) {
      debugPrint('Erro ao buscar do backend (usando cache local): $e');
    }

    return localEntries;
  }

  /// Retorna registros dos últimos N dias
  Future<List<MoodEntry>> getRecentEntries(int days) async {
    final allEntries = await getAllMoodEntries();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return allEntries.where((entry) => entry.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Mais recentes primeiro
  }

  /// Calcula a média de humor dos últimos N dias
  Future<double> calculateAverageMood(int days) async {
    final entries = await getRecentEntries(days);

    if (entries.isEmpty) return 0.0;

    final sum = entries.fold<int>(0, (prev, entry) => prev + entry.moodLevel);
    return sum / entries.length;
  }

  /// Retorna o humor mais frequente dos últimos N dias
  Future<int?> getMostFrequentMood(int days) async {
    final entries = await getRecentEntries(days);

    if (entries.isEmpty) return null;

    // Conta a frequência de cada humor
    final frequency = <int, int>{};
    for (var entry in entries) {
      frequency[entry.moodLevel] = (frequency[entry.moodLevel] ?? 0) + 1;
    }

    // Retorna o humor com maior frequência
    return frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Verifica se já existe um registro para hoje
  Future<MoodEntry?> getTodayEntry() async {
    final entries = await getAllMoodEntries();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      return entries.firstWhere((entry) {
        final entryDate = DateFormat('yyyy-MM-dd').format(entry.date);
        return entryDate == today;
      });
    } catch (e) {
      return null; // Não encontrou registro de hoje
    }
  }

  /// Limpa todos os dados (útil para testes)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMoodEntries);
    // Limpa também históricos de chat se houver chaves dinâmicas
    // Nota: Isso não limpa chaves de chat específicas por usuário a menos que iteremos.
    // Para simplificar, vamos assumir que isso é apenas para debug de humor por enquanto.
  }

  // --- Notification Preferences ---

  static const String _keyDailyReminderEnabled = 'daily_reminder_enabled';
  static const String _keyDailyReminderTime = 'daily_reminder_time'; // "HH:mm"
  static const String _keyWeeklyInsightEnabled = 'weekly_insight_enabled';
  static const String _keyWeeklyInsightDay =
      'weekly_insight_day'; // 1-7 (Mon-Sun)

  Future<void> saveNotificationPreferences({
    required bool dailyEnabled,
    required String dailyTime,
    required bool weeklyEnabled,
    required int weeklyDay,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyReminderEnabled, dailyEnabled);
    await prefs.setString(_keyDailyReminderTime, dailyTime);
    await prefs.setBool(_keyWeeklyInsightEnabled, weeklyEnabled);
    await prefs.setInt(_keyWeeklyInsightDay, weeklyDay);
  }

  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'dailyEnabled': prefs.getBool(_keyDailyReminderEnabled) ?? false,
      'dailyTime': prefs.getString(_keyDailyReminderTime) ?? '20:00',
      'weeklyEnabled': prefs.getBool(_keyWeeklyInsightEnabled) ?? false,
      'weeklyDay': prefs.getInt(_keyWeeklyInsightDay) ?? DateTime.sunday,
    };
  }

  // --- Accessibility Preferences ---

  static const String _keyFontSizeScale = 'font_size_scale';
  static const String _keyHighContrast = 'high_contrast';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyVisualDifficulty = 'visual_difficulty';

  Future<void> saveAccessibilityPreferences({
    required double fontSizeScale,
    required bool highContrast,
    required bool darkMode,
    required bool visualDifficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSizeScale, fontSizeScale);
    await prefs.setBool(_keyHighContrast, highContrast);
    await prefs.setBool(_keyDarkMode, darkMode);
    await prefs.setBool(_keyVisualDifficulty, visualDifficulty);
  }

  Future<Map<String, dynamic>> getAccessibilityPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fontSizeScale': prefs.getDouble(_keyFontSizeScale) ?? 1.0,
      'highContrast': prefs.getBool(_keyHighContrast) ?? false,
      'darkMode': prefs.getBool(_keyDarkMode) ?? false,
      'visualDifficulty': prefs.getBool(_keyVisualDifficulty) ?? false,
    };
  }

  // --- Chat History ---

  String _getChatHistoryKey(String userId) => 'chat_history_$userId';

  Future<void> saveChatHistory(String userId, List<dynamic> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getChatHistoryKey(userId);

    // Limit to last 50 messages
    final limitedMessages = messages.length > 50
        ? messages.sublist(messages.length - 50)
        : messages;

    final jsonList = limitedMessages.map((m) => m.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }

  Future<List<dynamic>> getChatHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getChatHistoryKey(userId);
    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    // Retorna a lista de mapas (JSONs), a conversão para objeto será feita no Controller/Model
    return jsonList;
  }
}
