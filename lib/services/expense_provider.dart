import 'dart:io';
import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/models/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final expenseControllerProvider = StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) {
  return ExpenseController(ref);
});

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ExpenseController(this._ref) : super(const AsyncValue.data(null));

  Future<void> addExpense({
    required double amount,
    required String category,
    String? description,
    File? proofImage,
  }) async {
    state = const AsyncValue.loading();
    try {
      final uid = _ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User not logged in');

      String? proofUrl;
      if (proofImage != null) {
        proofUrl = await _ref.read(storageServiceProvider).uploadBillImage(uid, proofImage);
      }

      final expense = ExpenseItem(
        id: const Uuid().v4(),
        userId: uid,
        amount: amount,
        category: category,
        date: DateTime.now(),
        description: description,
        proofUrl: proofUrl,
      );

      await _ref.read(firestoreServiceProvider).addExpense(expense);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
