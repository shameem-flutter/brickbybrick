import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/services/expense_provider.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/utilities/expense_utils.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final ExpenseItem expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Receipt"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.error,
            ),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountHeader(context),
            vertGap(32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.premiumCard,
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    "CATEGORY",
                    expense.category,
                    ExpenseUtils.getIcon(expense.category),
                    isFirst: true,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    context,
                    "DATE",
                    DateFormat('MMMM dd, yyyy').format(expense.date),
                    Icons.calendar_today_rounded,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    context,
                    "TIME",
                    DateFormat('hh:mm a').format(expense.date),
                    Icons.access_time_rounded,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    context,
                    "REFERENCE ID",
                    expense.id.substring(0, 12).toUpperCase(),
                    Icons.numbers_rounded,
                    isLast: true,
                  ),
                ],
              ),
            ),
            vertGap(32),
            const Text(
              "NOTES & MEMO",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey,
                letterSpacing: 1,
              ),
            ),
            vertGap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.premiumCard,
              child: Text(
                expense.description ?? "No memo attached to this transaction.",
                style: TextStyle(
                  height: 1.5,
                  color: expense.description != null
                      ? AppTheme.textBody
                      : AppTheme.textGrey,
                ),
              ),
            ),
            if (expense.proofUrl != null) ...[
              vertGap(32),
              const Text(
                "PROOF OF PURCHASE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textGrey,
                  letterSpacing: 1,
                ),
              ),
              vertGap(12),
              GestureDetector(
                onTap: () {
                  // Full screen image preview logic could go here
                },
                child: Container(
                  decoration: AppTheme.premiumCard,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      expense.proofUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey.withValues(alpha: 0.05),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
            vertGap(40),
            Center(
              child: Text(
                "Digitally Verified Transaction",
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppTheme.primaryGradient),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "TOTAL TRANSACTION",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          vertGap(8),
          Text(
            "₹${expense.amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 16, bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          horiGap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                vertGap(4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1));
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(expenseControllerProvider.notifier)
                  .deleteExpense(expense.id);
              if (context.mounted) {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
