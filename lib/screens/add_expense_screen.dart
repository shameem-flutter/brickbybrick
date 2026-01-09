import 'package:brickbybrick/screens/tabs/detected_expense_tab.dart';
import 'package:brickbybrick/screens/tabs/manual_expense_tab.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Transaction"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textBody,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textGrey,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: "Manual Entry"),
            Tab(text: "Detected (SMS)"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ManualExpenseTab(),
          DetectedExpenseTab(),
        ],
      ),
    );
  }
}
