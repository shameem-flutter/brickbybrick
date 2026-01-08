import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/models/user_model.dart';
import 'package:brickbybrick/screens/expense_history_screen.dart';
import 'package:brickbybrick/screens/add_expense_screen.dart';
import 'package:brickbybrick/screens/analytics_screen.dart';
import 'package:brickbybrick/services/dashboard_provider.dart';
import 'package:brickbybrick/services/salary_provider.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/utilities/expense_utils.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brickbybrick/services/automation_service.dart';
import 'package:brickbybrick/utilities/spend_analyzer.dart';
import 'package:intl/intl.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(automationServiceProvider).checkAndRunRollover();
    });
  }

  double _calculateTodaySpent(List<ExpenseItem> expenses) {
    final now = DateTime.now();
    return expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final expensesAsync = ref.watch(currentMonthExpensesProvider);

    return Scaffold(
      body: SafeArea(
        child: metricsAsync.when(
          data: (metrics) {
            final profile = ref.watch(userProfileStreamProvider).valueOrNull;
            final todaySpent = _calculateTodaySpent(expensesAsync.value ?? []);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  vertGap(20),
                  _buildHeader(profile),
                  vertGap(32),
                  _buildIntelligenceBanner(metrics.analysis),
                  if (metrics.analysis.isOverspent) vertGap(16),
                  _buildHeroCard(metrics),
                  vertGap(28),
                  _buildPrimaryStatsRow(metrics, todaySpent),
                  vertGap(32),
                  _buildSurvivalScoreSection(metrics.analysis),
                  vertGap(32),
                  _buildSectionHeader("Quick Actions"),
                  vertGap(16),
                  _buildQuickActionsRow(context),
                  vertGap(32),
                  _buildTransactionHeader(context),
                  _buildRecentExpensesPreview(expensesAsync),
                  vertGap(40),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile? profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${profile?.name ?? 'Builder'}!",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textBody,
              ),
            ),
            Text(
              "Welcome back to your empire.",
              style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              Icon(Icons.notifications_none_rounded, color: AppTheme.textBody),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(DashboardState metrics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.primaryGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          vertGap(4),
          Text(
            "₹${metrics.remainingAmount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          vertGap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat(
                "Safe Daily",
                "₹${metrics.safeToSpendDaily.toStringAsFixed(0)}",
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildMiniStat("Days Left", "${metrics.daysRemaining}"),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildMiniStat(
                "Burn Rate",
                "₹${metrics.dailyBurnRate.toStringAsFixed(0)}/d",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryStatsRow(DashboardState metrics, double todaySpent) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Spent Today",
            "₹${todaySpent.toStringAsFixed(0)}",
            AppTheme.accent,
            Icons.arrow_downward_rounded,
          ),
        ),
        horiGap(20),
        Expanded(
          child: _buildStatCard(
            "Total Budget",
            "₹${metrics.totalBudget.toStringAsFixed(0)}",
            AppTheme.secondary,
            Icons.account_balance_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          vertGap(16),
          Text(label, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          vertGap(4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurvivalScoreSection(SpendAnalysisResult analysis) {
    final color = analysis.survivalScore > 70
        ? Colors.green
        : (analysis.survivalScore > 40 ? AppTheme.accent : AppTheme.error);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Survival Score",
                style: TextStyle(
                  color: AppTheme.textBody,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "${analysis.survivalScore.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          vertGap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: analysis.survivalScore / 100,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 12,
            ),
          ),
          vertGap(12),
          Text(
            analysis.predictionText,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textBody,
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            "Add Expense",
            Icons.add_rounded,
            AppTheme.primary,
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
          ),
        ),
        horiGap(16),
        Expanded(
          child: _buildActionButton(
            context,
            "Analytics",
            Icons.insights_rounded,
            AppTheme.secondary,
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            vertGap(8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionHeader("Recent Activity"),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExpenseHistoryScreen()),
          ),
          child: const Text("See All"),
        ),
      ],
    );
  }

  Widget _buildRecentExpensesPreview(AsyncValue expensesAsync) {
    return expensesAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                "No empires built yet today.",
                style: TextStyle(color: AppTheme.textGrey),
              ),
            ),
          );
        }
        final recent = (expenses as List).take(5).toList();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final item = recent[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.premiumCard,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    ExpenseUtils.getIcon(item.category),
                    color: AppTheme.primary,
                  ),
                ),
                title: Text(
                  item.category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(item.date),
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
                trailing: Text(
                  "₹${item.amount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text("Error: $err"),
    );
  }

  Widget _buildIntelligenceBanner(SpendAnalysisResult analysis) {
    if (!analysis.isOverspent && analysis.breachedCategories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.error),
          horiGap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.breachedCategories.isNotEmpty
                      ? "Limit Reached: ${analysis.breachedCategories.join(', ')}"
                      : "Budget Alert!",
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  analysis.predictionText,
                  style: TextStyle(
                    color: AppTheme.error.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
