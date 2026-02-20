import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../repositories/mood_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_card.dart';

/// History Screen - Tela de histórico e gráficos com lazy loading
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final MoodRepository _moodRepo = MoodRepository();
  final ScrollController _scrollController = ScrollController();

  // Pagination
  List<MoodEntry> _entries = []; // Displayed entries (paginated)
  List<MoodEntry> _allEntries = []; // All entries (filtered)
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;

  // Filters
  String _selectedFilter = '7 Dias'; // '7 Dias', '30 Dias', 'Personalizado'
  DateTimeRange? _customDateRange;
  double _averageMood = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreEntries();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // 1. Load all entries from DB
    var allEntries = await _moodRepo.getAllMoodEntries();

    // 2. Apply Date Filter
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    if (_selectedFilter == '7 Dias') {
      startDate = now.subtract(Duration(days: 7));
      allEntries = allEntries.where((e) => e.date.isAfter(startDate)).toList();
    } else if (_selectedFilter == '30 Dias') {
      startDate = now.subtract(Duration(days: 30));
      allEntries = allEntries.where((e) => e.date.isAfter(startDate)).toList();
    } else if (_selectedFilter == 'Personalizado' && _customDateRange != null) {
      startDate = _customDateRange!.start;
      endDate = _customDateRange!.end.add(
        Duration(days: 1),
      ); // Include end date
      allEntries = allEntries
          .where((e) => e.date.isAfter(startDate) && e.date.isBefore(endDate))
          .toList();
    }

    // Sort by date descending
    allEntries.sort((a, b) => b.date.compareTo(a.date));

    // 3. Calculate Stats
    double average = 0.0;
    if (allEntries.isNotEmpty) {
      final sum = allEntries.fold<int>(0, (prev, e) => prev + e.moodLevel);
      average = sum / allEntries.length;
    }

    // 4. Setup Pagination
    _currentPage = 0;
    final firstPage = allEntries.take(_pageSize).toList();

    setState(() {
      _allEntries = allEntries;
      _entries = firstPage;
      _averageMood = average;
      _hasMore = allEntries.length > _pageSize;
      _isLoading = false;
    });
  }

  Future<void> _loadMoreEntries() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    await Future.delayed(Duration(milliseconds: 300));

    final startIndex = (_currentPage + 1) * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex < _allEntries.length) {
      final nextPage = _allEntries.sublist(
        startIndex,
        endIndex > _allEntries.length ? _allEntries.length : endIndex,
      );

      setState(() {
        _currentPage++;
        _entries.addAll(nextPage);
        _hasMore = endIndex < _allEntries.length;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _hasMore = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(Duration(days: 7)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedFilter = 'Personalizado';
      });
      _loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Histórico', style: AppTextStyles.h1),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : _allEntries.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadInitialData,
                    color: AppColors.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      itemCount: _getItemCount(),
                      itemBuilder: (context, index) => _buildItem(index),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('7 Dias'),
          SizedBox(width: 12),
          _buildFilterChip('30 Dias'),
          SizedBox(width: 12),
          _buildFilterChip('Personalizado', icon: Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon}) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.text,
            ),
            SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (label == 'Personalizado') {
          _selectDateRange();
        } else if (selected) {
          setState(() => _selectedFilter = label);
          _loadInitialData();
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.text,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey[300]!,
        ),
      ),
    );
  }

  int _getItemCount() {
    return 3 + _entries.length + (_hasMore ? 1 : 0);
  }

  Widget _buildItem(int index) {
    if (index == 0) {
      return Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: _buildStatsCard(),
      );
    }
    if (index == 1) {
      return Padding(
        padding: EdgeInsets.only(bottom: 32),
        child: _buildChart(),
      );
    }
    if (index == 2) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          'Registros (${_allEntries.length})',
          style: AppTextStyles.h1.copyWith(fontSize: 20),
        ),
      );
    }

    final entryIndex = index - 3;
    if (entryIndex < _entries.length) {
      return _buildEntryCard(_entries[entryIndex]);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Nenhum registro encontrado',
            style: AppTextStyles.h1.copyWith(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros',
            style: AppTextStyles.body.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final daysTracked = _allEntries
        .map((e) => DateFormat('yyyy-MM-dd').format(e.date))
        .toSet()
        .length;

    return MoodCard(
      child: Column(
        children: [
          Text(
            'Estatísticas ($_selectedFilter)',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Média',
                _averageMood.toStringAsFixed(1),
                Icons.trending_up,
                AppColors.primary,
              ),
              _buildStatItem(
                'Total',
                _allEntries.length.toString(),
                Icons.note_alt_outlined,
                AppColors.accent,
              ),
              _buildStatItem(
                'Dias',
                daysTracked.toString(),
                Icons.calendar_today,
                AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h1.copyWith(fontSize: 24, color: color),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (_allEntries.length < 2) return const SizedBox.shrink();

    // Chart logic: show up to 7 points distributed across the range or just last 7 of selection
    // For better viz, let's take up to 10 points evenly distributed or just the last 10
    final chartEntries = _allEntries.take(10).toList().reversed.toList();

    return MoodCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolução do Humor',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.body.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1, // Adjust based on data size
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < chartEntries.length) {
                          final date = chartEntries[value.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: AppTextStyles.body.copyWith(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      chartEntries.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        chartEntries[index].moodLevel.toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(MoodEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE8E8E8)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        onTap: () => _showEntryDetails(entry),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: entry.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(entry.emoji, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          entry.moodDescription,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMM · HH:mm', 'pt_BR').format(entry.date),
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: AppColors.text,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(MoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: entry.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            entry.emoji,
                            style: TextStyle(fontSize: 36),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.moodDescription,
                                style: AppTextStyles.h1.copyWith(fontSize: 24),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Nível ${entry.moodLevel}/5',
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Date
                    _buildDetailSection(
                      icon: Icons.calendar_today,
                      title: 'Data e Hora',
                      content: DateFormat(
                        'EEEE, d MMMM yyyy · HH:mm',
                        'pt_BR',
                      ).format(entry.date),
                    ),

                    // Context (Energy, Sleep, Social)
                    if (entry.energy != null ||
                        entry.sleep != null ||
                        (entry.social != null && entry.social!.isNotEmpty)) ...[
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.grid_view,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Contexto',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            if (entry.energy != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bolt,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Energia: ${entry.energy!.toInt()}/5'),
                                  ],
                                ),
                              ),
                            if (entry.sleep != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bedtime,
                                      size: 16,
                                      color: Colors.indigo,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Sono: ${entry.sleep}h'),
                                  ],
                                ),
                              ),
                            if (entry.social != null &&
                                entry.social!.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: entry.social!
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.white,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.zero,
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Note
                    if (entry.note != null && entry.note!.isNotEmpty) ...[
                      SizedBox(height: 20),
                      _buildDetailSection(
                        icon: Icons.note_outlined,
                        title: 'Nota',
                        content: entry.note!,
                      ),
                    ],

                    // AI Reflection
                    if (entry.aiReflection != null &&
                        entry.aiReflection!.isNotEmpty) ...[
                      SizedBox(height: 20),
                      _buildDetailSection(
                        icon: Icons.psychology_outlined,
                        title: 'Reflexão da IA',
                        content: entry.aiReflection!,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.05,
                        ),
                      ),
                    ],

                    SizedBox(height: 32),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Edição em desenvolvimento'),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit_outlined),
                            label: Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmDelete(entry),
                            icon: Icon(Icons.delete_outline),
                            label: Text('Deletar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    Color? backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(content, style: AppTextStyles.body.copyWith(fontSize: 15)),
        ],
      ),
    );
  }

  void _confirmDelete(MoodEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Deletar Registro', style: AppTextStyles.h1),
        content: Text(
          'Tem certeza que deseja deletar este registro? Esta ação não pode ser desfeita.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(dialogContext); // Close bottom sheet
              await _moodRepo.deleteMoodEntry(entry.id);
              await _loadInitialData(); // Reload with current filters

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registro deletado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Deletar'),
          ),
        ],
      ),
    );
  }
}
