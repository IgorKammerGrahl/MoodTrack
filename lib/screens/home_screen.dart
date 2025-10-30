import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/database_service.dart';
import 'history_screen.dart';
import 'reflections_screen.dart';

/// Home Screen - Tela principal para registro de humor (Stateful Widget)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedMood; // Humor selecionado (1 a 5)
  final TextEditingController _noteController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isSaving = false;
  MoodEntry? _todayEntry; // Registro existente de hoje
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkTodayEntry();
  }

  /// Verifica se já existe registro de hoje
  Future<void> _checkTodayEntry() async {
    final todayEntry = await _db.getTodayEntry();

    if (todayEntry != null) {
      setState(() {
        _todayEntry = todayEntry;
        _selectedMood = todayEntry.moodLevel;
        _noteController.text = todayEntry.note ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Salva o registro de humor
  Future<void> _saveMoodEntry() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um humor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      moodLevel: _selectedMood!,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    await _db.saveMoodEntry(entry);

    if (mounted) {
      setState(() => _isSaving = false);

      final isUpdate = _todayEntry != null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUpdate
                ? '✅ Humor de hoje atualizado!'
                : '✅ Humor registrado com sucesso!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Atualiza o registro de hoje
      setState(() {
        _todayEntry = entry;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM', 'pt_BR').format(DateTime.now());

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodTrack'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade600],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            tooltip: 'Ver histórico',
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReflectionsScreen()),
              );
            },
            tooltip: 'Reflexões',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicador se já registrou hoje
              if (_todayEntry != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Você já registrou hoje. Pode atualizar se quiser!',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Saudação
              Text(
                'Como você está se sentindo hoje?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                today.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Seletor de humor
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Escolha seu humor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Emojis de humor
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          final moodLevel = index + 1;
                          final isSelected = _selectedMood == moodLevel;

                          return _MoodButton(
                            emoji: MoodEntry(
                              id: '',
                              date: DateTime.now(),
                              moodLevel: moodLevel,
                            ).emoji,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => _selectedMood = moodLevel);
                            },
                          );
                        }),
                      ),

                      if (_selectedMood != null) ...[
                        const SizedBox(height: 15),
                        Text(
                          MoodEntry(
                            id: '',
                            date: DateTime.now(),
                            moodLevel: _selectedMood!,
                          ).moodDescription,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              MoodEntry(
                                id: '',
                                date: DateTime.now(),
                                moodLevel: _selectedMood!,
                              ).color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Campo de anotação
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Quer escrever sobre isso? (opcional)',
                  hintText: 'Como foi seu dia? O que aconteceu?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

              const SizedBox(height: 30),

              // Botão salvar
              ElevatedButton(
                onPressed: _isSaving ? null : _saveMoodEntry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Colors.purple.shade400,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _todayEntry != null
                            ? 'Atualizar Registro'
                            : 'Salvar Registro',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget personalizado para botão de humor
class _MoodButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade100 : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.purple.shade400 : Colors.grey.shade300,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(fontSize: isSelected ? 32 : 28)),
        ),
      ),
    );
  }
}
