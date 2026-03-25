import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/savings_provider.dart';
import 'savings_shield_dialog.dart';

class SavingsCard extends ConsumerWidget {
  const SavingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(savingsBalanceProvider);

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.planned.withOpacity(0.3), width: 2),
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
                onPressed: () {
                  // In a real app, you might want a small dialog to type the amount,
                  // but for testing, let's just add 1000 KES directly.
                  ref.read(savingsBalanceProvider.notifier).addFunds(1000);
                },
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
