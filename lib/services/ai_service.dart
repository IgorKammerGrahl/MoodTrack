import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'api_service.dart';

/// Abstract interface for AI providers — ready for future provider swaps.
abstract class AIProvider {
  Future<String> chat(String message, {Map<String, dynamic>? context});
  Future<String> getReflection(int moodLevel, String note);
}

/// Default AI service implementation (backend-proxied).
class AIService extends GetxService implements AIProvider {
  final ApiService _api = ApiService();

  @override
  Future<String> chat(String message, {Map<String, dynamic>? context}) async {
    try {
      final response = await _api.post('/api/ai/chat', {
        'message': message,
        'context': context,
      });
      return response['response'];
    } catch (e) {
      debugPrint('Erro no chat AI: $e');
      // Fallback response for demo/offline
      return "Estou tendo dificuldades para conectar agora, mas estou aqui para ouvir. Como você está se sentindo?";
    }
  }

  @override
  Future<String> getReflection(int moodLevel, String note) async {
    try {
      final response = await _api.post('/api/ai/reflection', {
        'moodLevel': moodLevel,
        'note': note,
      });
      return response['reflection'];
    } catch (e) {
      debugPrint('Erro na reflexão AI: $e');
      return "Parece que você está passando por um momento importante. Lembre-se de ser gentil consigo mesmo.";
    }
  }
}
