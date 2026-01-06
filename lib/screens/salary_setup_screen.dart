import 'package:brickbybrick/models/user_model.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/services/salary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalarySetupScreen extends ConsumerStatefulWidget {
  const SalarySetupScreen({super.key});

  @override
  ConsumerState<SalarySetupScreen> createState() => _SalarySetupScreenState();
}

class _SalarySetupScreenState extends ConsumerState<SalarySetupScreen> {
  final _salaryController = TextEditingController();

  double _rentSplit = 0.30;
  double _foodSplit = 0.20;
  double _travelSplit = 0.10;
  double _savingsSplit = 0.20;
  int _salaryDate = 1;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        final profile = ref.read(userProfileStreamProvider).valueOrNull;
        if (profile != null) {
          _populateFields(profile);
        }
      }
    });
  }

  void _populateFields(UserProfile profile) {
    _salaryController.text = profile.monthlySalary.toString();
    _rentSplit = profile.rentSplit;
    _foodSplit = profile.foodSplit;
    _travelSplit = profile.travelSplit;
    _savingsSplit = profile.savingsSplit;
    _salaryDate = profile.salaryDate;
    _isInitialized = true;
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final salary = double.tryParse(_salaryController.text);
    if (salary == null) return;

    await ref
        .read(salaryControllerProvider.notifier)
        .updateSalary(
          salary: salary,
          rentSplit: _rentSplit,
          foodSplit: _foodSplit,
          travelSplit: _travelSplit,
          savingsSplit: _savingsSplit,
          salaryDate: _salaryDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    double totalSplit = _rentSplit + _foodSplit + _travelSplit + _savingsSplit;
    bool isValid = totalSplit <= 1.0;

    ref.listen<AsyncValue<UserProfile?>>(userProfileStreamProvider, (
      prev,
      next,
    ) {
      if (!_isInitialized && next.hasValue) {
        final profile = next.value;
        if (profile != null) {
          _populateFields(profile);
        }
      }
    });

    final saveState = ref.watch(salaryControllerProvider);

    final isLoading = saveState.isLoading;

    ref.listen(salaryControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Salary Settings Saved!')),
            );
            Navigator.pop(context);
          }
        },
        error: (error, stack) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $error')));
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Salary Setup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Salary",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: "₹ ",
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Split Rules (Total: ${(totalSplit * 100).toStringAsFixed(0)}%)",
              style: TextStyle(
                color: isValid ? AppTheme.primary : AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildSplitSlider(
              "Rent",
              _rentSplit,
              (v) => setState(() => _rentSplit = v),
              Colors.orange,
            ),
            _buildSplitSlider(
              "Food",
              _foodSplit,
              (v) => setState(() => _foodSplit = v),
              Colors.green,
            ),
            _buildSplitSlider(
              "Travel",
              _travelSplit,
              (v) => setState(() => _travelSplit = v),
              Colors.blue,
            ),
            _buildSplitSlider(
              "Savings",
              _savingsSplit,
              (v) => setState(() => _savingsSplit = v),
              Colors.purple,
            ),

            const SizedBox(height: 16),

            Text(
              "Salary Credited Date: $_salaryDate",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _salaryDate.toDouble(),
              min: 1,
              max: 31,
              divisions: 30,
              onChanged: (v) => setState(() => _salaryDate = v.toInt()),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isLoading || !isValid) ? null : _save,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save Configuration"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitSlider(
    String label,
    double value,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text("${(value * 100).toStringAsFixed(0)}%")],
        ),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
