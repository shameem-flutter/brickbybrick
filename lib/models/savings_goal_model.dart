class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String icon; // Icon name as string

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    this.icon = 'savings',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'icon': icon,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline']) : null,
      icon: map['icon'] ?? 'savings',
    );
  }

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;
  bool get isCompleted => currentAmount >= targetAmount;

  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? icon,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
    );
  }
}
