import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';

class DebtActionDialog extends ConsumerStatefulWidget {
  final bool isBorrowing; // True for Fuliza/Okoa, False for Repayment

  const DebtActionDialog({super.key, required this.isBorrowing});

  @override
  ConsumerState<DebtActionDialog> createState() => _DebtActionDialogState();
}

class _DebtActionDialogState extends ConsumerState<DebtActionDialog> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    if (widget.isBorrowing && _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must provide a reason for taking on debt.'),
          backgroundColor: AppColors.impulse,
        ),
      );
      return;
    }

    final newTx = AppTransaction(
      amount: amount,
      category: widget.isBorrowing
          ? 'Borrowed (Fuliza/Okoa)'
          : 'Debt Repayment',
      // Borrowing is automatically flagged as an Impulse buy to hit their stats!
      type: widget.isBorrowing ? SpendType.impulse : SpendType.planned,
      note: _reasonController.text.isNotEmpty ? _reasonController.text : null,
      date: DateTime.now(),
      isDebt: widget.isBorrowing,
      debtReason: widget.isBorrowing ? _reasonController.text : null,
    );

    ref.read(transactionListProvider.notifier).addTransaction(newTx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isBorrowing
        ? AppColors.impulse
        : AppColors.planned;
    final title = widget.isBorrowing ? 'Take Debt' : 'Repay Debt';
    final icon = widget.isBorrowing
        ? Icons.account_balance_wallet_outlined
        : Icons.task_alt;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: themeColor, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: themeColor),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isBorrowing
                  ? 'Taking debt is borrowing from your future self.'
                  : 'Clearing the slate. Good job.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: 'KES',
                prefixStyle: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            const SizedBox(height: 16),

            if (widget.isBorrowing) ...[
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  hintText: 'Why do you need this?',
                  prefixIcon: Icon(
                    Icons.edit_note,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: AppColors.background,
                    ),
                    child: Text(widget.isBorrowing ? 'Borrow' : 'Repay'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
