import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/providers/transaction_provider.dart';

class DashboardAccumulators extends ConsumerWidget {
  const DashboardAccumulators({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return transactionsAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => const SizedBox(
        height: 120,
        child: Center(child: Text('Failed to load stats')),
      ),
      data: (transactions) {
        final now = DateTime.now();

        // 1. Today's Spend
        final todayTx = transactions.where(
          (tx) =>
              tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day,
        );
        final todayTotal = todayTx.fold(0.0, (sum, tx) => sum + tx.amount);

        // 2. This Month's Impulse Total
        final monthImpulseTx = transactions.where(
          (tx) =>
              tx.type == SpendType.impulse &&
              tx.date.year == now.year &&
              tx.date.month == now.month,
        );
        final impulseTotal = monthImpulseTx.fold(
          0.0,
          (sum, tx) => sum + tx.amount,
        );

        // 3. Small Amount Radar (Last 7 days, under 100 KES)
        final weekAgo = now.subtract(const Duration(days: 7));
        final smallTx = transactions.where(
          (tx) => tx.amount < 100 && tx.date.isAfter(weekAgo),
        );
        final smallTotal = smallTx.fold(0.0, (sum, tx) => sum + tx.amount);
        final smallCount = smallTx.length;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Row: Today & Impulse
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: "Today's Spend",
                      amount: todayTotal,
                      color: AppColors.primary,
                      icon: Icons.today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Impulse (Month)',
                      amount: impulseTotal,
                      color: AppColors.impulse,
                      icon: Icons.local_fire_department,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bottom Row: Small Amount Radar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.radar,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Small Amount Radar',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$smallCount leaks this week (<100 KES)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Text(
                      '${smallTotal.toStringAsFixed(0)} KES',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: color, width: 3),
        ), // Distinct top accent
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${amount.toStringAsFixed(0)} KES',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
