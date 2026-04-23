// lib/features/dashboard/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../transactions/presentation/add_transaction_sheet.dart';
import '../../transactions/presentation/transaction_history_list.dart';
import 'widgets/dashboard_accumulators.dart';
import '../../savings/presentation/savings_card.dart';
import '../../debt/presentation/debt_card.dart';
import '../../gamification/presentation/streak_badge.dart'; // NEW LINE
import '../../../core/utils/permission_manager.dart';
import '../../transactions/services/sms_sync_service.dart';
import '../../transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We add a DefaultTabController to manage the swipeable tabs

    return DefaultTabController(
      length: 2, // Two tabs: Activity and Vault
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Waziri'),
          elevation: 0,
          // NEW LINES - ADD THIS ACTIONS SECTION
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () async {
                // 1. Show scanning UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scanning M-Pesa inbox...')),
                );

                // 2. Run the background sync service
                final service = SmsSyncService();
                final receipts = await service.syncMpesaHistory();

                if (receipts.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No M-Pesa transactions found.'),
                      ),
                    );
                  }
                  return;
                }

                // 3. Send to Riverpod to save to SQLite!
                // Using ref.read to access your provider's methods
                final addedCount = await ref
                    .read(transactionListProvider.notifier)
                    .importMpesaTransactions(receipts);

                // 4. Show the final result
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Synced $addedCount new M-Pesa transactions!',
                      ),
                      backgroundColor: addedCount > 0
                          ? Colors.green
                          : Colors.blue,
                    ),
                  );
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: StreakBadge()),
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
