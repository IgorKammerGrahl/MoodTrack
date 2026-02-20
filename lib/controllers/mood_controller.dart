import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../services/database_service.dart';

const _uuid = Uuid();

class MoodController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final RxList<MoodEntry> todayEntries = <MoodEntry>[].obs;
  final RxList<MoodEntry> recentEntries = <MoodEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isReflectionLoading = false.obs;

  // New Entry State
  final RxInt selectedMoodLevel = 0.obs;
  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchTodayEntries();
    fetchRecentEntries();
  }

  Future<void> fetchTodayEntries() async {
    try {
      final today = await _db.getTodayEntry();
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
      final recent = await _db.getRecentEntries(30);
      recentEntries.assignAll(recent);
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
    }
  }

  Future<void> addEntry() async {
    if (selectedMoodLevel.value == 0) {
      Get.snackbar('Atenção', 'Selecione como você está se sentindo');
      return;
    }

    isLoading.value = true;
    try {
      // 1. Create and save base entry immediately
      final baseEntry = MoodEntry(
        id: _uuid.v4(),
        date: DateTime.now(),
        moodLevel: selectedMoodLevel.value,
        note: noteController.text,
      );

      final isUpdate = todayEntries.isNotEmpty;

      await _db.saveMoodEntry(baseEntry);

      // 2. Update local state to show "Registered View"
      await fetchTodayEntries();
      await fetchRecentEntries();

      // 3. Reset form
      selectedMoodLevel.value = 0;
      noteController.clear();
      isLoading.value = false; // Stop loading on the form

      Get.snackbar(
        'Sucesso',
        isUpdate ? 'Humor atualizado!' : 'Humor registrado!',
      );

      // 4. Poll for backend-generated AI reflection
      _pollForReflection();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erro', 'Falha ao registrar humor');
    }
  }

  /// Polls the backend for the AI reflection that is generated server-side.
  /// Re-fetches today's entry up to [maxAttempts] times, waiting [delay]
  /// between each attempt, until the reflection field is populated.
  Future<void> _pollForReflection({
    int maxAttempts = 5,
    Duration delay = const Duration(seconds: 3),
  }) async {
    isReflectionLoading.value = true;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(delay);
      await fetchTodayEntries();

      // Check if the reflection has arrived
      if (todayEntries.isNotEmpty &&
          todayEntries.first.aiReflection != null &&
          todayEntries.first.aiReflection!.isNotEmpty) {
        debugPrint('AI reflection received after ${attempt + 1} poll(s).');
        isReflectionLoading.value = false;
        return;
      }
    }
    debugPrint('AI reflection not received after $maxAttempts polls.');
    isReflectionLoading.value = false;
  }

  void selectMood(int level) {
    selectedMoodLevel.value = level;
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _db.deleteMoodEntry(id);
      await fetchTodayEntries();
      await fetchRecentEntries();
      Get.snackbar('Sucesso', 'Registro removido');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover registro');
    }
  }
}
