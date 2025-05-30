import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database.dart' as db;
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/glassmorphic_card.dart';


class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(balanceProvider.notifier).loadMonthlyBalance(selectedMonth);
      ref
          .read(transactionsProvider.notifier)
          .loadTransactions(
            startDate: DateTime(selectedMonth.year, selectedMonth.month, 1),
            endDate: DateTime(selectedMonth.year, selectedMonth.month + 1, 0),
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + delta);
    });
    ref.read(balanceProvider.notifier).loadMonthlyBalance(selectedMonth);
    ref
        .read(transactionsProvider.notifier)
        .loadTransactions(
          startDate: DateTime(selectedMonth.year, selectedMonth.month, 1),
          endDate: DateTime(selectedMonth.year, selectedMonth.month + 1, 0),
        );
  }

  @override
  Widget build(BuildContext context) {
    final balanceState = ref.watch(balanceProvider);
    final transactionsState = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
              'Statistik',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.textColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Grafik'),
            Tab(text: 'Kategori'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Month Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: GlassmorphicCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppTheme.textColor,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(balanceState, transactionsState),
                _buildChartTab(transactionsState),
                _buildCategoryTab(transactionsState),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(index: 3),
    );
  }

  Widget _buildSummaryTab(
    AsyncValue<Map<String, double>> balanceState,
    AsyncValue<List<db.Transaction>> transactionsState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Balance Cards
          balanceState.when(
            data: (balance) {
              final income = balance['income'] ?? 0.0;
              final expense = balance['expense'] ?? 0.0;
              final total = income - expense;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceCard(
                          'Pemasukan',
                          income,
                          Icons.trending_up,
                          AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBalanceCard(
                          'Pengeluaran',
                          expense,
                          Icons.trending_down,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildBalanceCard(
                    'Saldo',
                    total,
                    total >= 0 ? Icons.account_balance_wallet : Icons.warning,
                    total >= 0 ? AppTheme.primaryColor : Colors.orange,
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error:
                (error, _) => Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
          ),

          const SizedBox(height: 24),

          // Transaction Count
          transactionsState.when(
            data: (transactions) {
              final incomeCount = transactions.where((t) => t.isIncome).length;
              final expenseCount =
                  transactions.where((t) => !t.isIncome).length;

              return GlassmorphicCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jumlah Transaksi',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          'Pemasukan',
                          incomeCount,
                          AppTheme.secondaryColor,
                        ),
                        _buildStatItem('Pengeluaran', expenseCount, Colors.red),
                        _buildStatItem(
                          'Total',
                          transactions.length,
                          AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error:
                (error, _) => Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTab(AsyncValue<List<db.Transaction>> transactionsState) {
    return transactionsState.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada data untuk ditampilkan',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          );
        }

        // Group transactions by day
        final dailyData = <DateTime, Map<String, double>>{};
        for (final transaction in transactions) {
          final day = DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          );
          dailyData[day] ??= {'income': 0.0, 'expense': 0.0};
          if (transaction.isIncome) {
            dailyData[day]!['income'] =
                dailyData[day]!['income']! + transaction.amount;
          } else {
            dailyData[day]!['expense'] =
                dailyData[day]!['expense']! + transaction.amount;
          }
        }

        final sortedDates = dailyData.keys.toList()..sort();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GlassmorphicCard(
                padding: const EdgeInsets.all(20),
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik Harian',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    NumberFormat.compact().format(value),
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < sortedDates.length) {
                                    return Text(
                                      sortedDates[value.toInt()].day.toString(),
                                      style: const TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                        fontSize: 10,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Income line
                            LineChartBarData(
                              spots:
                                  sortedDates.asMap().entries.map((entry) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      dailyData[entry.value]!['income']!,
                                    );
                                  }).toList(),
                              isCurved: true,
                              color: AppTheme.secondaryColor,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                            // Expense line
                            LineChartBarData(
                              spots:
                                  sortedDates.asMap().entries.map((entry) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      dailyData[entry.value]!['expense']!,
                                    );
                                  }).toList(),
                              isCurved: true,
                              color: Colors.red,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppTheme.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Pemasukan',
                            style: TextStyle(color: AppTheme.textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Pengeluaran',
                            style: TextStyle(color: AppTheme.textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
    );
  }

  Widget _buildCategoryTab(AsyncValue<List<db.Transaction>> transactionsState) {
    return transactionsState.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada data untuk ditampilkan',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          );
        }

        final categoryData = <String, double>{};
        for (final transaction in transactions) {
          if (!transaction.isIncome) {
            categoryData[transaction.category] =
                (categoryData[transaction.category] ?? 0.0) +
                transaction.amount;
          }
        }

        final sortedCategories =
            categoryData.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        final total = categoryData.values.fold(
          0.0,
          (sum, amount) => sum + amount,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (total > 0) ...[
                GlassmorphicCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pengeluaran per Kategori',
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: 1.2, // Responsive square-ish pie chart
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 60,
                            sections:
                                sortedCategories.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final category = entry.value;
                                  final percentage =
                                      (category.value / total) * 100;

                                  return PieChartSectionData(
                                    color: _getCategoryColor(index),
                                    value: percentage,
                                    title: '${percentage.toStringAsFixed(1)}%',
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Category List
              GlassmorphicCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Kategori',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sortedCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final percentage =
                          total > 0 ? (category.value / total) * 100 : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(index),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.key,
                                style: const TextStyle(
                                  color: AppTheme.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                  ).format(category.value),
                                  style: const TextStyle(
                                    color: AppTheme.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
    );
  }

  Widget _buildBalanceCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
              ).format(amount),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
}
