import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/services/dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(currentMonthExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: expensesAsync.when(
        data: (expenses) => _buildAnalyticsContent(context, expenses),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    List<ExpenseItem> expenses,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Category Breakdown",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildCategoryPieChart(expenses),
          const SizedBox(height: 32),
          Text("Daily Spending", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildDailyBarChart(expenses),
          const SizedBox(height: 32),
          Text(
            "Expense Heatmap",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildExpenseHeatmap(expenses),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(List<ExpenseItem> expenses) {
    if (expenses.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No expenses to display")),
      );
    }

    // Group by category
    Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int colorIndex = 0;
    final sections = categoryTotals.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\n₹${entry.value.toStringAsFixed(0)}',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Widget _buildDailyBarChart(List<ExpenseItem> expenses) {
    if (expenses.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No expenses to display")),
      );
    }

    // Group by day
    Map<int, double> dailyTotals = {};
    for (var expense in expenses) {
      final day = expense.date.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + expense.amount;
    }

    final maxY = dailyTotals.values.isEmpty
        ? 1000.0
        : dailyTotals.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barGroups: dailyTotals.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: AppTheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildExpenseHeatmap(List<ExpenseItem> expenses) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Create a map of day -> total amount
    Map<int, double> dailyAmounts = {};
    for (var expense in expenses) {
      final day = expense.date.day;
      dailyAmounts[day] = (dailyAmounts[day] ?? 0) + expense.amount;
    }

    final maxAmount = dailyAmounts.values.isEmpty
        ? 1.0
        : dailyAmounts.values.reduce((a, b) => a > b ? a : b);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final amount = dailyAmounts[day] ?? 0;
        final intensity = amount / (maxAmount == 0 ? 1 : maxAmount);

        return Container(
          decoration: BoxDecoration(
            color: amount == 0
                ? AppTheme.surface
                : AppTheme.primary.withValues(alpha: 0.2 + (intensity * 0.8)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: amount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}
