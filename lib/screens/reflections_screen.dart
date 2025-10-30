import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/database_service.dart';

/// Reflections Screen - Tela de reflexões inteligentes (Stateful Widget)
class ReflectionsScreen extends StatefulWidget {
  const ReflectionsScreen({super.key});

  @override
  State<ReflectionsScreen> createState() => _ReflectionsScreenState();
}

class _ReflectionsScreenState extends State<ReflectionsScreen> {
  final DatabaseService _db = DatabaseService();

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

    final allEntries = await _db.getAllMoodEntries();
    final weekEntries = await _db.getRecentEntries(7);

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
      appBar: AppBar(
        title: const Text('Análise Psicológica'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade600],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allEntries.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _performDeepAnalysis,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Análise principal personalizada
                      _buildMainAnalysisCard(),

                      const SizedBox(height: 20),

                      // Insights inteligentes
                      ..._buildSmartInsights(),

                      const SizedBox(height: 25),

                      // Reflexões contextuais
                      Text(
                        'Reflexões para Você',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ..._buildContextualReflections(),

                      const SizedBox(height: 25),

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
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'Comece sua jornada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Registre seu humor por alguns dias para receber análises personalizadas e insights sobre seu bem-estar emocional.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
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
    List<Color> gradientColors = [Colors.purple.shade300, Colors.blue.shade400];

    // Mensagem personalizada baseada em múltiplos fatores
    if (_analysis['needsSupport'] == true) {
      mainMessage =
          'Percebi que você tem enfrentado dias difíceis. Lembre-se: conversar com alguém de confiança ou um profissional pode fazer toda diferença. Você não está sozinho. 💙';
      icon = Icons.support_agent;
      gradientColors = [Colors.blue.shade400, Colors.indigo.shade500];
    } else if (trend == 'melhorando') {
      mainMessage =
          'Que progresso incrível! Seu humor tem melhorado consistentemente. Continue cuidando de si mesmo, você está no caminho certo! 🌟';
      icon = Icons.trending_up;
      gradientColors = [Colors.green.shade400, Colors.teal.shade500];
    } else if (trend == 'piorando' && !_analysis['needsSupport']) {
      mainMessage =
          'Notei uma queda no seu humor recentemente. Todos temos altos e baixos - que tal fazer algo que te traz alegria hoje? 🌿';
      icon = Icons.trending_down;
      gradientColors = [Colors.orange.shade400, Colors.amber.shade500];
    } else if (isStable && weekAvg >= 4) {
      mainMessage =
          'Você está mantendo um humor excelente e estável! Essa consistência mostra que você está cuidando bem de si. Parabéns! 😊';
      icon = Icons.emoji_emotions;
      gradientColors = [Colors.pink.shade300, Colors.purple.shade400];
    } else if (isStable) {
      mainMessage =
          'Seu humor tem estado equilibrado. A estabilidade emocional é um sinal positivo de autoconhecimento e cuidado pessoal. 🧘';
      icon = Icons.balance;
    } else {
      mainMessage =
          'Seu humor tem variado bastante. Isso é normal - somos humanos! Tente identificar o que influencia essas mudanças. 🔄';
      icon = Icons.waves;
      gradientColors = [Colors.purple.shade300, Colors.deepPurple.shade400];
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 50),
            const SizedBox(height: 15),
            const Text(
              'Sua Análise Personalizada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mainMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
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
          Colors.indigo,
        ),
      );
      insights.add(const SizedBox(height: 15));
    }

