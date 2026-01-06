import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/screens/analytics_screen.dart';
import 'package:brickbybrick/screens/salary_setup_screen.dart';
import 'package:brickbybrick/services/dashboard_provider.dart';
import 'package:brickbybrick/screens/add_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildHeader(context),
               const SizedBox(height: 24),
               metricsAsync.when(
                 data: (state) => _buildDashboardContent(context, state),
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (e, s) => Center(child: Text("Error: $e")),
               ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Overview", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text("Financial Health", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
              },
              icon: const Icon(FontAwesomeIcons.chartLine),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SalarySetupScreen()));
              },
              icon: const Icon(FontAwesomeIcons.gear),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardState state) {
    return Column(
      children: [
        _buildSafeToSpendCard(context, state),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInfoCard(context, "Daily Burn", "₹${state.dailyBurnRate.toStringAsFixed(0)}", Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoCard(context, "Remaining", "₹${state.remainingAmount.toStringAsFixed(0)}", Colors.green)),
          ],
        ),
        const SizedBox(height: 16),
        _buildSurvivalScore(context, state),
      ],
    );
  }

  Widget _buildSafeToSpendCard(BuildContext context, DashboardState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration.copyWith(
        gradient: LinearGradient(colors: AppTheme.primaryGradient),
      ),
      child: Column(
        children: [
          const Text("Safe to Spend Today", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            "₹${state.safeToSpendDaily.toStringAsFixed(0)}",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "${state.daysRemaining} days left in cycle",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration.copyWith(color: AppTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSurvivalScore(BuildContext context, DashboardState state) {
     // Score: logical calculation. If (SafeToSpend > DailyBurn) good.
     double score = 100;
     if (state.dailyBurnRate > state.safeToSpendDaily && state.safeToSpendDaily > 0) {
       score = (state.safeToSpendDaily / state.dailyBurnRate) * 100;
     } else if (state.remainingAmount <= 0) {
       score = 0;
     }

     return Container(
       padding: const EdgeInsets.all(16),
       decoration: AppTheme.glassDecoration.copyWith(color: AppTheme.surface),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text("Survival Score", style: TextStyle(color: Colors.grey)),
           const SizedBox(height: 16),
           LinearProgressIndicator(
             value: score / 100,
             backgroundColor: Colors.grey[800],
             valueColor: AlwaysStoppedAnimation<Color>(score > 80 ? Colors.green : (score > 40 ? Colors.orange : Colors.red)),
             minHeight: 12,
             borderRadius: BorderRadius.circular(6),
           ),
           const SizedBox(height: 8),
           Text("${score.toStringAsFixed(0)}/100", style: const TextStyle(fontWeight: FontWeight.bold)),
         ],
       ),
     );
  }
}
