import 'package:brickbybrick/providers/bottom_nav_providers.dart';
import 'package:brickbybrick/screens/analytics_screen.dart';
import 'package:brickbybrick/screens/growth_screen.dart';
import 'package:brickbybrick/screens/homescreen.dart';
import 'package:brickbybrick/screens/profile_screen.dart';
import 'package:brickbybrick/screens/savings_goals_screen.dart';
import 'package:brickbybrick/services/automation_service.dart';
import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const List<Widget> _screens = [
    Homescreen(),
    AnalyticsScreen(),
    SavingsGoalsScreen(),
    GrowthScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: GNav(
              rippleColor: AppTheme.primary.withValues(alpha: 0.1),
              hoverColor: AppTheme.primary.withValues(alpha: 0.05),
              gap: 8,
              activeColor: AppTheme.primary,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 300),
              tabBackgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              color: AppTheme.textGrey,
              tabs: const [
                GButton(icon: Icons.grid_view_rounded, text: 'Home'),
                GButton(icon: Icons.insights_rounded, text: 'Stats'),
                GButton(icon: Icons.account_balance_rounded, text: 'Vault'),
                GButton(icon: Icons.emoji_events_rounded, text: 'Grow'),
                GButton(icon: Icons.person_rounded, text: 'Self'),
              ],
              selectedIndex: selectedIndex,
              onTabChange: (index) {
                ref.read(bottomNavIndexProvider.notifier).state = index;
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authServiceProvider).signOut();
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(WidgetRef ref) {
    final statsAsync = ref.watch(userStatsStreamProvider);
    return statsAsync.when(
      data: (stats) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fireplace_rounded, color: Colors.orange, size: 20),
            horiGap(4),
            Text(
              "${stats?.streakCount ?? 0}",
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
