import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/models/user_model.dart';

class SpendAnalysisResult {
  final bool isOverspent;
  final List<String> breachedCategories;
  final double survivalScore; // 0-100
  final int daysToBankruptcy;
  final String predictionText;

  SpendAnalysisResult({
    this.isOverspent = false,
    this.breachedCategories = const [],
    this.survivalScore = 100.0,
    this.daysToBankruptcy = 30,
    this.predictionText = "",
  });
}

class SpendAnalyzer {
  static SpendAnalysisResult analyze(
    UserProfile profile,
    List<ExpenseItem> expenses,
    double totalBudget,
    int daysRemaining,
  ) {
    double totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    List<String> breached = [];

    // 1. Category Breach Detection
    for (var rule in profile.budgetRules) {
      double categorySpent = expenses
          .where((e) => e.category == rule.category)
          .fold(0.0, (sum, e) => sum + e.amount);

      double limit = 0;
      limit = rule.fixedAmount;

      if (limit > 0 && categorySpent > limit) {
        breached.add(rule.category);
      }
    }

    // 2. Daily Burn Anomaly & Survival Prediction
    // Find how many days passed in current cycle
    final now = DateTime.now();
    DateTime cycleStart;
    if (now.day >= profile.salaryDate) {
      cycleStart = DateTime(now.year, now.month, profile.salaryDate);
    } else {
      cycleStart = DateTime(now.year, now.month - 1, profile.salaryDate);
    }
    int daysPassed = now.difference(cycleStart).inDays;
    if (daysPassed == 0) daysPassed = 1;

    double burnRate = totalSpent / daysPassed;
    double remaining = totalBudget - totalSpent;

    int daysToBankruptcy = 99;
    if (burnRate > 0) {
      daysToBankruptcy = (remaining / burnRate).floor();
    }
    if (daysToBankruptcy < 0) daysToBankruptcy = 0;

    // 3. Survival Score
    // Based on whether projected spending exceeds total budget
    double projectedEnd = totalSpent + (burnRate * daysRemaining);
    double variance = totalBudget - projectedEnd;
    double survivalScore =
        ((totalBudget / (projectedEnd > 0 ? projectedEnd : 1)) * 100).clamp(
          0,
          100,
        );

    String predictionText = "";
    if (daysToBankruptcy < daysRemaining) {
      predictionText =
          "At this rate, you'll be broke in $daysToBankruptcy days! 😱";
    } else {
      predictionText =
          "You're on track to finish the month with ₹${variance.toStringAsFixed(0)} 💰";
    }

    return SpendAnalysisResult(
      isOverspent: totalSpent > totalBudget || breached.isNotEmpty,
      breachedCategories: breached,
      survivalScore: survivalScore,
      daysToBankruptcy: daysToBankruptcy,
      predictionText: predictionText,
    );
  }
}
