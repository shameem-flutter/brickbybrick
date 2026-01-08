import 'package:uuid/uuid.dart';

class BudgetRule {
  final String id;
  final String category;

  /// true → percentage | false → fixed
  final bool isPercentage;

  final double percentage; // 0 → 1
  final double fixedAmount; // >= 0
  final String priority; // hard | soft

  const BudgetRule({
    required this.id,
    required this.category,
    required this.isPercentage,
    this.percentage = 0,
    this.fixedAmount = 0,
    this.priority = 'soft',
  });

  BudgetRule copyWith({
    String? category,
    bool? isPercentage,
    double? percentage,
    double? fixedAmount,
    String? priority,
  }) {
    final usePercentage = isPercentage ?? this.isPercentage;

    return BudgetRule(
      id: id,
      category: category ?? this.category,
      isPercentage: usePercentage,
      percentage: usePercentage ? (percentage ?? this.percentage) : 0,
      fixedAmount: usePercentage ? 0 : (fixedAmount ?? this.fixedAmount),
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'isPercentage': isPercentage,
    'percentage': percentage,
    'fixedAmount': fixedAmount,
    'priority': priority,
  };

  factory BudgetRule.fromMap(Map<String, dynamic> map) {
    final isPercentage = map['isPercentage'] ?? true;

    return BudgetRule(
      id: map['id'] ?? const Uuid().v4(),
      category: map['category'] ?? 'Other',
      isPercentage: isPercentage,
      percentage: isPercentage ? (map['percentage'] ?? 0).toDouble() : 0,
      fixedAmount: isPercentage ? 0 : (map['fixedAmount'] ?? 0).toDouble(),
      priority: map['priority'] ?? 'soft',
    );
  }
}

class UserProfile {
  final String uid;
  final String email;
  final String? name;

  final double monthlySalary;
  final int salaryDate;

  final String? profession;
  final String incomeType;
  final String budgetMode;

  final List<BudgetRule> budgetRules;

  /// 🔁 REQUIRED BY automation_service
  final DateTime? lastRolloverDate;

  /// 🔁 REQUIRED BY budget_calculator
  final double carriedOverAmount;

  const UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.monthlySalary = 0,
    this.salaryDate = 1,
    this.profession,
    this.incomeType = 'Fixed salary',
    this.budgetMode = 'Salary-based',
    this.budgetRules = const [],
    this.lastRolloverDate,
    this.carriedOverAmount = 0,
  });

  UserProfile copyWith({
    double? monthlySalary,
    int? salaryDate,
    String? profession,
    String? incomeType,
    String? budgetMode,
    List<BudgetRule>? budgetRules,
    DateTime? lastRolloverDate,
    double? carriedOverAmount,
    String? name,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      salaryDate: salaryDate ?? this.salaryDate,
      profession: profession ?? this.profession,
      incomeType: incomeType ?? this.incomeType,
      budgetMode: budgetMode ?? this.budgetMode,
      budgetRules: budgetRules ?? this.budgetRules,
      lastRolloverDate: lastRolloverDate ?? this.lastRolloverDate,
      carriedOverAmount: carriedOverAmount ?? this.carriedOverAmount,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'name': name,
    'monthlySalary': monthlySalary,
    'salaryDate': salaryDate,
    'profession': profession,
    'incomeType': incomeType,
    'budgetMode': budgetMode,
    'budgetRules': budgetRules.map((e) => e.toMap()).toList(),
    'lastRolloverDate': lastRolloverDate?.toIso8601String(),
    'carriedOverAmount': carriedOverAmount,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      monthlySalary: (map['monthlySalary'] ?? 0).toDouble(),
      salaryDate: map['salaryDate'] ?? 1,
      profession: map['profession'],
      incomeType: map['incomeType'] ?? 'Fixed salary',
      budgetMode: map['budgetMode'] ?? 'Salary-based',
      budgetRules: (map['budgetRules'] as List? ?? [])
          .map((e) => BudgetRule.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      lastRolloverDate: map['lastRolloverDate'] != null
          ? DateTime.tryParse(map['lastRolloverDate'])
          : null,
      carriedOverAmount: (map['carriedOverAmount'] ?? 0).toDouble(),
    );
  }
}
