import 'package:finance_management/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/glassmorphic_inkwell.dart';
import '../theme/app_theme.dart';
import '../database/database.dart' as db;

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  String? selectedPaymentMethod;
  bool? selectedIsIncome;
  String selectedSort = 'date DESC';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  bool _showScrollToTop = false;

  final List<String> sortOptions = [
    'date DESC',
    'date ASC',
    'amount DESC',
    'amount ASC',
    'name ASC',
    'name DESC',
  ];

  final Map<String, String> sortLabels = {
    'date DESC': 'Terbaru',
    'date ASC': 'Terlama',
    'amount DESC': 'Jumlah Tertinggi',
    'amount ASC': 'Jumlah Terendah',
    'name ASC': 'Nama A-Z',
    'name DESC': 'Nama Z-A',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildQuickStats(),
                    const SizedBox(height: 16),
                    _buildFilterSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState());
                }
                return _buildTransactionsList(transactions);
              },
              loading:
                  () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
              error:
                  (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.withAlpha(128),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan',
                            style: TextStyle(
                              color: Colors.white.withAlpha(179),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _applyFilters(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showScrollToTop)
              FloatingActionButton.small(
                onPressed: _scrollToTop,
                backgroundColor: Colors.white.withAlpha(26),
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ),
            if (_showScrollToTop) const SizedBox(height: 16),
            FloatingActionButton.extended(
              onPressed: () => context.push('/add-transaction'),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomBar(index: 1),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.0,
        title: const Text(
          'Semua Transaksi',
          style: TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor.withAlpha(51), Colors.transparent],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          onPressed: () => _showFilterBottomSheet(context),
        ),
        IconButton(
          icon: const Icon(Icons.sort, color: Colors.white),
          onPressed: () => _showSortBottomSheet(context),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final transactionsAsync = ref.watch(transactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) return const SizedBox.shrink();

        final totalIncome = transactions
            .where((t) => t.isIncome)
            .fold(0.0, (sum, t) => sum + t.amount);
        final totalExpense = transactions
            .where((t) => !t.isIncome)
            .fold(0.0, (sum, t) => sum + t.amount);

        return GlassmorphicCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Pemasukan',
                    totalIncome,
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withAlpha(26),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Pengeluaran',
                    totalExpense,
                    Colors.red,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    final hasActiveFilters =
        selectedCategory != null ||
        selectedPaymentMethod != null ||
        selectedIsIncome != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Filter & Urutkan',
              style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (hasActiveFilters)
              TextButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(
                  Icons.clear_all,
                  size: 16,
                  color: Colors.white70,
                ),
                label: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSortChip(),
              const SizedBox(width: 8),
              ..._buildFilterChips(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip() {
    return GestureDetector(
      onTap: () => _showSortBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withAlpha(77),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withAlpha(128)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              sortLabels[selectedSort] ?? 'Urutkan',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    final chips = <Widget>[];

    if (selectedCategory != null) {
      chips.add(
        _buildFilterChip(
          'Kategori: $selectedCategory',
          Icons.category,
          () => setState(() {
            selectedCategory = null;
            _applyFilters();
          }),
        ),
      );
      chips.add(const SizedBox(width: 8));
    }

    if (selectedPaymentMethod != null) {
      chips.add(
        _buildFilterChip(
          'Metode: $selectedPaymentMethod',
          Icons.payment,
          () => setState(() {
            selectedPaymentMethod = null;
            _applyFilters();
          }),
        ),
      );
      chips.add(const SizedBox(width: 8));
    }

    if (selectedIsIncome != null) {
      chips.add(
        _buildFilterChip(
          selectedIsIncome! ? 'Pemasukan' : 'Pengeluaran',
          selectedIsIncome! ? Icons.trending_up : Icons.trending_down,
          () => setState(() {
            selectedIsIncome = null;
            _applyFilters();
          }),
        ),
      );
      chips.add(const SizedBox(width: 8));
    }

    if (selectedStartDate != null || selectedEndDate != null) {
      String label = 'Tanggal: ';
      if (selectedStartDate != null) {
        label += DateFormat('dd MMM yyyy').format(selectedStartDate!);
      }
      label += ' - ';
      if (selectedEndDate != null) {
        label += DateFormat('dd MMM yyyy').format(selectedEndDate!);
      }
      chips.add(
        _buildFilterChip(
          label,
          Icons.date_range,
          () => setState(() {
            selectedStartDate = null;
            selectedEndDate = null;
            _applyFilters();
          }),
        ),
      );
      chips.add(const SizedBox(width: 8));
    }

    return chips;
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<db.Transaction> transactions) {
    final groupedTransactions = <String, List<db.Transaction>>{};
    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final dateKey = groupedTransactions.keys.elementAt(index);
          final dayTransactions = groupedTransactions[dateKey]!;
          final date = DateTime.parse(dateKey);

          final dayTotal = dayTransactions.fold(
            0.0,
            (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12, top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(26)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${dayTotal >= 0 ? '+' : ''}${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(dayTotal)}',
                      style: TextStyle(
                        color: dayTotal >= 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Transactions for this date
              ...dayTransactions.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildTransactionItem(entry.value, entry.key),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }, childCount: groupedTransactions.length),
      ),
    );
  }

  Widget _buildTransactionItem(db.Transaction transaction, int index) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return AnimatedSlide(
      offset: Offset.zero,
      duration: Duration(milliseconds: 200 + (index * 50)),
      child: GlassmorphicInkwell(
        padding: const EdgeInsets.all(16),
        onTap: () => _showTransactionDetails(transaction),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    transaction.isIncome
                        ? Colors.green.withAlpha(26)
                        : Colors.red.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.isIncome ? Icons.trending_up : Icons.trending_down,
                color: transaction.isIncome ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.category,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        transaction.paymentMethod,
                        style: TextStyle(
                          color: Colors.white.withAlpha(128),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                  style: TextStyle(
                    color: transaction.isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(transaction.date),
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.white.withAlpha(77),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              color: Colors.white.withAlpha(179),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat keuangan Anda dengan\nmenambahkan transaksi pertama',
            style: TextStyle(
              color: Colors.white.withAlpha(128),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-transaction'),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tambah Transaksi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        bool? tempSelectedIsIncome = selectedIsIncome;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(77),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Filter Transaksi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFilterOption('Jenis Transaksi', Icons.swap_vert, [
                      _buildFilterButton(
                        'Semua',
                        tempSelectedIsIncome == null,
                        () {
                          setModalState(() => tempSelectedIsIncome = null);
                        },
                      ),
                      _buildFilterButton(
                        'Pemasukan',
                        tempSelectedIsIncome == true,
                        () {
                          setModalState(() => tempSelectedIsIncome = true);
                        },
                      ),
                      _buildFilterButton(
                        'Pengeluaran',
                        tempSelectedIsIncome == false,
                        () {
                          setModalState(() => tempSelectedIsIncome = false);
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // Date filter option
                    _buildFilterOption('Tanggal', Icons.date_range, [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedStartDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => selectedStartDate = picked);
                              setModalState(() {});
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(13),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha(26),
                              ),
                            ),
                            child: Text(
                              selectedStartDate != null
                                  ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(selectedStartDate!)
                                  : 'Dari',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedEndDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => selectedEndDate = picked);
                              setModalState(() {});
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(13),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha(26),
                              ),
                            ),
                            child: Text(
                              selectedEndDate != null
                                  ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(selectedEndDate!)
                                  : 'Sampai',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                selectedCategory = null;
                                selectedPaymentMethod = null;
                                selectedIsIncome = null;
                                selectedSort = 'date DESC';
                              });
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedIsIncome = tempSelectedIsIncome;
                              });
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(77),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Urutkan Berdasarkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...sortOptions.map(
                      (option) => ListTile(
                        title: Text(
                          sortLabels[option]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading: Radio<String>(
                          value: option,
                          groupValue: selectedSort,
                          onChanged: (value) {
                            setState(() => selectedSort = value!);
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        onTap: () {
                          setState(() => selectedSort = option);
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: buttons),
      ],
    );
  }

  Widget _buildFilterButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? AppTheme.primaryColor : Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? AppTheme.primaryColor
                      : Colors.white.withAlpha(26),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(db.Transaction transaction) {
    context.push('/add-transaction', extra: transaction);
  }

  void _applyFilters() {
    ref
        .read(transactionsProvider.notifier)
        .loadTransactions(
          category: selectedCategory,
          paymentMethod: selectedPaymentMethod,
          isIncome: selectedIsIncome,
          orderBy: selectedSort,
          startDate: selectedStartDate,
          endDate: selectedEndDate,
        );
  }

  void _clearAllFilters() {
    setState(() {
      selectedCategory = null;
      selectedPaymentMethod = null;
      selectedIsIncome = null;
      selectedSort = 'date DESC';
      selectedStartDate = null;
      selectedEndDate = null;
    });
    _applyFilters();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
