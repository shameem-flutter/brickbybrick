import 'package:brickbybrick/models/user_stats_model.dart';
import 'package:brickbybrick/services/automation_service.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Growth Metrics"),
        centerTitle: false,
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats == null) return const Center(child: Text("Loading stats..."));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStreakCard(stats),
                vertGap(32),
                _buildLevelCard(stats),
                vertGap(32),
                _buildAchievementsSection(stats),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildStreakCard(UserStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8E53), Color(0xFFFF2E97)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2E97).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Activity Streak",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              vertGap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${stats.streakCount}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12, left: 8),
                    child: Text(
                      "DAYS",
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.fireplace_rounded, color: Colors.white, size: 80),
        ],
      ),
    );
  }

  Widget _buildLevelCard(UserStats stats) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.premiumCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current Standing", style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                  Text(
                    "Commander Level ${stats.level}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "${stats.totalXP} XP",
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          vertGap(24),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: stats.levelProgress.clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          vertGap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.textGrey),
              horiGap(8),
              Text(
                "${(100 - (stats.totalXP % 100)).toInt()} XP to reach next rank",
                style: TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(UserStats stats) {
    final allAchievements = [
      {'name': 'Novice Builder', 'req': 'Level 1 reached', 'icon': Icons.handyman_rounded, 'unlocked': true},
      {'name': 'Constant Logger', 'req': '7 day streak', 'icon': Icons.calendar_today_rounded, 'unlocked': stats.streakCount >= 7},
      {'name': 'Budget Master', 'req': 'Month under budget', 'icon': Icons.verified_user_rounded, 'unlocked': false},
      {'name': 'Brick Layer', 'req': 'Saved ₹10,000', 'icon': Icons.layers_rounded, 'unlocked': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Empire Achievements",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        vertGap(20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: allAchievements.length,
          itemBuilder: (context, index) => _buildAchievementItem(allAchievements[index]),
        ),
      ],
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] as bool;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCard.copyWith(
        color: isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.6),
        border: Border.all(
          color: isUnlocked ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? AppTheme.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement['icon'] as IconData,
              size: 32,
              color: isUnlocked ? AppTheme.primary : AppTheme.textGrey.withValues(alpha: 0.3),
            ),
          ),
          vertGap(16),
          Text(
            achievement['name'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isUnlocked ? AppTheme.textBody : AppTheme.textGrey,
            ),
          ),
          vertGap(4),
          Text(
            achievement['req'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
