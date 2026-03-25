import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionHistoryList extends ConsumerWidget {
  const TransactionHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the database state
    final transactionsAsync = ref.watch(transactionListProvider);

    return transactionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading data.',
          style: TextStyle(color: AppColors.impulse),
        ),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.separated(
          // Add bottom padding so the FAB doesn't cover the last item
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 100,
            left: 16,
            right: 16,
          ),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return _buildTransactionCard(context, ref, tx);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet.',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to log your first spend.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    WidgetRef ref,
    AppTransaction tx,
  ) {
    final isImpulse = tx.type == SpendType.impulse;
    // Format the date simply (e.g., 2026-03-25)
    final dateString = tx.date.toIso8601String().split('T')[0];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        // Subtle left border to flag impulse buys
        border: Border(
          left: BorderSide(
            color: isImpulse ? AppColors.impulse : AppColors.planned,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          tx.category,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            tx.note ?? dateString, // Show note if it exists, otherwise the date
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Amount
            Text(
              '${tx.amount.toStringAsFixed(0)} KES',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isImpulse ? AppColors.impulse : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),

            // The Behavioral "Regret" Toggle
            if (isImpulse) ...[
              Container(
                decoration: BoxDecoration(
                  color: tx.isRegretted
                      ? AppColors.impulse.withOpacity(0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    tx.isRegretted ? Icons.heart_broken : Icons.favorite_border,
                    color: tx.isRegretted
                        ? AppColors.impulse
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  tooltip: tx.isRegretted
                      ? 'Unmark Regret'
                      : 'Mark as Regretted',
                  onPressed: () {
                    // Update SQLite instantly
                    ref.read(transactionListProvider.notifier).toggleRegret(tx);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
