import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../repositories/mood_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_card.dart';

/// Reflections Screen - Tela de reflexões inteligentes (Stateful Widget)
class ReflectionsScreen extends StatefulWidget {
  const ReflectionsScreen({super.key});

  @override
  State<ReflectionsScreen> createState() => _ReflectionsScreenState();
}

class _ReflectionsScreenState extends State<ReflectionsScreen> {
  final MoodRepository _moodRepo = MoodRepository();

  // Dados analisados
  List<MoodEntry> _allEntries = [];
  List<MoodEntry> _weekEntries = [];
  Map<String, dynamic> _analysis = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performDeepAnalysis();
  }

  /// Análise profunda dos dados do usuário
  Future<void> _performDeepAnalysis() async {
    setState(() => _isLoading = true);

    final allEntries = await _moodRepo.getAllMoodEntries();
    final weekEntries = await _moodRepo.getRecentEntries(7);

    if (allEntries.isEmpty) {
      setState(() {
        _allEntries = [];
        _weekEntries = [];
        _isLoading = false;
      });
      return;
    }

    // Análises estatísticas
    final analysis = {
      // Básico
      'totalDays': allEntries.length,
      'weekAverage': _calculateAverage(weekEntries),
      'overallAverage': _calculateAverage(allEntries),

      // Tendência
      'trend': _calculateTrend(weekEntries),
      'isImproving': _isImproving(allEntries),

      // Volatilidade emocional
      'volatility': _calculateVolatility(weekEntries),
      'isStable': _isEmotionallyStable(weekEntries),

      // Padrões
      'mostFrequentMood': _getMostFrequentMood(weekEntries),
      'worstDay': _getWorstDayOfWeek(allEntries),
      'bestDay': _getBestDayOfWeek(allEntries),

      // Engajamento
      'writingRate': _calculateWritingRate(weekEntries),
      'isReflective': _isReflectiveUser(allEntries),

      // Alertas
      'hasLowMoodStreak': _hasLowMoodStreak(weekEntries),
      'needsSupport': _needsSupport(weekEntries),

      // Conquistas
      'daysTracked': _countUniqueDays(allEntries),
      'longestStreak': _calculateLongestStreak(allEntries),
    };

    setState(() {
      _allEntries = allEntries;
      _weekEntries = weekEntries;
      _analysis = analysis;
      _isLoading = false;
    });
  }

  // ========== CÁLCULOS ANALÍTICOS ==========

  double _calculateAverage(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    return entries.fold<int>(0, (sum, e) => sum + e.moodLevel) / entries.length;
  }

  String _calculateTrend(List<MoodEntry> entries) {
    if (entries.length < 3) return 'neutro';

    final recent = entries.take(3).toList();
    final older = entries.skip(3).take(3).toList();

    if (older.isEmpty) return 'neutro';

    final recentAvg = _calculateAverage(recent);
    final olderAvg = _calculateAverage(older);

    if (recentAvg > olderAvg + 0.5) return 'melhorando';
    if (recentAvg < olderAvg - 0.5) return 'piorando';
    return 'estável';
  }

  bool _isImproving(List<MoodEntry> entries) {
    if (entries.length < 5) return false;
    final recent = entries.take(3).toList();
    final older = entries.skip(3).take(3).toList();
    return _calculateAverage(recent) > _calculateAverage(older);
  }

  double _calculateVolatility(List<MoodEntry> entries) {
    if (entries.length < 2) return 0;

    final avg = _calculateAverage(entries);
    final variance =
        entries.fold<double>(
          0,
          (sum, e) => sum + ((e.moodLevel - avg) * (e.moodLevel - avg)),
        ) /
        entries.length;

    return variance; // Quanto maior, mais volátil
  }

  bool _isEmotionallyStable(List<MoodEntry> entries) {
    return _calculateVolatility(entries) < 1.5;
  }

  int _getMostFrequentMood(List<MoodEntry> entries) {
    if (entries.isEmpty) return 3;

    final frequency = <int, int>{};
    for (var entry in entries) {
      frequency[entry.moodLevel] = (frequency[entry.moodLevel] ?? 0) + 1;
    }

    return frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String? _getWorstDayOfWeek(List<MoodEntry> entries) {
    if (entries.length < 7) return null;

    final dayAverages = <String, List<int>>{};

    for (var entry in entries) {
      final day = DateFormat('EEEE', 'pt_BR').format(entry.date);
      dayAverages.putIfAbsent(day, () => []).add(entry.moodLevel);
    }

    if (dayAverages.isEmpty) return null;

    final averages = dayAverages.map(
      (day, moods) =>
          MapEntry(day, moods.reduce((a, b) => a + b) / moods.length),
    );

    return averages.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  String? _getBestDayOfWeek(List<MoodEntry> entries) {
    if (entries.length < 7) return null;

    final dayAverages = <String, List<int>>{};

    for (var entry in entries) {
      final day = DateFormat('EEEE', 'pt_BR').format(entry.date);
      dayAverages.putIfAbsent(day, () => []).add(entry.moodLevel);
    }

    if (dayAverages.isEmpty) return null;

    final averages = dayAverages.map(
      (day, moods) =>
          MapEntry(day, moods.reduce((a, b) => a + b) / moods.length),
    );

    return averages.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _calculateWritingRate(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    final withNotes = entries
        .where((e) => e.note != null && e.note!.isNotEmpty)
        .length;
    return withNotes / entries.length;
  }

  bool _isReflectiveUser(List<MoodEntry> entries) {
    return _calculateWritingRate(entries) > 0.5;
  }

  bool _hasLowMoodStreak(List<MoodEntry> entries) {
    if (entries.length < 3) return false;

    int streak = 0;
    for (var entry in entries.take(5)) {
      if (entry.moodLevel <= 2) {
        streak++;
        if (streak >= 3) return true;
      } else {
        streak = 0;
      }
    }
    return false;
  }

  bool _needsSupport(List<MoodEntry> entries) {
    final weekAvg = _calculateAverage(entries.take(7).toList());
    final hasLowStreak = _hasLowMoodStreak(entries);
    return weekAvg < 2.5 || hasLowStreak;
  }

  int _countUniqueDays(List<MoodEntry> entries) {
    return entries
        .map((e) => DateFormat('yyyy-MM-dd').format(e.date))
        .toSet()
        .length;
  }

  int _calculateLongestStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    final sortedDates =
        entries
            .map((e) => DateFormat('yyyy-MM-dd').format(e.date))
            .toSet()
            .toList()
          ..sort();

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prev = DateTime.parse(sortedDates[i - 1]);
      final curr = DateTime.parse(sortedDates[i]);

      if (curr.difference(prev).inDays == 1) {
        currentStreak++;
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Análise Psicológica', style: AppTextStyles.h1),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _allEntries.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _performDeepAnalysis,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Análise principal personalizada
                      _buildMainAnalysisCard(),

                      const SizedBox(height: 24),

                      // Insights inteligentes
                      ..._buildSmartInsights(),

                      const SizedBox(height: 32),

                      // Reflexões contextuais
                      Text(
                        'Reflexões para Você',
                        style: AppTextStyles.h1.copyWith(fontSize: 20),
                      ),

                      const SizedBox(height: 16),

                      ..._buildContextualReflections(),

                      const SizedBox(height: 32),

                      // Canais de apoio (só aparece se necessário)
                      if (_analysis['needsSupport'] == true)
                        _buildSupportCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Comece sua jornada',
              style: AppTextStyles.h1.copyWith(
                fontSize: 24,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Registre seu humor por alguns dias para receber análises personalizadas e insights sobre seu bem-estar emocional.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAnalysisCard() {
    final weekAvg = _analysis['weekAverage'] ?? 0;
    final trend = _analysis['trend'] ?? 'neutro';
    final isStable = _analysis['isStable'] ?? false;

    String mainMessage = '';
    IconData icon = Icons.psychology;
    Color cardColor = AppColors.primary;

    // Mensagem personalizada baseada em múltiplos fatores
    if (_analysis['needsSupport'] == true) {
      mainMessage =
          'Percebi que você tem enfrentado dias difíceis. Lembre-se: conversar com alguém de confiança ou um profissional pode fazer toda diferença. Você não está sozinho. 💙';
      icon = Icons.support_agent;
      cardColor = AppColors.accent;
    } else if (trend == 'melhorando') {
      mainMessage =
          'Que progresso incrível! Seu humor tem melhorado consistentemente. Continue cuidando de si mesmo, você está no caminho certo! 🌟';
      icon = Icons.trending_up;
      cardColor = AppColors.primary;
    } else if (trend == 'piorando' && !_analysis['needsSupport']) {
      mainMessage =
          'Notei uma queda no seu humor recentemente. Todos temos altos e baixos - que tal fazer algo que te traz alegria hoje? 🌿';
      icon = Icons.trending_down;
      cardColor = Color(0xFFE68161);
    } else if (isStable && weekAvg >= 4) {
      mainMessage =
          'Você está mantendo um humor excelente e estável! Essa consistência mostra que você está cuidando bem de si. Parabéns! 😊';
      icon = Icons.emoji_emotions;
      cardColor = AppColors.primary;
    } else if (isStable) {
      mainMessage =
          'Seu humor tem estado equilibrado. A estabilidade emocional é um sinal positivo de autoconhecimento e cuidado pessoal. 🧘';
      icon = Icons.balance;
      cardColor = AppColors.secondary;
    } else {
      mainMessage =
          'Seu humor tem variado bastante. Isso é normal - somos humanos! Tente identificar o que influencia essas mudanças. 🔄';
      icon = Icons.waves;
      cardColor = AppColors.accent;
    }

    return MoodCard(
      backgroundColor: cardColor,
      border: Border.all(color: Colors.transparent),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'Sua Análise Personalizada',
            style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            mainMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Média 7 dias', weekAvg.toStringAsFixed(1)),
              _buildMiniStat('Tendência', _getTrendEmoji(trend)),
              _buildMiniStat('Estabilidade', isStable ? '✅' : '📊'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getTrendEmoji(String trend) {
    switch (trend) {
      case 'melhorando':
        return '📈';
      case 'piorando':
        return '📉';
      default:
        return '➡️';
    }
  }

  List<Widget> _buildSmartInsights() {
    final insights = <Widget>[];

    // Insight 1: Padrão semanal
    final worstDay = _analysis['worstDay'];
    final bestDay = _analysis['bestDay'];

    if (worstDay != null && bestDay != null && _allEntries.length >= 14) {
      insights.add(
        _buildInsightCard(
          '📅 Padrão Semanal Detectado',
          'Seus $worstDay costumam ser mais desafiadores, enquanto seus $bestDay são geralmente melhores. '
              'Que tal planejar algo especial para as $worstDay?',
          AppColors.primary,
        ),
      );
      insights.add(const SizedBox(height: 16));
    }

    // Insight 2: Distribuição de humor na semana
    if (_weekEntries.length >= 5) {
      final goodDays = _weekEntries.where((e) => e.moodLevel >= 4).length;
      final badDays = _weekEntries.where((e) => e.moodLevel <= 2).length;
      final neutralDays = _weekEntries.length - goodDays - badDays;

      String distributionMessage = '';
      Color distributionColor = AppColors.accent;

      if (goodDays > badDays * 2) {
        distributionMessage =
            'Esta semana teve $goodDays dias bons contra apenas $badDays ruins. '
            'Você está cultivando um padrão positivo! Continue assim. 🌟';
        distributionColor = AppColors.primary;
      } else if (badDays > goodDays) {
        distributionMessage =
            'Esta semana teve mais dias desafiadores ($badDays) do que bons ($goodDays). '
            'Lembre-se: semanas difíceis acontecem, mas são temporárias. 💪';
        distributionColor = Color(0xFFE68161);
      } else if (neutralDays >= _weekEntries.length * 0.6) {
        distributionMessage =
            'Sua semana foi predominantemente neutra ($neutralDays dias). '
            'Que tal buscar pequenas alegrias no dia a dia? 🌿';
        distributionColor = AppColors.secondary;
      }

      if (distributionMessage.isNotEmpty) {
        insights.add(
          _buildInsightCard(
            '📊 Distribuição Semanal',
            distributionMessage,
            distributionColor,
          ),
        );
        insights.add(const SizedBox(height: 16));
      }
    }

    // Insight 3: Escrita reflexiva
    final isReflective = _analysis['isReflective'] ?? false;
    final writingRate = (_analysis['writingRate'] ?? 0.0) * 100;

    if (isReflective) {
      insights.add(
        _buildInsightCard(
          '✍️ Você é um Pensador',
          'Você escreve em ${writingRate.toStringAsFixed(0)}% dos seus registros! '
              'Pesquisas mostram que a escrita reflexiva melhora significativamente o bem-estar emocional.',
          AppColors.accent,
        ),
      );
      insights.add(const SizedBox(height: 16));
    }

    // Insight 4: Conquista de constância
    final longestStreak = _analysis['longestStreak'] ?? 0;
    if (longestStreak >= 7) {
      insights.add(
        _buildInsightCard(
          '🏆 Conquista Desbloqueada',
          'Seu recorde é $longestStreak dias consecutivos registrando! '
              'A consistência no autoconhecimento é fundamental para o crescimento pessoal.',
          Color(0xFFF4B400),
        ),
      );
      insights.add(const SizedBox(height: 16));
    }

    // Insight 5: Volatilidade emocional
    final volatility = _analysis['volatility'] ?? 0.0;
    if (volatility > 2.0 && !_analysis['needsSupport']) {
      insights.add(
        _buildInsightCard(
          '🌊 Variação Emocional',
          'Seu humor tem oscilado bastante. Isso pode indicar que fatores externos estão te afetando. '
              'Tente identificar gatilhos: sono, alimentação, eventos estressantes.',
          Color(0xFFE68161),
        ),
      );
      insights.add(const SizedBox(height: 16));
    }

    // Insight 6: Progresso positivo
    if (_analysis['isImproving'] == true &&
        _analysis['trend'] == 'melhorando') {
      insights.add(
        _buildInsightCard(
          '🌱 Crescimento Emocional',
          'Comparando com semanas anteriores, há uma melhora clara no seu bem-estar! '
              'O que você tem feito diferente? Continue nesse caminho.',
          AppColors.primary,
        ),
      );
      insights.add(const SizedBox(height: 16));
    }

    return insights;
  }

  Widget _buildInsightCard(String title, String content, Color color) {
    return MoodCard(
      border: Border.all(color: color.withValues(alpha: 0.3)),
      backgroundColor: color.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContextualReflections() {
    final reflections = <Widget>[];
    final mostFrequentMood = _analysis['mostFrequentMood'] ?? 3;
    final weekAvg = _analysis['weekAverage'] ?? 3.0;

    // Reflexões adaptadas ao estado emocional atual
    if (weekAvg >= 4) {
      // Usuário está bem - reforço positivo
      reflections.add(
        _buildReflectionCard(
          'Continue Cultivando',
          'Você está em um momento positivo. Aproveite para fortalecer hábitos saudáveis: '
              'exercícios, sono regular, conexões sociais. Momentos bons são a base para enfrentar desafios futuros.',
          'gratitude',
          AppColors.primary,
        ),
      );
    } else if (weekAvg < 2.5) {
      // Usuário está mal - acolhimento e ação
      reflections.add(
        _buildReflectionCard(
          'Um Passo de Cada Vez',
          'Dias difíceis fazem parte da vida. Seja gentil consigo mesmo. '
              'Comece com pequenas ações: uma caminhada de 10 minutos, ligar para um amigo, '
              'ou apenas respirar profundamente. Você tem capacidade de superar isso.',
          'selfcare',
          AppColors.accent,
        ),
      );
    } else {
      // Usuário neutro - crescimento
      reflections.add(
        _buildReflectionCard(
          'Espaço para Crescer',
          'Você está em equilíbrio. Este é um ótimo momento para experimentar algo novo: '
              'um hobby, uma técnica de relaxamento, ou aprofundar conexões com pessoas queridas.',
          'mindfulness',
          AppColors.secondary,
        ),
      );
    }

    reflections.add(const SizedBox(height: 16));

    // Reflexão baseada no humor mais frequente
    if (mostFrequentMood == 5) {
      reflections.add(
        _buildReflectionCard(
          '😄 Energia Positiva',
          'Você tem estado muito feliz! Aproveite esse momento para ajudar outros. '
              'Compartilhar alegria multiplica o bem-estar. Sua energia positiva é contagiante!',
          'gratitude',
          AppColors.primary,
        ),
      );
      reflections.add(const SizedBox(height: 16));
    } else if (mostFrequentMood == 4) {
      reflections.add(
        _buildReflectionCard(
          '😊 Equilíbrio Feliz',
          'Seu humor predominante tem sido feliz. Esse é um ótimo sinal de que você está '
              'cuidando bem do seu bem-estar. Continue identificando o que te faz bem!',
          'gratitude',
          AppColors.primary,
        ),
      );
      reflections.add(const SizedBox(height: 16));
    } else if (mostFrequentMood == 3) {
      reflections.add(
        _buildReflectionCard(
          '😐 Zona Neutra',
          'Você tem estado neutro com frequência. Isso pode significar estabilidade, '
              'mas também pode ser momento de buscar mais alegria. Que tal experimentar algo novo hoje?',
          'mindfulness',
          AppColors.accent,
        ),
      );
      reflections.add(const SizedBox(height: 16));
    } else if (mostFrequentMood <= 2) {
      reflections.add(
        _buildReflectionCard(
          '💙 Dias Desafiadores',
          'Você tem enfrentado dias difíceis com frequência. Lembre-se: isso é temporário. '
              'Considere conversar com alguém de confiança ou buscar apoio profissional. '
              'Você merece sentir-se melhor.',
          'selfcare',
          AppColors.secondary,
        ),
      );
      reflections.add(const SizedBox(height: 16));
    }

    // Reflexão sobre conexão (sempre relevante)
    reflections.add(
      _buildReflectionCard(
        'O Poder da Conexão',
        'Somos seres sociais. Mesmo uma breve conversa pode melhorar significativamente o humor. '
            'Que tal enviar uma mensagem carinhosa para alguém? Ou compartilhar como você está se sentindo?',
        'connection',
        AppColors.secondary,
      ),
    );

    reflections.add(const SizedBox(height: 16));

    // Reflexão sobre mindfulness
    reflections.add(
      _buildReflectionCard(
        'Presente no Agora',
        'Exercício rápido: Feche os olhos. Respire fundo 3 vezes. '
            'Perceba 3 coisas que você pode ouvir agora. 2 que pode sentir. 1 que pode cheirar. '
            'Este simples exercício acalma a mente e reduz ansiedade.',
        'mindfulness',
        AppColors.primary,
      ),
    );

    return reflections;
  }

  Widget _buildReflectionCard(
    String title,
    String content,
    String iconName,
    Color color,
  ) {
    IconData icon;
    switch (iconName) {
      case 'gratitude':
        icon = Icons.favorite;
        break;
      case 'mindfulness':
        icon = Icons.self_improvement;
        break;
      case 'connection':
        icon = Icons.people;
        break;
      case 'selfcare':
        icon = Icons.spa;
        break;
      default:
        icon = Icons.lightbulb;
    }

    return MoodCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return MoodCard(
      backgroundColor: Color(0xFFFFF0F0),
      border: Border.all(color: Color(0xFFFF5459).withValues(alpha: 0.3)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF5459),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Precisando de Ajuda?',
                  style: AppTextStyles.h1.copyWith(
                    color: Color(0xFFFF5459),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Se você está se sentindo sobrecarregado, não hesite em buscar ajuda profissional. O CVV oferece apoio emocional gratuito 24h.',
            style: AppTextStyles.body.copyWith(color: Colors.grey[800]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Implementar chamada ou link para CVV
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5459),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ligar para o CVV (188)'),
            ),
          ),
        ],
      ),
    );
  }
}
