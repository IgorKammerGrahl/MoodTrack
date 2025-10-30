/// Classe que representa um registro de humor do usuário
class MoodEntry {
  final String id;
  final DateTime date;
  final int moodLevel; // 1 (muito triste) a 5 (muito feliz)
  final String? note; // Anotação opcional do usuário

  MoodEntry({
    required this.id,
    required this.date,
    required this.moodLevel,
    this.note,
  });

  // Converte para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodLevel': moodLevel,
      'note': note,
    };
  }

  // Cria MoodEntry a partir de Map (para ler do banco)
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      moodLevel: map['moodLevel'],
      note: map['note'],
    );
  }

  // Retorna emoji baseado no nível de humor
  String get emoji {
    switch (moodLevel) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  // Retorna descrição textual do humor
  String get moodDescription {
    switch (moodLevel) {
      case 1:
        return 'Muito Triste';
      case 2:
        return 'Triste';
      case 3:
        return 'Neutro';
      case 4:
        return 'Feliz';
      case 5:
        return 'Muito Feliz';
      default:
        return 'Neutro';
    }
  }

  // Retorna cor baseada no humor
  int get color {
    switch (moodLevel) {
      case 1:
        return 0xFF6366F1; // Roxo azulado
      case 2:
        return 0xFF3B82F6; // Azul
      case 3:
        return 0xFF10B981; // Verde
      case 4:
        return 0xFFF59E0B; // Amarelo
      case 5:
        return 0xFFEF4444; // Vermelho alaranjado
      default:
        return 0xFF10B981;
    }
  }
}
