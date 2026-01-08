class UserStats {
  final String userId;
  final int streakCount;
  final int totalXP;
  final DateTime? lastLoginDate;
  final List<String> achievements;

  const UserStats({
    required this.userId,
    this.streakCount = 0,
    this.totalXP = 0,
    this.lastLoginDate,
    this.achievements = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'streakCount': streakCount,
      'totalXP': totalXP,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'achievements': achievements,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      userId: map['userId'] ?? '',
      streakCount: map['streakCount'] ?? 0,
      totalXP: map['totalXP'] ?? 0,
      lastLoginDate: map['lastLoginDate'] != null ? DateTime.tryParse(map['lastLoginDate']) : null,
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }

  UserStats copyWith({
    String? userId,
    int? streakCount,
    int? totalXP,
    DateTime? lastLoginDate,
    List<String>? achievements,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      streakCount: streakCount ?? this.streakCount,
      totalXP: totalXP ?? this.totalXP,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      achievements: achievements ?? this.achievements,
    );
  }

  int get level => (totalXP / 100).floor() + 1;
  double get levelProgress => (totalXP % 100) / 100;
}
