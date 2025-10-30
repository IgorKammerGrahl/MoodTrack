import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';

/// Serviço responsável por salvar e recuperar dados localmente
class DatabaseService {
  static const String _keyMoodEntries = 'mood_entries';

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Salva um novo registro de humor (apenas 1 por dia)
  Future<void> saveMoodEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();

    // Busca registros existentes
    final entries = await getAllMoodEntries();

    // Formata a data do novo registro (sem hora)
    final entryDate = DateFormat('yyyy-MM-dd').format(entry.date);

    // Remove qualquer registro do mesmo dia (se existir)
    entries.removeWhere((e) {
      final existingDate = DateFormat('yyyy-MM-dd').format(e.date);
      return existingDate == entryDate;
    });

    // Adiciona o novo registro
    entries.add(entry);

    // Converte para JSON e salva
    final jsonList = entries.map((e) => e.toMap()).toList();
    await prefs.setString(_keyMoodEntries, json.encode(jsonList));
  }

  /// Retorna todos os registros de humor
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMoodEntries);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => MoodEntry.fromMap(json)).toList();
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
  }
}
