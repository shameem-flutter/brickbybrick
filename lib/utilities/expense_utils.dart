import 'package:flutter/material.dart';

class ExpenseUtils {
  static const Map<String, ({IconData icon, Color color})> categoryDetails = {
    'Food': (icon: Icons.restaurant, color: Colors.orange),
    'Travel': (icon: Icons.directions_car, color: Colors.blue),
    'Rent': (icon: Icons.home, color: Colors.purple),
    'Office': (icon: Icons.work, color: Colors.brown),
    'Shopping': (icon: Icons.shopping_bag, color: Colors.pink),
    'Subscriptions': (icon: Icons.subscriptions, color: Colors.indigo),
    'EMI/Loans': (icon: Icons.account_balance, color: Color(0xFFF59E0B)),
    'Family Support': (icon: Icons.family_restroom, color: Color(0xFF3B82F6)),
    'Entertainment': (icon: Icons.movie, color: Colors.red),
    'Health': (icon: Icons.medical_services, color: Colors.green),
    'Emergency': (icon: Icons.warning_amber_rounded, color: Color(0xFFFB7185)),
    'Savings': (icon: Icons.savings_outlined, color: Color(0xFF22C55E)),
    'General': (icon: Icons.receipt, color: Colors.grey),
  };

  static IconData getIcon(String category) {
    return categoryDetails[category]?.icon ?? Icons.receipt;
  }

  static Color getColor(String category) {
    return categoryDetails[category]?.color ?? Colors.grey;
  }
}
