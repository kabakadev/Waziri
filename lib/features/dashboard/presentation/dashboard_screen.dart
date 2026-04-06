// lib/features/dashboard/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../transactions/presentation/add_transaction_sheet.dart';
import '../../transactions/presentation/transaction_history_list.dart';
import 'widgets/dashboard_accumulators.dart';
import '../../savings/presentation/savings_card.dart';
import '../../debt/presentation/debt_card.dart';
import '../../gamification/presentation/streak_badge.dart';  // NEW LINE

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We add a DefaultTabController to manage the swipeable tabs
    return DefaultTabController(
      length: 2, // Two tabs: Activity and Vault
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Waziri'),
          elevation: 0,
          // NEW LINES - ADD THIS ACTIONS SECTION
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: StreakBadge(),
              ),
            ),
          ],
          // END OF NEW LINES
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Activity'),
              Tab(text: 'Vault & Debt'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // TAB 1: ACTIVITY (Focuses entirely on daily behavior)
            Column(
              children: [
                DashboardAccumulators(),
                Expanded(child: TransactionHistoryList()),
              ],
            ),

            // TAB 2: VAULT & DEBT (Your big cards with exposed buttons)
            SingleChildScrollView(
              padding: EdgeInsets.only(top: 8.0),
              child: Column(children: [SavingsCard(), DebtCard()]),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTransactionSheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
