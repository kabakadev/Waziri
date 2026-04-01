import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../transactions/providers/transaction_provider.dart';

part 'debt_provider.g.dart';

@riverpod
double outstandingDebt(OutstandingDebtRef ref) {
  // ✅ fixed
  final transactionsAsync = ref.watch(transactionListProvider);

  return transactionsAsync.maybeWhen(
    data: (transactions) {
      double borrowed = 0.0;
      double repaid = 0.0;
      for (var tx in transactions) {
        if (tx.isDebt) {
          borrowed += tx.amount;
        } else if (tx.category == 'Debt Repayment') {
          repaid += tx.amount;
        }
      }
      final total = borrowed - repaid;
      return total > 0 ? total : 0.0;
    },
    orElse: () => 0.0,
  );
}
