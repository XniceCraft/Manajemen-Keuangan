import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../database/database.dart' as db;
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/glassmorphic_card.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Kategori',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withAlpha(153),
              tabs: const [Tab(text: 'Pemasukan'), Tab(text: 'Pengeluaran')],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [_buildCategoriesList(true), _buildCategoriesList(false)],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.go('/add-category'),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(index: 2),
    );
  }

  Widget _buildCategoriesList(bool isIncome) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesProvider);

        return categoriesAsync.when(
          data: (allCategories) {
            final filteredCategories =
                allCategories
                    .where((category) => category.isIncome == isIncome)
                    .toList();

            if (filteredCategories.isEmpty) {
              return _buildEmptyState(isIncome);
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return _buildCategoryCard(category);
                },
              ),
            );
          },
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
          error:
              (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
        );
      },
    );
  }

  Widget _buildCategoryCard(db.Category category) {
    final color = Color(int.parse('FF${category.color}', radix: 16));
    return GlassmorphicCard(
      child: InkWell(
        onTap: () => _showCategoryOptions(category),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _getIconData(category.icon),
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      category.isIncome
                          ? Colors.green.withAlpha(51)
                          : Colors.red.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.isIncome ? 'Masuk' : 'Keluar',
                  style: TextStyle(
                    color: category.isIncome ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isIncome) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 64, color: Colors.white.withAlpha(77)),
          const SizedBox(height: 16),
          Text(
            'Belum ada kategori ${isIncome ? 'pemasukan' : 'pengeluaran'}',
            style: TextStyle(
              color: Colors.white.withAlpha(179),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kategori untuk mengorganisir transaksi Anda',
            style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCategoryOptions(db.Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse('FF${category.color}', radix: 16),
                          ).withAlpha(51),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          _getIconData(category.icon),
                          color: Color(
                            int.parse('FF${category.color}', radix: 16),
                          ),
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              category.isIncome
                                  ? 'Kategori Pemasukan'
                                  : 'Kategori Pengeluaran',
                              style: TextStyle(
                                color: Colors.white.withAlpha(179),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go('/add-category', extra: category);
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(0, 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmDeleteCategory(category),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(0, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _confirmDeleteCategory(db.Category category) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text(
              'Hapus Kategori',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus kategori "${category.name}"?\n\nTindakan ini tidak dapat dibatalkan.',
              style: TextStyle(color: Colors.white.withAlpha(204)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.white.withAlpha(179)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCategory(category);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  void _deleteCategory(db.Category category) {
    ref.read(categoriesProvider.notifier).deleteCategory(category.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kategori "${category.name}" berhasil dihapus'),
        backgroundColor: Colors.green,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'wallet': Icons.wallet,
      'laptop': Icons.laptop,
      'trending-up': Icons.trending_up,
      'utensils': Icons.restaurant,
      'car': Icons.directions_car,
      'shopping-bag': Icons.shopping_bag,
      'gamepad-2': Icons.sports_esports,
      'heart': Icons.favorite,
      'file-text': Icons.description,
    };

    return iconMap[iconName] ?? Icons.category;
  }
}