    // Insight 2: Distribuição de humor na semana
    if (_weekEntries.length >= 5) {
      final goodDays = _weekEntries.where((e) => e.moodLevel >= 4).length;
      final badDays = _weekEntries.where((e) => e.moodLevel <= 2).length;
      final neutralDays = _weekEntries.length - goodDays - badDays;

      String distributionMessage = '';
      Color distributionColor = Colors.blue;

      if (goodDays > badDays * 2) {
        distributionMessage =
            'Esta semana teve $goodDays dias bons contra apenas $badDays ruins. '
            'Você está cultivando um padrão positivo! Continue assim. 🌟';
        distributionColor = Colors.green;
      } else if (badDays > goodDays) {
        distributionMessage =
            'Esta semana teve mais dias desafiadores ($badDays) do que bons ($goodDays). '
            'Lembre-se: semanas difíceis acontecem, mas são temporárias. 💪';
        distributionColor = Colors.orange;
      } else if (neutralDays >= _weekEntries.length * 0.6) {
        distributionMessage =
            'Sua semana foi predominantemente neutra ($neutralDays dias). '
            'Que tal buscar pequenas alegrias no dia a dia? 🌿';
        distributionColor = Colors.teal;
      }

      if (distributionMessage.isNotEmpty) {
        insights.add(
          _buildInsightCard(
            '📊 Distribuição Semanal',
            distributionMessage,
            distributionColor,
          ),
        );
        insights.add(const SizedBox(height: 15));
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
          Colors.teal,
        ),
      );
      insights.add(const SizedBox(height: 15));
    }

    // Insight 4: Conquista de constância
    final longestStreak = _analysis['longestStreak'] ?? 0;
    if (longestStreak >= 7) {
      insights.add(
        _buildInsightCard(
          '🏆 Conquista Desbloqueada',
          'Seu recorde é $longestStreak dias consecutivos registrando! '
              'A consistência no autoconhecimento é fundamental para o crescimento pessoal.',
          Colors.amber.shade700,
        ),
      );
      insights.add(const SizedBox(height: 15));
    }

    // Insight 5: Volatilidade emocional
    final volatility = _analysis['volatility'] ?? 0.0;
    if (volatility > 2.0 && !_analysis['needsSupport']) {
      insights.add(
        _buildInsightCard(
          '🌊 Variação Emocional',
          'Seu humor tem oscilado bastante. Isso pode indicar que fatores externos estão te afetando. '
              'Tente identificar gatilhos: sono, alimentação, eventos estressantes.',
          Colors.deepOrange,
        ),
      );
      insights.add(const SizedBox(height: 15));
    }

    // Insight 6: Progresso positivo
    if (_analysis['isImproving'] == true &&
        _analysis['trend'] == 'melhorando') {
      insights.add(
        _buildInsightCard(
          '🌱 Crescimento Emocional',
          'Comparando com semanas anteriores, há uma melhora clara no seu bem-estar! '
              'O que você tem feito diferente? Continue nesse caminho.',
          Colors.green,
        ),
      );
      insights.add(const SizedBox(height: 15));
    }

    return insights;
  }

  Widget _buildInsightCard(String title, String content, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lightbulb, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
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
          Colors.green,
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
          Colors.blue,
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
          Colors.purple,
        ),
      );
    }

    reflections.add(const SizedBox(height: 15));

    // Reflexão baseada no humor mais frequente
    if (mostFrequentMood == 5) {
      reflections.add(
        _buildReflectionCard(
          '😄 Energia Positiva',
          'Você tem estado muito feliz! Aproveite esse momento para ajudar outros. '
              'Compartilhar alegria multiplica o bem-estar. Sua energia positiva é contagiante!',
          'gratitude',
          Colors.pink,
        ),
      );
      reflections.add(const SizedBox(height: 15));
    } else if (mostFrequentMood == 4) {
      reflections.add(
        _buildReflectionCard(
          '😊 Equilíbrio Feliz',
          'Seu humor predominante tem sido feliz. Esse é um ótimo sinal de que você está '
              'cuidando bem do seu bem-estar. Continue identificando o que te faz bem!',
          'gratitude',
          Colors.green,
        ),
      );
      reflections.add(const SizedBox(height: 15));
    } else if (mostFrequentMood == 3) {
      reflections.add(
        _buildReflectionCard(
          '😐 Zona Neutra',
          'Você tem estado neutro com frequência. Isso pode significar estabilidade, '
              'mas também pode ser momento de buscar mais alegria. Que tal experimentar algo novo hoje?',
          'mindfulness',
          Colors.blue,
        ),
      );
      reflections.add(const SizedBox(height: 15));
    } else if (mostFrequentMood <= 2) {
      reflections.add(
        _buildReflectionCard(
          '💙 Dias Desafiadores',
          'Você tem enfrentado dias difíceis com frequência. Lembre-se: isso é temporário. '
              'Considere conversar com alguém de confiança ou buscar apoio profissional. '
              'Você merece sentir-se melhor.',
          'selfcare',
          Colors.indigo,
        ),
      );
      reflections.add(const SizedBox(height: 15));
    }

    // Reflexão sobre conexão (sempre relevante)
    reflections.add(
      _buildReflectionCard(
        'O Poder da Conexão',
        'Somos seres sociais. Mesmo uma breve conversa pode melhorar significativamente o humor. '
            'Que tal enviar uma mensagem carinhosa para alguém? Ou compartilhar como você está se sentindo?',
        'connection',
        Colors.pink,
      ),
    );

    reflections.add(const SizedBox(height: 15));

    // Reflexão sobre mindfulness
    reflections.add(
      _buildReflectionCard(
        'Presente no Agora',
        'Exercício rápido: Feche os olhos. Respire fundo 3 vezes. '
            'Perceba 3 coisas que você pode ouvir agora. 2 que pode sentir. 1 que pode cheirar. '
            'Este simples exercício acalma a mente e reduz ansiedade.',
        'mindfulness',
        Colors.teal,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: Colors.orange.shade700,
                  size: 30,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '💙 Você Não Está Sozinho',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Se você está passando por um momento difícil, saiba que conversar com alguém pode fazer toda diferença. '
              'Buscar ajuda é um sinal de coragem e autocuidado.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 15),
            _buildSupportItem(
              '📞 CVV - 188',
              'Centro de Valorização da Vida\n24 horas • Gratuito • Sigiloso',
            ),
            const Divider(height: 20),
            _buildSupportItem(
              '💚 CAPS',
              'Centros de Atenção Psicossocial\nAtendimento gratuito pelo SUS',
            ),
            const Divider(height: 20),
            _buildSupportItem(
              '👨‍⚕️ Profissional',
              'Considere conversar com um psicólogo\nA terapia pode transformar vidas',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
