import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/models/user_model.dart';
import 'package:brickbybrick/utilities/budget_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brickbybrick/utilities/spend_analyzer.dart';

// Provider to get all expenses for the current month
final currentMonthExpensesProvider = StreamProvider<List<ExpenseItem>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);

  final now = DateTime.now();
  return ref
      .read(firestoreServiceProvider)
      .getExpensesByMonth(uid, now.year, now.month);
});

class DashboardState {
  final double safeToSpendDaily;
  final double burnedAmount;
  final double remainingAmount;
  final double dailyBurnRate;
  final int daysRemaining;
  final double totalBudget;
  final SpendAnalysisResult analysis;

  DashboardState({
    this.safeToSpendDaily = 0.0,
    this.burnedAmount = 0.0,
    this.remainingAmount = 0.0,
    this.dailyBurnRate = 0.0,
    this.daysRemaining = 0,
    this.totalBudget = 0.0,
    SpendAnalysisResult? analysis,
  }) : analysis = analysis ?? _DefaultAnalysis();
}

class _DefaultAnalysis extends SpendAnalysisResult {
  _DefaultAnalysis() : super();
}

final dashboardControllerProvider = Provider<DashboardState>((ref) {
  // Let's create a computed provider that watches both streams.
  return DashboardState(); // Placeholder
});

final dashboardMetricsProvider =
    Provider.autoDispose<AsyncValue<DashboardState>>((ref) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null) return AsyncValue.data(DashboardState());

      final userProfileAsync = ref.watch(userDataProvider(uid));
      final expensesAsync = ref.watch(currentMonthExpensesProvider);

      if (userProfileAsync.isLoading || expensesAsync.isLoading) {
        return const AsyncValue.loading();
      }

      final profile = userProfileAsync.value;
      final expenses = expensesAsync.value ?? [];

      if (profile == null) return AsyncValue.data(DashboardState());

      // Calculations
      final now = DateTime.now();
      // Find salary cycle end date
      DateTime cycleStart;
      if (now.day >= profile.salaryDate) {
        cycleStart = DateTime(now.year, now.month, profile.salaryDate);
      } else {
        cycleStart = DateTime(now.year, now.month - 1, profile.salaryDate);
      }

      DateTime cycleEnd = DateTime(
        cycleStart.year,
        cycleStart.month + 1,
        cycleStart.day,
      );

      int totalDays = cycleEnd.difference(cycleStart).inDays;
      int daysPassed = now.difference(cycleStart).inDays;
      int daysRemaining = totalDays - daysPassed;
      if (daysRemaining < 1) daysRemaining = 1;

      // Amounts
      double burnedAmount = expenses.fold(
        0.0,
        (sum, item) => sum + item.amount,
      );

      final strategy = BudgetCalculator.getStrategy(profile);
      double totalBudget = strategy.calculateTotalBudget(profile);

      double remaining = totalBudget - burnedAmount;
      double safeDaily = BudgetCalculator.calculateSafeToSpend(
        profile,
        burnedAmount,
        daysRemaining,
      );

      double currentBurnRate =
          burnedAmount / (daysPassed == 0 ? 1 : daysPassed);

      final analysis = SpendAnalyzer.analyze(
        profile,
        expenses,
        totalBudget,
        daysRemaining,
      );

      return AsyncValue.data(
        DashboardState(
          safeToSpendDaily: safeDaily,
          burnedAmount: burnedAmount,
          remainingAmount: remaining,
          dailyBurnRate: currentBurnRate,
          daysRemaining: daysRemaining,
          totalBudget: totalBudget,
          analysis: analysis,
        ),
      );
    });

final userDataProvider = StreamProvider.family<UserProfile?, String>((
  ref,
  uid,
) {
  return ref.read(firestoreServiceProvider).getUserProfileStream(uid);
});
