import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../providers/savings_provider.dart';

class SavingsShieldDialog extends ConsumerStatefulWidget {
  const SavingsShieldDialog({super.key});

  @override
  ConsumerState<SavingsShieldDialog> createState() =>
      _SavingsShieldDialogState();
}

class _SavingsShieldDialogState extends ConsumerState<SavingsShieldDialog> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isEmergency = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _breakShield() {
    final amountText = _amountController.text;
    final reasonText = _reasonController.text;

    // The Friction: We literally block the action if they don't justify it
    if (amountText.isEmpty || reasonText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must provide an amount and a reason to break the shield.',
          ),
          backgroundColor: AppColors.impulse,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final currentSavings = ref.read(savingsBalanceProvider);
    if (amount > currentSavings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You cannot withdraw more than your current savings balance.',
          ),
          backgroundColor: AppColors.impulse,
        ),
      );
      return;
    }

    // 1. Deduct from the Savings Pot
    ref.read(savingsBalanceProvider.notifier).drawDown(amount);

    // 2. Log it as a Transaction so it haunts their Regret Log
    final drawdownTx = AppTransaction(
      amount: amount,
      category: 'Savings Drawdown',
      type: SpendType
          .impulse, // Drawing from savings is treated as an impulse by default
      note: reasonText,
      date: DateTime.now(),
      isSavingsDrawdown: true,
    );
    ref.read(transactionListProvider.notifier).addTransaction(drawdownTx);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // 1. ADD THE SCROLL VIEW HERE to prevent keyboard overflow
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_rounded,
                color: AppColors.impulse,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Break the Shield?',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppColors.impulse),
              ),
              const SizedBox(height: 8),
              Text(
                'Withdrawing from savings should hurt. Justify it below.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: AppColors.impulse,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  // 2. SWAP THE ICON FOR 'KES ' TEXT
                  prefixText: 'KES ',
                  prefixStyle: TextStyle(
                    color: AppColors.impulse,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  hintText: 'Why are you doing this?',
                  prefixIcon: Icon(
                    Icons.edit_note,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text(
                  'This is a genuine emergency',
                  style: TextStyle(fontSize: 14),
                ),
                value: _isEmergency,
                activeColor: AppColors.impulse,
                checkColor: AppColors.background,
                side: const BorderSide(color: AppColors.textSecondary),
                onChanged: (val) => setState(() => _isEmergency = val ?? false),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _breakShield,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.impulse,
                        foregroundColor: AppColors.background,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
