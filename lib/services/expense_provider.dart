import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/models/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) {
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
        debugPrint(
          '🟡 Starting image upload... (Platform: $defaultTargetPlatform)',
        );

        try {
          proofUrl = await _ref
              .read(storageServiceProvider)
              .uploadBillImage(uid, proofImage)
              .timeout(const Duration(seconds: 30));

          debugPrint('🟢 Image uploaded successfully: $proofUrl');
        } catch (e) {
          debugPrint('🔴 IMAGE UPLOAD FAILED: $e');

          final errorStr = e.toString().toLowerCase();

          // Check for specific configuration or installation issues
          if (errorStr.contains('channel-error') ||
              errorStr.contains('no-storage-bucket') ||
              errorStr.contains('not-initialized')) {
            debugPrint(
              '⚠️ Firebase Storage looks unconfigured. Continuing without image.',
            );
          } else {
            debugPrint(
              '⚠️ Upload failed (network or permissions). Continuing without image.',
            );
          }

          // We intentionally don't rethrow here so the expense can still be saved
          // but we set proofUrl to null as fallback.
          proofUrl = null;
        }
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

  Future<void> deleteExpense(String expenseId) async {
    state = const AsyncValue.loading();
    try {
      final uid = _ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User not logged in');

      await _ref.read(firestoreServiceProvider).deleteExpense(uid, expenseId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
