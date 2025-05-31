import 'package:finance_management/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/transaction_list_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    final ScrollController outerScrollController = ScrollController();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.backgroundColor.withAlpha(204),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: outerScrollController,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildBalanceCard(balanceAsync),
                  _buildQuickActions(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildRecentTransactions(
                    context,
                    transactionsAsync,
                    outerScrollController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-transaction'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      bottomNavigationBar: BottomBar(index: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color.fromRGBO(176, 179, 184, 1),
                  fontSize: 18,
                ),
              ),
              Text(
                'Ayo, Kelola Keuanganmu!',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 14),
              ),
            ],
          ),
          TextButton(
            onPressed: () => context.go('/statistics'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize:
                  MaterialTapTargetSize
                      .shrinkWrap,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glassmorphismDecoration,
              child: const Icon(
                LucideIcons.barChart3,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(AsyncValue<Map<String, double>> balanceAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: balanceAsync.when(
            data: (balance) {
              final income = balance['income'] ?? 0.0;
              final expense = balance['expense'] ?? 0.0;
              final total = income - expense;

              return Column(
                children: [
                  Text(
                    'Saldo Bulan Ini',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(total),
                    style: TextStyle(
                      color:
                          total >= 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceItem(
                          'Pemasukan',
                          income,
                          AppTheme.successColor,
                          LucideIcons.trendingUp,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBalanceItem(
                          'Pengeluaran',
                          expense,
                          AppTheme.errorColor,
                          LucideIcons.trendingDown,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading:
                () => const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
            error:
                (error, _) => Text(
                  'Error: $error',
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(amount),
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Lihat Semua',
              LucideIcons.list,
              AppTheme.secondaryColor,
              () => context.go('/transactions'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'Kategori',
              LucideIcons.tag,
              AppTheme.warningColor,
              () => context.go('/categories'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    AsyncValue<List<dynamic>> transactionsAsync,
    ScrollController outerScrollController,
  ) {
    final ScrollController listScrollController = ScrollController();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.inbox,
                    size: 48,
                    color: AppTheme.textSecondaryColor.withAlpha(179),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor.withAlpha(179),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final recentTransactions = transactions.take(5).toList();
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification &&
                  listScrollController.offset <= 0 &&
                  notification.metrics.pixels <= 0 &&
                  notification.dragDetails != null &&
                  notification.scrollDelta! < 0) {
                if (outerScrollController.offset <= 0) {
                  outerScrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                } else {
                  final scrollAmount = notification.scrollDelta!.abs();
                  final currentOffset = outerScrollController.offset;
                  final newOffset = (currentOffset - scrollAmount).clamp(
                    0.0,
                    outerScrollController.position.maxScrollExtent,
                  );
                  outerScrollController.animateTo(
                    newOffset,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                  );
                }
                return true;
              }
              return false;
            },
            child: ListView.builder(
              controller: listScrollController,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recentTransactions.length,
              itemBuilder: (contextListView, index) {
                return TransactionListItem(
                  transaction: recentTransactions[index],
                  onTap: () => context.go(
                    '/add-transaction',
                    extra: recentTransactions[index],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppTheme.errorColor),
          ),
        ),
      ),
    );
  }
}
