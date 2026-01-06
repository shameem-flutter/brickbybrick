import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to get all expenses for the current month
final currentMonthExpensesProvider = StreamProvider<List<ExpenseItem>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  
  final now = DateTime.now();
  return ref.read(firestoreServiceProvider).getExpensesByMonth(uid, now.year, now.month);
});

class DashboardState {
  final double safeToSpendDaily;
  final double burnedAmount;
  final double remainingAmount;
  final double dailyBurnRate;
  final int daysRemaining;
  final double totalBudget;

  const DashboardState({
    this.safeToSpendDaily = 0.0,
    this.burnedAmount = 0.0,
    this.remainingAmount = 0.0,
    this.dailyBurnRate = 0.0,
    this.daysRemaining = 0,
    this.totalBudget = 0.0,
  });
}

final dashboardControllerProvider = Provider<DashboardState>((ref) {
  // Let's create a computed provider that watches both streams.
  return DashboardState(); // Placeholder
});

final dashboardMetricsProvider = Provider.autoDispose<AsyncValue<DashboardState>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const AsyncValue.data(DashboardState());

  final userProfileAsync = ref.watch(userDataProvider(uid));
  final expensesAsync = ref.watch(currentMonthExpensesProvider);

  if (userProfileAsync.isLoading || expensesAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final profile = userProfileAsync.value;
  final expenses = expensesAsync.value ?? [];

  if (profile == null) return const AsyncValue.data(DashboardState());

  // Calculations
  final now = DateTime.now();
  // Find salary cycle end date
  DateTime cycleStart;
  if (now.day >= profile.salaryDate) {
    cycleStart = DateTime(now.year, now.month, profile.salaryDate);
  } else {
     cycleStart = DateTime(now.year, now.month - 1, profile.salaryDate);
  }
  
  DateTime cycleEnd = DateTime(cycleStart.year, cycleStart.month + 1, cycleStart.day);
  
  int totalDays = cycleEnd.difference(cycleStart).inDays;
  int daysPassed = now.difference(cycleStart).inDays;
  int daysRemaining = totalDays - daysPassed;
  if (daysRemaining < 1) daysRemaining = 1;

  // Amounts
  double salary = profile.monthlySalary;
  
  double totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);
  
  double availablePool = salary - (salary * profile.rentSplit) - (salary * profile.savingsSplit);
  
  double remaining = availablePool - totalSpent;
  double safeDaily = remaining / daysRemaining;
  
  double currentBurnRate = totalSpent / (daysPassed == 0 ? 1 : daysPassed);

  return AsyncValue.data(DashboardState(
    safeToSpendDaily: safeDaily,
    burnedAmount: totalSpent,
    remainingAmount: remaining,
    dailyBurnRate: currentBurnRate,
    daysRemaining: daysRemaining,
    totalBudget: availablePool,
  ));
});

final userDataProvider = StreamProvider.family<UserProfile?, String>((ref, uid) {
  return ref.read(firestoreServiceProvider).getUserProfileStream(uid);
});
