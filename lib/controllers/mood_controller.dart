import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/mood_entry.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';

class MoodController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final GeminiService _geminiService = Get.put(GeminiService());
  final RxList<MoodEntry> todayEntries = <MoodEntry>[].obs;
  final RxList<MoodEntry> recentEntries = <MoodEntry>[].obs;
  final RxBool isLoading = false.obs;

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
      print('Erro ao buscar registros de hoje: $e');
    }
  }

  Future<void> fetchRecentEntries() async {
    try {
      final recent = await _db.getRecentEntries(30);
      recentEntries.assignAll(recent);
    } catch (e) {
      print('Erro ao buscar histórico: $e');
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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

      // 4. Generate Reflection in background
      _generateAndSaveReflection(baseEntry);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erro', 'Falha ao registrar humor');
    }
  }

  Future<void> _generateAndSaveReflection(MoodEntry baseEntry) async {
    try {
      // Simulate network delay for effect if needed, or just call service
      // await Future.delayed(Duration(seconds: 2));

      final reflection = await _geminiService.getReflection(
        baseEntry.moodDescription,
        baseEntry.note ?? '',
      );

      final updatedEntry = MoodEntry(
        id: baseEntry.id,
        date: baseEntry.date,
        moodLevel: baseEntry.moodLevel,
        note: baseEntry.note,
        aiReflection: reflection,
        reflectionGeneratedAt: DateTime.now(),
      );

      await _db.saveMoodEntry(updatedEntry);
      await fetchTodayEntries(); // Update UI with reflection
    } catch (e) {
      print('Erro ao gerar reflexão em background: $e');
    }
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
