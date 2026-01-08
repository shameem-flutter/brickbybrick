import 'package:brickbybrick/models/user_model.dart';
import 'package:brickbybrick/providers/bottom_nav_providers.dart';
import 'package:brickbybrick/services/salary_provider.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final Set<String> expandedRules = {};
  // Controllers
  final _salaryController = TextEditingController();
  final _customProfessionController = TextEditingController();
  final Map<String, TextEditingController> _ruleAmountControllers = {};

  // Form State
  String? _selectedProfession;
  String _incomeType = 'Fixed salary';
  String _budgetMode = 'Salary-based';
  int _salaryDate = 1;
  List<BudgetRule> _budgetRules = [];

  bool _initialized = false;
  final _uuid = Uuid();

  static const _professions = [
    'IT',
    'Student',
    'Freelancer',
    'Business',
    'Other',
  ];

  static const _categories = [
    'Rent',
    'Food',
    'Travel',
    'Office',
    'Entertainment',
    'Shopping',
    'Subscriptions',
    'Other',
  ];

  @override
  void dispose() {
    _salaryController.dispose();
    _customProfessionController.dispose();
    for (var c in _ruleAmountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProfileStreamProvider, (prev, next) {
      if (!_initialized && next.hasValue && next.value != null) {
        _loadProfile(next.value!);
        _initialized = true;
      }
    });

    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        centerTitle: false,
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (_) => _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final saveState = ref.watch(salaryControllerProvider);
    final profile = ref.watch(userProfileStreamProvider).valueOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(profile),
          vertGap(40),
          _buildSectionHeader("Personalization"),
          vertGap(16),
          _buildCardSection([
            _buildProfessionInput(),
            if (_selectedProfession == 'Other') ...[
              vertGap(16),
              _buildTextInput(_customProfessionController, "Custom Profession"),
            ],
          ]),
          vertGap(32),
          _buildSectionHeader("Income Details"),
          vertGap(16),
          _buildIncomeTypeSelector(),
          vertGap(20),
          _buildCardSection([
            _buildTextInput(
              _salaryController,
              _budgetMode == 'Salary-based'
                  ? "Monthly Salary"
                  : "Monthly Budget",
              prefix: "₹ ",
              keyboardType: TextInputType.number,
            ),
          ]),
          vertGap(20),
          _buildSalaryDateCard(),
          vertGap(32),
          _buildSectionHeader("Budget Strategy"),
          vertGap(16),
          _buildBudgetModeSelector(),
          if (_budgetMode == 'Salary-based') ...[
            vertGap(32),
            _buildSectionHeader("Budget Rules"),
            vertGap(16),
            _buildBudgetRulesList(),
            vertGap(24),
            Center(child: _buildAddRuleButton()),
          ],
          _buildSaveButton(saveState.isLoading),
          vertGap(24),
        ],
      ),
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCard,
      child: Column(children: children),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddRuleButton() {
    return TextButton.icon(
      onPressed: _addNewRule,
      icon: const Icon(Icons.add_circle_outline_rounded),
      label: const Text("New Budget Rule"),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? profile) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: AppTheme.primaryGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          vertGap(20),
          Text(
            profile?.name ?? "Builder",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            profile?.email ?? "email@example.com",
            style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(
    TextEditingController controller,
    String label, {
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        labelStyle: TextStyle(color: AppTheme.textGrey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.textGrey.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildProfessionInput() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedProfession,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textGrey),
      decoration: InputDecoration(
        labelText: "Profession",
        labelStyle: TextStyle(color: AppTheme.textGrey),
        border: InputBorder.none,
      ),
      items: _professions
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: (v) => setState(() => _selectedProfession = v),
    );
  }

  Widget _buildIncomeTypeSelector() {
    return Container(
      decoration: AppTheme.premiumCard,
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text(
              "Fixed Salary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Regular monthly income",
              style: TextStyle(color: AppTheme.textGrey),
            ),
            value: 'Fixed salary',
            groupValue: _incomeType,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _incomeType = v!),
          ),
          RadioListTile<String>(
            title: const Text(
              "Variable Income",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Irregular or freelance earnings",
              style: TextStyle(color: AppTheme.textGrey),
            ),
            value: 'Variable income',
            groupValue: _incomeType,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _incomeType = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetModeSelector() {
    return Container(
      decoration: AppTheme.premiumCard,
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text(
              "Salary-based",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Auto-allocate based on rules",
              style: TextStyle(color: AppTheme.textGrey),
            ),
            value: 'Salary-based',
            groupValue: _budgetMode,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _budgetMode = v!),
          ),
          RadioListTile<String>(
            title: const Text(
              "Manual Track",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Self-managed expenses only",
              style: TextStyle(color: AppTheme.textGrey),
            ),
            value: 'Budget-only',
            groupValue: _budgetMode,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _budgetMode = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryDateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cycle Start Day",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          vertGap(16),
          Row(
            children: [
              Text(
                "$_salaryDate",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              horiGap(16),
              Expanded(
                child: Slider(
                  value: _salaryDate.toDouble(),
                  min: 1,
                  max: 31,
                  divisions: 30,
                  activeColor: AppTheme.primary,
                  inactiveColor: AppTheme.primary.withValues(alpha: 0.1),
                  onChanged: (v) => setState(() => _salaryDate = v.round()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRulesList() {
    if (_budgetRules.isEmpty) {
      return Card(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              "No budget rules added yet.\nTap below to create one.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      children: _budgetRules.map((rule) => _buildRuleCard(rule)).toList(),
    );
  }

  Widget _buildRuleCard(BudgetRule rule) {
    // Safely get or create controller
    if (!_ruleAmountControllers.containsKey(rule.id)) {
      _ruleAmountControllers[rule.id] = TextEditingController(
        text: rule.isPercentage
            ? (rule.percentage * 100).toStringAsFixed(0)
            : rule.fixedAmount.toStringAsFixed(0),
      );
    }
    final controller = _ruleAmountControllers[rule.id]!;

    final isExpanded = expandedRules.contains(rule.id);

    return Card(
      key: ValueKey(rule.id),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header tile (always visible)
          Material(
            color: isExpanded
                ? Theme.of(context).colorScheme.surface
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expandedRules.remove(rule.id);
                  } else {
                    expandedRules.add(rule.id);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Category icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(rule.category),
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rule.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rule.isPercentage
                                ? "${(rule.percentage * 100).toStringAsFixed(0)}% of salary"
                                : "₹${rule.fixedAmount.toStringAsFixed(0)} fixed",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Delete button
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _deleteRule(rule),
                    ),

                    // Expand icon
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expandable content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: rule.category,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null && v != rule.category) {
                        _updateRule(rule.copyWith(category: v));
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text("Percentage"),
                        icon: Icon(Icons.percent),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text("Fixed Amount"),
                        icon: Icon(Icons.currency_rupee),
                      ),
                    ],
                    selected: {rule.isPercentage},
                    onSelectionChanged: (set) {
                      final isPercentage = set.first;
                      if (isPercentage != rule.isPercentage) {
                        final newRule = rule.copyWith(
                          isPercentage: isPercentage,
                          percentage: isPercentage
                              ? (rule.percentage > 0 ? rule.percentage : 0.1)
                              : 0,
                          fixedAmount: isPercentage
                              ? 0
                              : (rule.fixedAmount > 0
                                    ? rule.fixedAmount
                                    : 1000),
                        );
                        _updateRule(newRule);

                        // Update controller text
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.text = isPercentage
                              ? (newRule.percentage * 100).toStringAsFixed(0)
                              : newRule.fixedAmount.toStringAsFixed(0);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: rule.isPercentage
                          ? "Percentage of salary"
                          : "Fixed amount",
                      prefixText: rule.isPercentage ? null : "₹ ",
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final val = double.tryParse(value);
                      if (val != null && val >= 0) {
                        _updateRule(
                          rule.copyWith(
                            percentage: rule.isPercentage ? val / 100 : 0,
                            fixedAmount: rule.isPercentage ? 0 : val,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to get category icon
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Rent':
        return Icons.home_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.directions_car_rounded;
      case 'Office':
        return Icons.business_center_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Subscriptions':
        return Icons.subscriptions_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _addNewRule() {
    final newRule = BudgetRule(
      id: _uuid.v4(),
      category: 'Other',
      isPercentage: true,
      percentage: 0.1,
      priority: 'soft',
    );
    setState(() {
      _budgetRules.add(newRule);
      _ruleAmountControllers[newRule.id] = TextEditingController(text: "10");
    });
  }

  void _deleteRule(BudgetRule rule) {
    setState(() {
      expandedRules.remove(rule.id);
      _budgetRules.remove(rule);
      _ruleAmountControllers.remove(rule.id)?.dispose();
    });
  }

  void _updateRule(BudgetRule updated) {
    setState(() {
      final index = _budgetRules.indexWhere((r) => r.id == updated.id);
      if (index != -1) _budgetRules[index] = updated;
    });
  }

  Future<void> _saveProfile() async {
    final salary =
        double.tryParse(_salaryController.text.replaceAll(',', '')) ?? 0;
    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    final profession = _selectedProfession == 'Other'
        ? _customProfessionController.text.trim()
        : _selectedProfession;

    if (profession == null || profession.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select or enter a profession")),
      );
      return;
    }

    await ref
        .read(salaryControllerProvider.notifier)
        .updateProfile(
          salary: salary,
          salaryDate: _salaryDate,
          profession: profession,
          incomeType: _incomeType,
          budgetMode: _budgetMode,
          budgetRules: _budgetRules,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      ref.read(bottomNavIndexProvider.notifier).state = 0;
    }
  }

  Widget _buildSaveButton(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? SizedBox(
                    key: ValueKey("loader"),
                    height: 22,
                    width: 22,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "Save Profile",
                    key: ValueKey("key"),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  void _loadProfile(UserProfile profile) {
    _salaryController.text = profile.monthlySalary > 0
        ? profile.monthlySalary.toStringAsFixed(0)
        : '';
    _salaryDate = profile.salaryDate.clamp(1, 31);
    _incomeType = profile.incomeType;
    _budgetMode = profile.budgetMode;
    _budgetRules = List.from(profile.budgetRules);

    if (_professions.contains(profile.profession)) {
      _selectedProfession = profile.profession;
    } else if (profile.profession?.isNotEmpty == true) {
      _selectedProfession = 'Other';
      _customProfessionController.text = profile.profession!;
    }

    _ruleAmountControllers.clear();
    for (final rule in _budgetRules) {
      final value = rule.isPercentage
          ? rule.percentage * 100
          : rule.fixedAmount;
      _ruleAmountControllers[rule.id] = TextEditingController(
        text: value.toStringAsFixed(0),
      );
    }

    setState(() {});
  }
}
