import 'dart:async';
import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.read(firestoreServiceProvider).getUserProfileStream(uid);
});

final salaryControllerProvider = StateNotifierProvider<SalaryController, AsyncValue<void>>((ref) {
  return SalaryController(ref);
});

class SalaryController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  SalaryController(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateSalary({
    required double salary,
    required double rentSplit,
    required double foodSplit,
    required double travelSplit,
    required double savingsSplit,
    required int salaryDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final uid = _ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User not logged in');

      final existingProfile = await _ref
          .read(firestoreServiceProvider)
          .getUserProfileStream(uid)
          .first
          .timeout(const Duration(seconds: 10));

      final updatedProfile =
          (existingProfile ?? UserProfile(uid: uid, email: '')).copyWith(
            monthlySalary: salary,
            rentSplit: rentSplit,
            foodSplit: foodSplit,
            travelSplit: travelSplit,
            savingsSplit: savingsSplit,
            salaryDate: salaryDate,
          );

      await _ref
          .read(firestoreServiceProvider)
          .saveUserProfile(updatedProfile)
          .timeout(const Duration(seconds: 10));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      String message = e.toString();
      if (e is TimeoutException) {
        message = "Connection timed out. Please check your internet or Firebase Firestore setup.";
      }
      state = AsyncValue.error(message, st);
    }
  }
}

