
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final double monthlySalary;
  final int salaryDate; // Day of the month (1-31)
  
  // Split Rule Percentages (0.0 to 1.0)
  final double rentSplit;
  final double foodSplit;
  final double travelSplit;
  final double savingsSplit;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.monthlySalary = 0.0,
    this.salaryDate = 1,
    this.rentSplit = 0.30,
    this.foodSplit = 0.20,
    this.travelSplit = 0.10,
    this.savingsSplit = 0.20,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'monthlySalary': monthlySalary,
      'salaryDate': salaryDate,
      'rentSplit': rentSplit,
      'foodSplit': foodSplit,
      'travelSplit': travelSplit,
      'savingsSplit': savingsSplit,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      monthlySalary: (map['monthlySalary'] ?? 0.0).toDouble(),
      salaryDate: map['salaryDate'] ?? 1,
      rentSplit: (map['rentSplit'] ?? 0.30).toDouble(),
      foodSplit: (map['foodSplit'] ?? 0.20).toDouble(),
      travelSplit: (map['travelSplit'] ?? 0.10).toDouble(),
      savingsSplit: (map['savingsSplit'] ?? 0.20).toDouble(),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    double? monthlySalary,
    int? salaryDate,
    double? rentSplit,
    double? foodSplit,
    double? travelSplit,
    double? savingsSplit,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      salaryDate: salaryDate ?? this.salaryDate,
      rentSplit: rentSplit ?? this.rentSplit,
      foodSplit: foodSplit ?? this.foodSplit,
      travelSplit: travelSplit ?? this.travelSplit,
      savingsSplit: savingsSplit ?? this.savingsSplit,
    );
  }
}
