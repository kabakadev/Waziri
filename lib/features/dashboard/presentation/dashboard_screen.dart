import 'package:flutter/material.dart';
import '../../transactions/presentation/add_transaction_sheet.dart';
import '../../transactions/presentation/transaction_history_list.dart';
import 'widgets/dashboard_accumulators.dart';
// 1. We import the SavingsCard we just built
import '../../savings/presentation/savings_card.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Waziri'), elevation: 0),
      body: const Column(
        children: [
          // 2. We drop the Savings Card right at the top of the column!
          SavingsCard(),

          // The Accumulators we built earlier
          DashboardAccumulators(),

          // The Scrollable Transaction List
          Expanded(child: TransactionHistoryList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
