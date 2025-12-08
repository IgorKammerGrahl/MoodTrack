import 'package:get/get.dart';
import 'api_service.dart';

class GeminiService extends GetxService {
  final ApiService _api = ApiService();

  Future<String> chat(String message, {Map<String, dynamic>? context}) async {
    try {
      final response = await _api.post('/ai/chat', {
        'message': message,
        'context': context,
      });
      return response['response'];
    } catch (e) {
      print('Erro no chat Gemini: $e');
      // Fallback response for demo/offline
      return "Estou tendo dificuldades para conectar agora, mas estou aqui para ouvir. Como você está se sentindo?";
    }
  }

  Future<String> getReflection(String mood, String note) async {
    try {
      final response = await _api.post('/ai/reflection', {
        'mood': mood,
        'note': note,
      });
      return response['reflection'];
    } catch (e) {
      print('Erro na reflexão Gemini: $e');
      return "Parece que você está passando por um momento importante. Lembre-se de ser gentil consigo mesmo.";
    }
  }
}
