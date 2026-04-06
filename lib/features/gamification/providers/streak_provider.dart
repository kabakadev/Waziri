// lib/features/gamification/providers/streak_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../utils/streak_calculator.dart';

part 'streak_provider.g.dart';

/// Provider that returns the current impulse-free streak count.
///
/// Watches transactionListProvider and recalculates whenever transactions change.
/// Returns 0 while loading or if an error occurs.
@riverpod
Future<int> impulseFreeStreak(ImpulseFreeStreakRef ref) async {
  // Watch the transaction list provider
  final transactions = await ref.watch(transactionListProvider.future);

  // Use the pure utility function from Card 2
  return calculateStreak(transactions);
}

/// Provider that returns the best streak ever achieved.
/// Useful for showing "Personal Best" in the UI.
@riverpod
Future<int> bestStreak(BestStreakRef ref) async {
  final transactions = await ref.watch(transactionListProvider.future);

  // Calculate best streak by checking all possible end dates
  int best = 0;

  // For each transaction date, calculate streak ending on that day
  for (int i = 0; i <= transactions.length; i++) {
    // Get subset of transactions up to this point
    final subset = transactions.take(i).toList();
    final refDate = subset.isNotEmpty ? subset.last.date : DateTime.now();
    final currentStreak = calculateStreak(subset, referenceDate: refDate);
    if (currentStreak > best) {
      best = currentStreak;
    }
  }

  return best;
}
