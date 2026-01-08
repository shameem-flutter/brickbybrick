import 'package:brickbybrick/models/savings_goal_model.dart';
import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getSavingsGoals(uid);
});

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Brick Vault"), centerTitle: false),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: goals.length,
            itemBuilder: (context, index) =>
                _buildGoalCard(context, ref, goals[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalSheet(context, ref),
        label: const Text("New Brick"),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 80,
              color: AppTheme.primary.withValues(alpha: 0.2),
            ),
          ),
          vertGap(24),
          Text(
            "Your vault is empty",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          vertGap(8),
          Text(
            "Start building your bricks today!",
            style: TextStyle(color: AppTheme.textGrey),
          ),
          vertGap(32),
          ElevatedButton(
            onPressed: () => _showAddGoalSheet(context, ref),
            child: const Text("Create First Goal"),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIcon(goal.icon),
              horiGap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Target: ₹${goal.targetAmount.toStringAsFixed(0)}",
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${(goal.progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          vertGap(24),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: goal.progress.clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppTheme.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          vertGap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Savings",
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  ),
                  Text(
                    "₹${goal.currentAmount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showTopUpSheet(context, ref, goal),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 0,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 18),
                    horiGap(4),
                    Text("Brick It"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String iconName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.stars_rounded, color: AppTheme.primary),
    );
  }

  void _showAddGoalSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            vertGap(24),
            const Text(
              "Create New Brick",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            vertGap(8),
            Text(
              "Set a goal and start building your future.",
              style: TextStyle(color: AppTheme.textGrey),
            ),
            vertGap(32),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Goal Name",
                hintText: "e.g. New iPhone, Vacation",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            vertGap(20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Target Amount",
                prefixText: "₹ ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            vertGap(32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final uid = ref.read(currentUserIdProvider);
                  if (uid != null && nameController.text.isNotEmpty) {
                    final goal = SavingsGoal(
                      id: const Uuid().v4(),
                      userId: uid,
                      name: nameController.text,
                      targetAmount: double.tryParse(amountController.text) ?? 0,
                    );
                    await ref
                        .read(firestoreServiceProvider)
                        .saveSavingsGoal(goal);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Deploy Brick"),
              ),
            ),
            vertGap(32),
          ],
        ),
      ),
    );
  }

  void _showTopUpSheet(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            vertGap(24),
            Text(
              "Add to ${goal.name}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            vertGap(8),
            Text(
              "How many bricks are you adding today?",
              style: TextStyle(color: AppTheme.textGrey),
            ),
            vertGap(32),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: "₹",
                border: InputBorder.none,
                hintText: "0",
                hintStyle: TextStyle(
                  color: AppTheme.textGrey.withValues(alpha: 0.3),
                ),
              ),
            ),
            vertGap(32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0) {
                    final updated = goal.copyWith(
                      currentAmount: goal.currentAmount + amount,
                    );
                    await ref
                        .read(firestoreServiceProvider)
                        .saveSavingsGoal(updated);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Confirm Brick"),
              ),
            ),
            vertGap(32),
          ],
        ),
      ),
    );
  }
}
