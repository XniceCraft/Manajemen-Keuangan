// ignore_for_file: use_build_context_synchronously

import 'package:finance_management/widgets/transactions/chip_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../database/database.dart' as drift;
import 'package:drift/drift.dart' as drift;

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) return newValue.copyWith(text: '');
    final number = int.parse(newText);
    final formatted = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddTransactionScreen extends ConsumerStatefulWidget {
  final drift.Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';
  String _selectedPaymentMethod = 'Cash';
  bool _isIncome = false;

  final List<String> _paymentMethods = ['Cash', 'Bank', 'E-Wallet'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final transaction = widget.transaction!;
    _nameController.text = transaction.name;
    _amountController.text = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(transaction.amount);
    _descriptionController.text = transaction.description ?? '';
    _selectedDate = transaction.date;
    _selectedCategory = transaction.category;
    _selectedPaymentMethod = transaction.paymentMethod;
    _isIncome = transaction.isIncome;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              surface: AppTheme.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final amountText = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0;

    final transactionCompanion = drift.TransactionsCompanion(
      id:
          widget.transaction?.id != null
              ? drift.Value(widget.transaction!.id)
              : const drift.Value.absent(),
      name: drift.Value(_nameController.text),
      amount: drift.Value(amount),
      date: drift.Value(_selectedDate),
      category: drift.Value(_selectedCategory),
      paymentMethod: drift.Value(_selectedPaymentMethod),
      isIncome: drift.Value(_isIncome),
      description:
          _descriptionController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(_descriptionController.text),
    );

    try {
      if (widget.transaction == null) {
        await ref
            .read(transactionsProvider.notifier)
            .addTransaction(transactionCompanion);
      } else {
        final updated = drift.Transaction(
          id: widget.transaction!.id,
          name: _nameController.text,
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
          paymentMethod: _selectedPaymentMethod,
          isIncome: _isIncome,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
        );
        await ref
            .read(transactionsProvider.notifier)
            .updateTransaction(updated);
      }
      await ref
          .read(balanceProvider.notifier)
          .loadMonthlyBalance(DateTime.now());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaction == null
                  ? 'Transaksi berhasil ditambahkan'
                  : 'Transaksi berhasil diperbarui',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteTransaction() async {
    if (widget.transaction?.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text(
              'Hapus Transaksi',
              style: TextStyle(color: AppTheme.textColor),
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus transaksi ini?',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(transactionsProvider.notifier)
            .deleteTransaction(widget.transaction!.id);
        await ref
            .read(balanceProvider.notifier)
            .loadMonthlyBalance(DateTime.now());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil dihapus'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.go('/');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus transaksi: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTransactionTypeSelector(),
                        const SizedBox(height: 20),
                        _buildBasicInfoCard(),
                        const SizedBox(height: 16),
                        _buildCategoryCard(),
                        const SizedBox(height: 16),
                        _buildPaymentMethodCard(),
                        const SizedBox(height: 16),
                        _buildDescriptionCard(),
                        const SizedBox(height: 24),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          TextButton(
            onPressed: () => context.go('/'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glassmorphismDecoration,
              child: const Icon(
                LucideIcons.arrowLeft,
                color: AppTheme.textColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.transaction == null
                  ? 'Tambah Transaksi'
                  : 'Edit Transaksi',
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.transaction != null)
            GestureDetector(
              onTap: _deleteTransaction,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: AppTheme.glassmorphismDecoration,
                child: const Icon(
                  LucideIcons.trash2,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _isIncome = false),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor:
                      !_isIncome
                          ? AppTheme.errorColor.withAlpha(51)
                          : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color:
                        !_isIncome ? AppTheme.errorColor : Colors.transparent,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.trendingDown,
                        color:
                            !_isIncome
                                ? AppTheme.errorColor
                                : AppTheme.textSecondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pengeluaran',
                        style: TextStyle(
                          color:
                              !_isIncome
                                  ? AppTheme.errorColor
                                  : AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _isIncome = true),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor:
                      _isIncome
                          ? AppTheme.successColor.withAlpha(51)
                          : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color:
                        _isIncome ? AppTheme.successColor : Colors.transparent,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.trendingUp,
                        color:
                            _isIncome
                                ? AppTheme.successColor
                                : AppTheme.textSecondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pemasukan',
                        style: TextStyle(
                          color:
                              _isIncome
                                  ? AppTheme.successColor
                                  : AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Dasar',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Nama Transaksi',
                labelStyle: const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
                hintText: 'Masukkan nama transaksi',
                hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                filled: true,
                fillColor: AppTheme.surfaceColor.withAlpha(80),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withAlpha(60)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama transaksi harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w500,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Jumlah',
                labelStyle: const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
                hintText: 'Masukkan jumlah',
                hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor.withAlpha(80),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withAlpha(60)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah harus diisi';
                }
                final clean = value.replaceAll('.', '');
                if (double.tryParse(clean) == null) {
                  return 'Jumlah harus berupa angka';
                }
                if (double.parse(clean) <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _selectDate,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: AppTheme.surfaceColor.withAlpha(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(color: Colors.white.withAlpha(60)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      color: AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildCategoryCard() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) {
                final filteredCategories =
                    categories
                        .where((cat) => cat.isIncome == _isIncome)
                        .toList();

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      filteredCategories.map((category) {
                        final isSelected = _selectedCategory == category.name;
                        return ChipButton(
                          name: category.name,
                          onPressed:
                              () => setState(
                                () => _selectedCategory = category.name,
                              ),
                          isSelected: isSelected,
                        );
                      }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => Text(
                    'Error: $error',
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _paymentMethods.map((method) {
                    final isSelected = _selectedPaymentMethod == method;
                    return ChipButton(
                      name: method,
                      onPressed:
                          () => setState(() => _selectedPaymentMethod = method),
                      isSelected: isSelected,
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi (Opsional)',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: AppTheme.textColor),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tambahkan catatan untuk transaksi ini...',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        widget.transaction == null ? 'Simpan Transaksi' : 'Perbarui Transaksi',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
