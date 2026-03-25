import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // These match the default categories we seeded in SQLite
  final List<String> _categories = [
    'Food & Groceries',
    'Transport',
    'Housing',
    'Impulse/Wants',
    'Debt Repayment',
  ];
  String? _selectedCategory;
  bool _isImpulse = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final amountText = _amountController.text;
    if (amountText.isEmpty || _selectedCategory == null) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final newTx = AppTransaction(
      amount: amount,
      category: _selectedCategory!,
      type: _isImpulse ? SpendType.impulse : SpendType.planned,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      date: DateTime.now(),
      // We default regret to false at the moment of entry
      isRegretted: false,
    );

    // Write to SQLite via Riverpod
    ref.read(transactionListProvider.notifier).addTransaction(newTx);

    // Close the sheet
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // The UI dramatically shifts based on the Impulse toggle
    final activeColor = _isImpulse ? AppColors.impulse : AppColors.primary;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log Spend',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(color: activeColor),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: 'KES ',
                prefixStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              dropdownColor: AppColors.surface,
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 16),

            // Optional Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Note (Optional)',
                prefixIcon: Icon(Icons.notes, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // The Behavioral "Impulse" Toggle
            GestureDetector(
              onTap: () => setState(() => _isImpulse = !_isImpulse),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isImpulse
                      ? AppColors.impulse.withOpacity(0.2)
                      : AppColors.surface,
                  border: Border.all(
                    color: _isImpulse ? AppColors.impulse : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isImpulse
                          ? Icons.local_fire_department
                          : Icons.check_circle_outline,
                      color: _isImpulse
                          ? AppColors.impulse
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isImpulse
                          ? 'This was an Impulse Spend'
                          : 'This was Planned',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _isImpulse
                            ? AppColors.impulse
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Save Transaction',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.background),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
