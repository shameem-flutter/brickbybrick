import 'package:brickbybrick/models/draft_expense.dart';
import 'package:brickbybrick/services/sms_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final draftProvider = StateNotifierProvider<DraftNotifier, AsyncValue<List<DraftExpense>>>((ref) {
  return DraftNotifier();
});

class DraftNotifier extends StateNotifier<AsyncValue<List<DraftExpense>>> {
  final SmsService _smsService = SmsService();

  DraftNotifier() : super(const AsyncValue.data([]));

  Future<void> loadDrafts() async {
    state = const AsyncValue.loading();
    try {
      final drafts = await _smsService.fetchTransactionSms();
      state = AsyncValue.data(drafts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void removeDraft(String id) {
    state.whenData((drafts) {
      state = AsyncValue.data(drafts.where((d) => d.id != id).toList());
    });
  }
}
