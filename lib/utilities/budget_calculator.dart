import 'package:brickbybrick/models/user_model.dart';

abstract class BudgetStrategy {
  double calculateTotalBudget(UserProfile profile);
  double calculateSafeToSpend(double totalBudget, int daysRemaining);
}

class SalaryStrategy implements BudgetStrategy {
  @override
  double calculateTotalBudget(UserProfile profile) {
    double salary = profile.monthlySalary;
    double fixedTotal = 0;
    double percentageTotal = 0;

    for (var rule in profile.budgetRules) {
      fixedTotal += rule.fixedAmount;
    }

    // Available pool for daily spending is salary minus allocated rules
    double allocated = fixedTotal + (salary * percentageTotal);
    return salary - allocated + profile.carriedOverAmount;
  }

  @override
  double calculateSafeToSpend(double totalBudget, int daysRemaining) {
    if (daysRemaining < 1) return totalBudget;
    return totalBudget / daysRemaining;
  }
}

class BudgetOnlyStrategy implements BudgetStrategy {
  @override
  double calculateTotalBudget(UserProfile profile) {
    return profile.monthlySalary + profile.carriedOverAmount;
  }

  @override
  double calculateSafeToSpend(double totalBudget, int daysRemaining) {
    if (daysRemaining < 1) return totalBudget;
    return totalBudget / daysRemaining;
  }
}

class BudgetCalculator {
  static BudgetStrategy getStrategy(UserProfile profile) {
    if (profile.budgetMode == 'Budget-only') {
      return BudgetOnlyStrategy();
    }
    return SalaryStrategy();
  }

  static double calculateSafeToSpend(
    UserProfile profile,
    double burnedAmount,
    int daysRemaining,
  ) {
    final strategy = getStrategy(profile);
    double totalBudget = strategy.calculateTotalBudget(profile);
    double remaining = totalBudget - burnedAmount;

    if (profile.profession == null || profile.profession!.isEmpty) {
      return remaining / (daysRemaining < 1 ? 1 : daysRemaining);
    }

    return strategy.calculateSafeToSpend(remaining, daysRemaining);
  }
}
