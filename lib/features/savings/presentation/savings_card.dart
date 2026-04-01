import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/savings_provider.dart';
import 'savings_shield_dialog.dart';

class SavingsCard extends ConsumerWidget {
  const SavingsCard({super.key});
  void _showAddFundsDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add to Savings',
          style: TextStyle(color: AppColors.planned),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Amount',
            prefixText: 'KES ',
            prefixStyle: TextStyle(
              color: AppColors.planned,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                ref.read(savingsBalanceProvider.notifier).addFunds(amount);
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.planned,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(savingsBalanceProvider);

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.planned.withValues(alpha: 0.3),
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
                  const Icon(
                    Icons.lock_outline,
                    color: AppColors.planned,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Locked Savings',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: AppColors.planned),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${balance.toStringAsFixed(0)} KES',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              // Add Funds Button (Positive, Low Friction)
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.planned),
                onPressed: () => _showAddFundsDialog(
                  context,
                  ref,
                ), // <--- Use the new dialog!
              ),
              // Drawdown Button (Negative, High Friction)
              IconButton(
                icon: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.impulse,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SavingsShieldDialog(),
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
