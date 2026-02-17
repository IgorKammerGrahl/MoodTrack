import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Classe que representa um registro de humor do usuário
class MoodEntry {
  final String id;
  final DateTime date;
  final int moodLevel; // 1 (muito triste) a 5 (muito feliz)
  final String? note; // Anotação opcional do usuário
  final String? aiReflection; // Reflexão gerada pela IA
  final DateTime? reflectionGeneratedAt; // Data da geração da reflexão
  final double? energy; // Nível de energia (1-5)
  final double? sleep; // Horas de sono
  final List<String>? social; // Contexto social (família, amigos, etc)
  final String? _storedEmoji; // Emoji armazenado (do backend ou construtor)
  final String? _storedColor; // Cor armazenada como hex string

  MoodEntry({
    required this.id,
    required this.date,
    required this.moodLevel,
    this.note,
    this.aiReflection,
    this.reflectionGeneratedAt,
    this.energy,
    this.sleep,
    this.social,
    String? emoji,
    String? colorHex,
  })  : _storedEmoji = emoji,
        _storedColor = colorHex;

  // Converte para Map (para salvar no banco/API)
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'moodLevel': moodLevel,
      'emoji': emoji,
      'color': colorHex,
      'note': note,
      'aiReflection': aiReflection,
      'reflectionGeneratedAt': reflectionGeneratedAt?.toIso8601String(),
      'energy': energy,
      'sleep': sleep,
      'social': social,
    };
  }

  // Cria MoodEntry a partir de Map (para ler do banco/API)
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      moodLevel: json['moodLevel'],
      note: json['note'],
      aiReflection: json['aiReflection'],
      reflectionGeneratedAt: json['reflectionGeneratedAt'] != null
          ? DateTime.parse(json['reflectionGeneratedAt'])
          : null,
      energy: json['energy']?.toDouble(),
      sleep: json['sleep']?.toDouble(),
      social: json['social'] != null ? List<String>.from(json['social']) : null,
      emoji: json['emoji'],
      colorHex: json['color'],
    );
  }

  // Retorna emoji baseado no nível de humor (usa valor armazenado se disponível)
  String get emoji {
    if (_storedEmoji != null) return _storedEmoji;
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

  // Retorna cor como hex string para serialização
  String get colorHex {
    if (_storedColor != null) return _storedColor;
    switch (moodLevel) {
      case 1:
        return 'FFC1C1';
      case 2:
        return 'FFD4A3';
      case 3:
        return 'E8E8E8';
      case 4:
        return 'B8E6D5';
      case 5:
        return 'A8D5FF';
      default:
        return 'B8E6D5';
    }
  }

  // Retorna cor baseada no humor (Design System)
  Color get color {
    switch (moodLevel) {
      case 1:
        return Color(0xFFFFC1C1); // Pastel Red
      case 2:
        return Color(0xFFFFD4A3); // Pastel Orange
      case 3:
        return Color(0xFFE8E8E8); // Neutral Gray
      case 4:
        return Color(0xFFB8E6D5); // Mint Green (Soft)
      case 5:
        return Color(0xFFA8D5FF); // Soft Blue
      default:
        return AppColors.primary;
    }
  }
}
