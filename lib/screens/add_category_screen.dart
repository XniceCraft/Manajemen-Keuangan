import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/category.dart';
import '../providers/providers.dart';
import '../widgets/glassmorphic_card.dart';
import '../theme/app_theme.dart';

class CategoryCard extends GlassmorphicCard {
  final bool isSelected;

  const CategoryCard({
    super.key,
    required super.child,
    super.padding,
    super.height,
    super.width,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
      gradient: isSelected ? null : AppTheme.glassmorphismDecoration.gradient,
      color: isSelected ? AppTheme.secondaryColor.withAlpha(50) : null,
      borderRadius: AppTheme.glassmorphismDecoration.borderRadius,
      border: AppTheme.glassmorphismDecoration.border,
    );
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}

class AddCategoryScreen extends ConsumerStatefulWidget {
  final Category? category;

  const AddCategoryScreen({super.key, this.category});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIcon = 'category';
  String _selectedColor = '6C63FF';
  bool _isIncome = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'category', 'icon': Icons.category},
    {'name': 'wallet', 'icon': Icons.wallet},
    {'name': 'laptop', 'icon': Icons.laptop},
    {'name': 'trending-up', 'icon': Icons.trending_up},
    {'name': 'trending-down', 'icon': Icons.trending_down},
    {'name': 'utensils', 'icon': Icons.restaurant},
    {'name': 'car', 'icon': Icons.directions_car},
    {'name': 'shopping-bag', 'icon': Icons.shopping_bag},
    {'name': 'gamepad-2', 'icon': Icons.sports_esports},
    {'name': 'heart', 'icon': Icons.favorite},
    {'name': 'file-text', 'icon': Icons.description},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'medical', 'icon': Icons.local_hospital},
    {'name': 'fitness', 'icon': Icons.fitness_center},
    {'name': 'travel', 'icon': Icons.flight},
    {'name': 'gift', 'icon': Icons.card_giftcard},
    {'name': 'phone', 'icon': Icons.phone},
    {'name': 'internet', 'icon': Icons.wifi},
  ];

  final List<String> _availableColors = [
    '6C63FF', // Purple
    '4ECDC4', // Teal
    'FF6B9D', // Pink
    'F44336', // Red
    '4CAF50', // Green
    '2196F3', // Blue
    'FF9800', // Orange
    '9C27B0', // Purple
    'E91E63', // Pink
    '3F51B5', // Indigo
    'FF5722', // Deep Orange
    '795548', // Brown
    '607D8B', // Blue Grey
    'FFC107', // Amber
    'CDDC39', // Lime
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
      _isIncome = widget.category!.isIncome;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.category != null ? 'Edit Kategori' : 'Tambah Kategori',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview
                _buildPreview(),
                const SizedBox(height: 24),

                // Category Name
                _buildCategoryNameField(),
                const SizedBox(height: 24),

                // Category Type
                _buildCategoryTypeField(),
                const SizedBox(height: 24),

                // Icon Selection
                _buildIconSelection(),
                const SizedBox(height: 24),

                // Color Selection
                _buildColorSelection(),
                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final color = Color(int.parse('FF$_selectedColor', radix: 16));
    final selectedIconData =
        _availableIcons.firstWhere(
              (icon) => icon['name'] == _selectedIcon,
            )['icon']
            as IconData;

    return Center(
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Preview Kategori',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(selectedIconData, color: color, size: 35),
            ),
            const SizedBox(height: 12),
            Text(
              _nameController.text.isEmpty
                  ? 'Nama Kategori'
                  : _nameController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:
                    _isIncome
                        ? Colors.green.withAlpha(51)
                        : Colors.red.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isIncome ? 'Pemasukan' : 'Pengeluaran',
                style: TextStyle(
                  color: _isIncome ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Kategori',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassmorphicCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Masukkan nama kategori',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama kategori tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipe Kategori',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isIncome = false),
                child: CategoryCard(
                  padding: const EdgeInsets.all(16),
                  isSelected: !_isIncome,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Icon(Icons.trending_down, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Pengeluaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isIncome = true),
                child: CategoryCard(
                  padding: const EdgeInsets.all(16),
                  isSelected: _isIncome,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Pemasukan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Icon',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GlassmorphicCard(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = _availableIcons[index];
              final isSelected = _selectedIcon == iconData['name'];

              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = iconData['name']),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppTheme.primaryColor.withAlpha(77)
                            : Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        isSelected
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : null,
                  ),
                  child: Icon(
                    iconData['icon'],
                    color: isSelected ? AppTheme.primaryColor : Colors.white70,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Warna',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GlassmorphicCard(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final colorHex = _availableColors[index];
              final color = Color(int.parse('FF$colorHex', radix: 16));
              final isSelected = _selectedColor == colorHex;

              return GestureDetector(
                onTap: () => setState(() => _selectedColor = colorHex),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(25),
                    border:
                        isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                          : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveCategory,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  widget.category != null
                      ? 'Update Kategori'
                      : 'Simpan Kategori',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = Category(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        isIncome: _isIncome,
      );

      if (widget.category != null) {
        // Update existing category
        await ref.read(categoriesProvider.notifier).updateCategory(category);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kategori berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new category
        await ref.read(categoriesProvider.notifier).addCategory(category);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kategori berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
