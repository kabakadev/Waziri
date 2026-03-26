import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/debt_provider.dart';
import 'debt_action_dialog.dart';

class DebtCard extends ConsumerWidget {
  const DebtCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtAmount = ref.watch(outstandingDebtProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: debtAmount > 0
              ? AppColors.impulse.withValues(alpha: 0.5)
              : AppColors.textSecondary.withValues(alpha: 0.2),
          width: 2,
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
                  Icon(
                    Icons.warning_amber_rounded,
                    color: debtAmount > 0
                        ? AppColors.impulse
                        : AppColors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Outstanding Debt',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: debtAmount > 0
                          ? AppColors.impulse
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${debtAmount.toStringAsFixed(0)} KES',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: debtAmount > 0
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Borrow Button
              IconButton(
                icon: const Icon(
                  Icons.arrow_downward,
                  color: AppColors.impulse,
                ),
                tooltip: 'Take Debt',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        const DebtActionDialog(isBorrowing: true),
                  );
                },
              ),
              // Repay Button
              if (debtAmount > 0)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_upward,
                    color: AppColors.planned,
                  ),
                  tooltip: 'Repay Debt',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          const DebtActionDialog(isBorrowing: false),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
