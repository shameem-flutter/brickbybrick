import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/screens/expense_detail_screen.dart';
import 'package:brickbybrick/services/dashboard_provider.dart';
import 'package:brickbybrick/utilities/expense_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ExpenseHistoryScreen extends ConsumerWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(currentMonthExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Empire Ledger")),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppTheme.textGrey.withValues(alpha: 0.2)),
                  vertGap(16),
                  Text("No history recorded", style: TextStyle(color: AppTheme.textGrey)),
                ],
              ),
            );
          }

          final groupedExpenses = _groupExpenses(expenses);
          final sortedDates = groupedExpenses.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dateExpenses = groupedExpenses[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(context, date),
                  vertGap(12),
                  ...dateExpenses.map(
                    (expense) => _buildExpenseItem(context, expense),
                  ),
                  vertGap(24),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Map<DateTime, List<ExpenseItem>> _groupExpenses(List<ExpenseItem> expenses) {
    final Map<DateTime, List<ExpenseItem>> grouped = {};
    for (var expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(expense);
    }
    return grouped;
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String title;
    if (date == today) {
      title = "Today";
    } else if (date == yesterday) {
      title = "Yesterday";
    } else {
      title = DateFormat('MMMM dd, yyyy').format(date);
    }

    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textGrey, fontSize: 11, letterSpacing: 1),
    );
  }

  Widget _buildExpenseItem(BuildContext context, ExpenseItem expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.premiumCard,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExpenseDetailScreen(expense: expense),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ExpenseUtils.getColor(expense.category).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            ExpenseUtils.getIcon(expense.category),
            color: ExpenseUtils.getColor(expense.category),
            size: 24,
          ),
        ),
        title: Text(
          expense.category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          expense.description ?? "No description",
          style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          "₹${expense.amount.toStringAsFixed(0)}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBody),
        ),
      ),
    );
  }
}
