import 'package:brickbybrick/models/expense_model.dart';
import 'package:brickbybrick/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Profile ---

  Future<void> saveUserProfile(UserProfile user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserProfile.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // --- Expenses ---

  Future<void> addExpense(ExpenseItem expense) async {
    await _db.collection('users').doc(expense.userId).collection('expenses').doc(expense.id).set(expense.toMap());
  }

  Stream<List<ExpenseItem>> getExpensesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ExpenseItem.fromMap(doc.data())).toList();
    });
  }

   Stream<List<ExpenseItem>> getExpensesByMonth(String uid, int year, int month) {
    DateTime start = DateTime(year, month, 1);
    DateTime end = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));
    
    // Note: Firestore searching by date range requires ISO string string comparison 
    // IF we stored as strings. Since we stored as strings in toMap(), that works.
    // Ideally we store as Timestamp for better querying, but string ISO works for order too.
    // Let's rely on client side filtering for small data or refine query if needed.
    // For now, simple stream for all.
    
    return _db
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ExpenseItem.fromMap(doc.data())).toList();
    });
  }
  
  Future<void> deleteExpense(String uid, String expenseId) async {
      await _db.collection('users').doc(uid).collection('expenses').doc(expenseId).delete();
  }
}
