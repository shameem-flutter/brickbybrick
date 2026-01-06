
class ExpenseItem {
  final String id;
  final String userId;
  final double amount;
  final String category; // 'Rent', 'Food', 'Travel', 'Office', etc.
  final DateTime date;
  final String? description;
  final String? proofUrl; // URL from Firebase Storage

  const ExpenseItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.proofUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'proofUrl': proofUrl,
    };
  }

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'General',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      description: map['description'],
      proofUrl: map['proofUrl'],
    );
  }
}
