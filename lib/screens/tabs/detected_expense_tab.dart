import 'package:brickbybrick/models/draft_expense.dart';
import 'package:brickbybrick/services/draft_provider.dart';
import 'package:brickbybrick/services/expense_provider.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/utilities/expense_utils.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:brickbybrick/utilities/smart_categorizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DetectedExpenseTab extends ConsumerStatefulWidget {
  const DetectedExpenseTab({super.key});

  @override
  ConsumerState<DetectedExpenseTab> createState() => _DetectedExpenseTabState();
}

class _DetectedExpenseTabState extends ConsumerState<DetectedExpenseTab> {
  // We keep a local map of draftId -> selectedCategory so users can change it before confirming
  final Map<String, String> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    // Fetch drafts when tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(draftProvider.notifier).loadDrafts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final draftsAsync = ref.watch(draftProvider);
    final isSaving = ref.watch(expenseControllerProvider).isLoading;

    return draftsAsync.when(
      data: (drafts) {
        if (drafts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 48,
                  color: AppTheme.textGrey.withValues(alpha: 0.5),
                ),
                vertGap(16),
                Text(
                  "No transaction SMS found",
                  style: TextStyle(color: AppTheme.textGrey),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(draftProvider.notifier).loadDrafts(),
                  child: const Text("Refresh"),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: drafts.length,
          separatorBuilder: (_, __) => vertGap(16),
          itemBuilder: (context, index) {
            final draft = drafts[index];
            return _buildDraftCard(draft, isSaving);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          "Error loading SMS: $err",
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDraftCard(DraftExpense draft, bool isSaving) {
    // If we haven't selected a category yet, guess it
    if (!_selectedCategories.containsKey(draft.id)) {
      _selectedCategories[draft.id] = SmartCategorizer.guessCategory(
        draft.merchant,
      );
    }

    final currentCategory = _selectedCategories[draft.id]!;

    return Container(
      padding: const EdgeInsets.all(16),
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
                  Text(
                    DateFormat('MMM d, h:mm a').format(draft.date),
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                  vertGap(4),
                  Row(
                    children: [
                      Text(
                        draft.merchant,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  vertGap(07),

                  if (draft.bankName != null && draft.bankName != 'Bank') ...[
                    horiGap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        draft.bankName!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                "₹${draft.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          vertGap(16),
          Row(
            children: [
              Expanded(
                child: _buildCategoryDropdown(draft.id, currentCategory),
              ),
              horiGap(12),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () => _confirmDraft(draft, currentCategory),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (draft.originalMessage != null) ...[
            vertGap(8),
            ExpansionTile(
              title: const Text("View SMS", style: TextStyle(fontSize: 12)),
              dense: true,
              tilePadding: EdgeInsets.zero,
              children: [
                Text(
                  draft.originalMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(String draftId, String currentCategory) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentCategory,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
          items: _allCategories.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Row(
                children: [
                  Icon(
                    ExpenseUtils.getIcon(c),
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  horiGap(8),
                  Text(c, style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCategories[draftId] = val;
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _confirmDraft(DraftExpense draft, String category) async {
    // Save to Firestore
    await ref
        .read(expenseControllerProvider.notifier)
        .addExpense(
          amount: draft.amount,
          category: category,
          description: "Detected from SMS: ${draft.merchant}",
          proofImage: null, // No image parsing yet
        );

    final state = ref.read(expenseControllerProvider);
    if (!state.hasError) {
      // Remove from local draft list
      ref.read(draftProvider.notifier).removeDraft(draft.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Added expense for ${draft.merchant}")),
        );
      }
    }
  }

  final List<String> _allCategories = [
    'Food',
    'Rent',
    'Travel',
    'Office',
    'Shopping',
    'Subscriptions',
    'EMI/Loans',
    'Family Support',
    'Entertainment',
    'Health',
    'Emergency',
    'Savings',
    'General',
  ];
}
