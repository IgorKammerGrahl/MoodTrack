import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../repositories/mood_repository.dart';
import '../repositories/reflection_repository.dart';
import '../services/auth_service.dart';

const _uuid = Uuid();

class MoodController extends GetxController {
  final MoodRepository _moodRepo = MoodRepository();
  final ReflectionRepository _reflectionRepo = ReflectionRepository();
  final RxList<MoodEntry> todayEntries = <MoodEntry>[].obs;
  final RxList<MoodEntry> recentEntries = <MoodEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isReflectionLoading = false.obs;
  final RxInt currentStreak = 0.obs;

  // New Entry State
  final RxInt selectedMoodLevel = 0.obs;
  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _setUserScope();
    fetchTodayEntries();
    fetchRecentEntries();
  }

  /// Sets user scope on the repository for per-user cache isolation.
  void _setUserScope() {
    try {
      final auth = Get.find<AuthService>();
      _moodRepo.setCurrentUserId(auth.currentUser.value?.id);
    } catch (_) {
      _moodRepo.setCurrentUserId(null);
    }
  }

  Future<void> fetchTodayEntries() async {
    try {
      final today = await _moodRepo.getTodayEntry();
      todayEntries.clear();
      if (today != null) {
        todayEntries.add(today);
      }
    } catch (e) {
      debugPrint('Erro ao buscar registros de hoje: $e');
    }
  }

  Future<void> fetchRecentEntries() async {
    try {
      final recent = await _moodRepo.getRecentEntries(30);
      recentEntries.assignAll(recent);
      _updateStreak(recent);
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
    }
  }

  /// Compute the current daily streak from recent entries.
  void _updateStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      currentStreak.value = 0;
      return;
    }

    // Get unique days sorted descending
    final uniqueDays =
        entries
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    // Streak must include today or yesterday
    if (uniqueDays.isEmpty) {
      currentStreak.value = 0;
      return;
    }

    final firstDay = uniqueDays.first;
    final diffFromToday = todayNorm.difference(firstDay).inDays;
    if (diffFromToday > 1) {
      currentStreak.value = 0;
      return;
    }

    int streak = 1;
    for (int i = 1; i < uniqueDays.length; i++) {
      final diff = uniqueDays[i - 1].difference(uniqueDays[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    currentStreak.value = streak;
  }

  Future<void> addEntry() async {
    if (selectedMoodLevel.value == 0) {
      Get.snackbar('Atenção', 'Selecione como você está se sentindo');
      return;
    }

    isLoading.value = true;
    try {
      final baseEntry = MoodEntry(
        id: _uuid.v4(),
        date: DateTime.now(),
        moodLevel: selectedMoodLevel.value,
        note: noteController.text,
      );

      final isUpdate = todayEntries.isNotEmpty;

      await _moodRepo.saveMoodEntry(baseEntry);

      await fetchTodayEntries();
      await fetchRecentEntries();

      selectedMoodLevel.value = 0;
      noteController.clear();
      isLoading.value = false;

      Get.snackbar(
        'Sucesso',
        isUpdate ? 'Humor atualizado!' : 'Humor registrado!',
      );

      _pollForReflection();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erro', 'Falha ao registrar humor');
    }
  }

  /// Polls the backend for AI reflection via ReflectionRepository
  Future<void> _pollForReflection() async {
    isReflectionLoading.value = true;
    final found = await _reflectionRepo.pollForReflection();
    if (found) {
      await fetchTodayEntries();
    }
    isReflectionLoading.value = false;
  }

  void selectMood(int level) {
    selectedMoodLevel.value = level;
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _moodRepo.deleteMoodEntry(id);
      await fetchTodayEntries();
      await fetchRecentEntries();
      Get.snackbar('Sucesso', 'Registro removido');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover registro');
    }
  }
}
