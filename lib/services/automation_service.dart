import 'package:brickbybrick/models/user_model.dart';
import 'package:brickbybrick/models/user_stats_model.dart';
import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/services/salary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final automationServiceProvider = Provider((ref) => AutomationService(ref));

final userStatsStreamProvider = StreamProvider<UserStats?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).getUserStatsStream(uid);
});

class AutomationService {
  final Ref _ref;
  AutomationService(this._ref);

  Future<void> checkAndRunRollover() async {
    final uid = _ref.read(currentUserIdProvider);
    if (uid == null) return;

    // Run gamification check first
    await _checkAndScaleStats(uid);

    final profile = await _ref.read(userProfileStreamProvider.future);
    if (profile == null) return;

    final now = DateTime.now();
    final lastRollover = profile.lastRolloverDate;

    bool shouldRollover = false;
    
    if (lastRollover == null) {
        shouldRollover = true;
    } else {
        DateTime currentCycleStart;
        if (now.day >= profile.salaryDate) {
            currentCycleStart = DateTime(now.year, now.month, profile.salaryDate);
        } else {
            currentCycleStart = DateTime(now.year, now.month - 1, profile.salaryDate);
        }

        if (lastRollover.isBefore(currentCycleStart)) {
            shouldRollover = true;
        }
    }

    if (shouldRollover) {
        await _runRollover(profile, now);
    }
  }

  Future<void> _checkAndScaleStats(String uid) async {
    final stats = await _ref.read(userStatsStreamProvider.future);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (stats == null) {
        final newStats = UserStats(
            userId: uid,
            streakCount: 1,
            totalXP: 50,
            lastLoginDate: today,
        );
        await _ref.read(firestoreServiceProvider).saveUserStats(newStats);
        return;
    }

    final lastLogin = stats.lastLoginDate;
    if (lastLogin == null) {
        await _ref.read(firestoreServiceProvider).saveUserStats(stats.copyWith(lastLoginDate: today, streakCount: 1));
        return;
    }

    final diff = today.difference(DateTime(lastLogin.year, lastLogin.month, lastLogin.day)).inDays;

    if (diff == 1) {
        final updated = stats.copyWith(
            streakCount: stats.streakCount + 1,
            totalXP: stats.totalXP + 10,
            lastLoginDate: today,
        );
        await _ref.read(firestoreServiceProvider).saveUserStats(updated);
    } else if (diff > 1) {
        final updated = stats.copyWith(
            streakCount: 1,
            lastLoginDate: today,
        );
        await _ref.read(firestoreServiceProvider).saveUserStats(updated);
    }
  }

  Future<void> awardXP(int amount) async {
      final uid = _ref.read(currentUserIdProvider);
      if (uid == null) return;
      final statsProviderFuture = _ref.read(userStatsStreamProvider.future);
      final stats = await statsProviderFuture;
      if (stats != null) {
          await _ref.read(firestoreServiceProvider).saveUserStats(stats.copyWith(totalXP: stats.totalXP + amount));
      }
  }

  Future<void> _runRollover(UserProfile profile, DateTime now) async {
      // Calculate remaining from last month (this is complex because we need past expenses)
      // For MVP, we'll just log the rollover and maybe carry over some value if planned.
      // User says: "Carry forward savings, Flag negative balance"
      
      // In more complex version, we'd fetch last month's metrics.
      // For now, let's just update the lastRolloverDate to prevent infinite loop.
      
      final updatedProfile = profile.copyWith(
          lastRolloverDate: now,
          // carriedOverAmount: ... logic here ...
      );

      await _ref.read(firestoreServiceProvider).saveUserProfile(updatedProfile);
  }
}
