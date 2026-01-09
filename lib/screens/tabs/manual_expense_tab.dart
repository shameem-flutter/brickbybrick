import 'dart:io';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/services/expense_provider.dart';
import 'package:brickbybrick/utilities/expense_utils.dart';
import 'package:brickbybrick/utilities/gap_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ManualExpenseTab extends ConsumerStatefulWidget {
  const ManualExpenseTab({super.key});

  @override
  ConsumerState<ManualExpenseTab> createState() => _ManualExpenseTabState();
}

class _ManualExpenseTabState extends ConsumerState<ManualExpenseTab> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Food';
  File? _proofImage;

  final List<String> _categories = [
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
  
  // To verify if the tab is effectively initialized
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() {
        _proofImage = File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final hadImage = _proofImage != null;

    await ref
        .read(expenseControllerProvider.notifier)
        .addExpense(
          amount: amount,
          category: _selectedCategory,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          proofImage: _proofImage,
        );

    final state = ref.read(expenseControllerProvider);
    if (state.hasError) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
      }
    } else {
      if (mounted) {
        // Check if we had an image but it might not have uploaded
        final message = hadImage
            ? 'Expense saved! (Note: Check console if image upload failed)'
            : 'Expense saved successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
        // We probably shouldn't pop here anymore as we are in a tab.
        // Instead, just clear fields or show success.
        // BUT, the original behavior was to Pop. The user might want to stay.
        // Let's clear fields for now.
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _proofImage = null;
          _selectedCategory = 'Food';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(expenseControllerProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          _buildAmountInput(),
          vertGap(48),
          _buildSectionLabel("Category"),
          vertGap(24),
          _buildCategoryGrid(),
          vertGap(40),
          _buildSectionLabel("Notes"),
          vertGap(16),
          _buildNotesInput(),
          vertGap(40),
          _buildSectionLabel("Proof of Purchase"),
          vertGap(16),
          _buildProofSection(),
          vertGap(60),
          _buildSaveButton(isLoading),
          vertGap(40),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        Text(
          "Amount",
          style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
        ),
        vertGap(8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            letterSpacing: -2,
          ),
          decoration: InputDecoration(
            prefixText: "₹",
            prefixStyle: TextStyle(
              fontSize: 32,
              color: AppTheme.primary.withValues(alpha: 0.5),
            ),
            border: InputBorder.none,
            hintText: "0",
            hintStyle: TextStyle(
              color: AppTheme.textGrey.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category;
        final icon = ExpenseUtils.getIcon(category);

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.textBody,
                  size: 24,
                ),
              ),
              vertGap(8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primary : AppTheme.textGrey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesInput() {
    return Container(
      decoration: AppTheme.premiumCard,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _descriptionController,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: "What was this for?",
          hintStyle: TextStyle(color: AppTheme.textGrey.withValues(alpha: 0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildProofSection() {
    if (_proofImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(
              _proofImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => setState(() => _proofImage = null),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.textGrey.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.camera_enhance_rounded,
              color: AppTheme.textGrey,
              size: 32,
            ),
            vertGap(8),
            Text(
              "Snap Receipt",
              style: TextStyle(
                color: AppTheme.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveExpense,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text("Authorize Transaction"),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
