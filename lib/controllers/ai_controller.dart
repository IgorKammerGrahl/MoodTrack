import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'mood_controller.dart';

class AIController extends GetxController {
  final GeminiService _geminiService = Get.put(GeminiService());
  final DatabaseService _db = DatabaseService();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final messageController = TextEditingController();
  final RxBool isTyping = false.obs;
  final RxBool showCrisisModal = false.obs;

  final List<String> _crisisKeywords = [
    'suicídio',
    'suicidio',
    'me matar',
    'não aguento mais',
    'nao aguento mais',
    'morrer',
    'acabar com tudo',
    'desesperado',
    'sem saída',
    'sem saida',
    'cortar',
    'machucar',
    'tirar minha vida',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final userId = _authService.currentUser.value?.id ?? 'guest';
      final history = await _db.getChatHistory(userId);

      messages.assignAll(
        history.map((json) => ChatMessage.fromJson(json)).toList(),
      );
    } catch (e) {
      debugPrint('Erro ao carregar histórico de chat: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final userId = _authService.currentUser.value?.id ?? 'guest';
      await _db.saveChatHistory(userId, messages);
    } catch (e) {
      debugPrint('Erro ao salvar histórico de chat: $e');
    }
  }

  Map<String, dynamic> _buildUserContext() {
    // Try to get mood context
    try {
      final moodController = Get.find<MoodController>();
      final recentEntries = moodController.recentEntries;

      if (recentEntries.isEmpty) {
        return {};
      }

      // Last mood (today or most recent)
      final lastEntry = recentEntries.first;

      // Weekly pattern (last 7 days)
      final lastWeek = recentEntries.where((entry) {
        final diff = DateTime.now().difference(entry.date).inDays;
        return diff <= 7;
      }).toList();

      final weeklyAverage = lastWeek.isEmpty
          ? null
          : lastWeek.map((e) => e.moodLevel).reduce((a, b) => a + b) /
                lastWeek.length;

      return {
        'lastMood': lastEntry.moodDescription,
        'lastMoodLevel': lastEntry.moodLevel,
        'weeklyPattern': weeklyAverage?.toStringAsFixed(1),
        'instruction':
            'Responda com empatia, sem diagnosticar. Você é um assistente de suporte emocional.',
      };
    } catch (e) {
      // MoodController not found or error
      return {
        'instruction':
            'Responda com empatia, sem diagnosticar. Você é um assistente de suporte emocional.',
      };
    }
  }

  void sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.add(userMessage);
    await _saveChatHistory();

    messageController.clear();
    isTyping.value = true;

    // Crisis Detection
    if (_detectCrisis(text)) {
      isTyping.value = false;
      showCrisisModal.value = true;

      // Log crisis event
      debugPrint('[CRISIS DETECTED] User message: $text');

      // Add system message
      final crisisMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            "Identifiquei que você pode estar passando por um momento muito difícil. Por favor, considere buscar ajuda imediata. O CVV (188) está disponível 24h.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.add(crisisMessage);
      await _saveChatHistory();
      return;
    }

    try {
      // Build context
      final context = _buildUserContext();

      // Get AI response with context
      final response = await _geminiService.chat(text, context: context);

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.add(aiMessage);
      await _saveChatHistory();
    } catch (e) {
      debugPrint('Erro ao enviar mensagem: $e');
      Get.snackbar('Erro', 'Falha ao conectar com a IA');
    } finally {
      isTyping.value = false;
    }
  }

  bool _detectCrisis(String text) {
    final lowerText = text.toLowerCase();
    return _crisisKeywords.any((keyword) => lowerText.contains(keyword));
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
