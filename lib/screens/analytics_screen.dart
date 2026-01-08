import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/services/dashboard_provider.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(currentMonthExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Empire Analytics")),
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
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final topCategory = _getTopCategory(expenses);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryStats(totalSpent, topCategory, expenses.length),
          vertGap(40),
          _buildSectionHeader("Spending Distribution"),
          vertGap(20),
          _buildPieChartCard(expenses),
          vertGap(40),
          _buildSectionHeader("Daily Intensity"),
          vertGap(20),
          _buildBarChartCard(expenses),
          vertGap(40),
          _buildSectionHeader("Activity Heatmap"),
          vertGap(20),
          _buildHeatmapCard(expenses),
          vertGap(40),
        ],
      ),
    );
  }

  String _getTopCategory(List<ExpenseItem> expenses) {
    if (expenses.isEmpty) return "N/A";
    Map<String, double> totals = {};
    for (var e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSummaryStats(double total, String top, int count) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickStatCard(
            "Total Spent",
            "₹${total.toStringAsFixed(0)}",
            AppTheme.primary,
            Icons.payments_rounded,
          ),
          horiGap(16),
          _buildQuickStatCard(
            "Top Category",
            top,
            AppTheme.accent,
            Icons.stars_rounded,
          ),
          horiGap(16),
          _buildQuickStatCard(
            "Transactions",
            count.toString(),
            AppTheme.secondary,
            Icons.list_alt_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          vertGap(12),
          Text(label, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          vertGap(4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(List<ExpenseItem> expenses) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard,
      child: Column(
        children: [
          _buildCategoryPieChart(expenses),
          vertGap(24),

          // Legend or other info can go here
        ],
      ),
    );
  }

  Widget _buildBarChartCard(List<ExpenseItem> expenses) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard,
      child: _buildDailyBarChart(expenses),
    );
  }

  Widget _buildHeatmapCard(List<ExpenseItem> expenses) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard,
      child: _buildExpenseHeatmap(expenses),
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

    final colorList = [
      AppTheme.primary,
      AppTheme.accent,
      AppTheme.secondary,
      const Color(0xFF8E44AD),
      const Color(0xFF2ECC71),
      const Color(0xFFE67E22),
      const Color(0xFFD35400),
      const Color(0xFFC0392B),
    ];

    int colorIndex = 0;
    final sections = categoryTotals.entries.map((entry) {
      final color = colorList[colorIndex % colorList.length];
      colorIndex++;
      return PieChartSectionData(
        value: entry.value,
        title: '',
        color: color,
        radius: 40,
        badgeWidget: _buildPieBadge(entry.key, color),
        badgePositionPercentageOffset: 1.5,
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 4,
          centerSpaceRadius: 60,
          startDegreeOffset: -90,
        ),
      ),
    );
  }

  Widget _buildPieBadge(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
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
          barTouchData: BarTouchData(
            touchExtraThreshold: EdgeInsets.symmetric(vertical: 200),
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppTheme.primary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "₹${rod.toY.toStringAsFixed(2)}",
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barGroups: dailyTotals.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: AppTheme.primary,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY * 1.2,
                    color: AppTheme.primary.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,

                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
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
