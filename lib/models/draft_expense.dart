class DraftExpense {
  final String id;
  final double amount;
  final String merchant;
  final DateTime date;
  final String? originalMessage;
  final String? bankName;
  
  // We don't store category yet because it's a guess, 
  // but we can add a helper or transient field if we want to pre-fill it.

  const DraftExpense({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.date,
    this.originalMessage,
    this.bankName,
  });
}
