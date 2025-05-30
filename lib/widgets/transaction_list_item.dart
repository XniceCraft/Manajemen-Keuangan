import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (transaction.isIncome 
                ? AppTheme.successColor 
                : AppTheme.errorColor).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: transaction.isIncome 
                ? AppTheme.successColor 
                : AppTheme.errorColor,
            size: 24,
          ),
        ),
        title: Text(
          transaction.name,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              transaction.category,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(transaction.paymentMethod),
                  size: 14,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  transaction.paymentMethod,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.date),
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}${NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(transaction.amount)}',
              style: TextStyle(
                color: transaction.isIncome 
                    ? AppTheme.successColor 
                    : AppTheme.errorColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return LucideIcons.utensils;
      case 'transportasi':
        return LucideIcons.car;
      case 'belanja':
        return LucideIcons.shoppingBag;
      case 'hiburan':
        return LucideIcons.gamepad2;
      case 'kesehatan':
        return LucideIcons.heart;
      case 'tagihan':
        return LucideIcons.fileText;
      case 'gaji':
        return LucideIcons.wallet;
      case 'freelance':
        return LucideIcons.laptop;
      case 'investasi':
        return LucideIcons.trendingUp;
      default:
        return LucideIcons.dollarSign;
    }
  }

  IconData _getPaymentMethodIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return LucideIcons.banknote;
      case 'bank':
        return LucideIcons.creditCard;
      case 'e-wallet':
        return LucideIcons.smartphone;
      default:
        return LucideIcons.wallet;
    }
  }
}