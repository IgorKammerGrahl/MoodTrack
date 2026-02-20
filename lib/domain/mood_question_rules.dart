/// Contextual questions based on mood level.
/// These are optional prompts shown after mood selection to enrich the data entry.
class MoodQuestionRules {
  /// Returns contextual questions for a given mood level (1-5).
  static List<String> getQuestions(int moodLevel) {
    return _questions[moodLevel] ?? _questions[3]!;
  }

  static const Map<int, List<String>> _questions = {
    1: [
      'O que causou esse sentimento?',
      'Você está dormindo bem?',
      'Quer desabafar sobre algo?',
    ],
    2: [
      'Algo te preocupou hoje?',
      'Como está seu nível de energia?',
      'Tem alguém com quem conversar?',
    ],
    3: [
      'Algo te preocupa hoje?',
      'O que poderia melhorar seu dia?',
      'Como está sua rotina?',
    ],
    4: [
      'O que contribuiu para seu bem-estar?',
      'Você fez algo especial hoje?',
      'Como está sua energia?',
    ],
    5: [
      'O que te fez tão feliz?',
      'Qual foi o melhor momento do dia?',
      'Quer compartilhar essa alegria?',
    ],
  };
}
