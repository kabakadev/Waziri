// lib/features/gamification/utils/streak_calculator.dart

import '../../../features/transactions/models/transaction.dart';

/// Calculates the current streak of consecutive days without an impulse transaction.
///
/// This is a pure function - no database calls, no side effects.
///
/// Algorithm:
/// 1. Start from today and go backward day by day
/// 2. For each day, check if an impulse transaction occurred on that day
/// 3. Stop counting when an impulse day is found
/// 4. Return the count of clean days
///
/// Examples:
/// - No transactions at all → returns 0
/// - Impulse transaction today → returns 0
/// - Last impulse was yesterday → returns 1 (today is clean)
/// - Last impulse was 5 days ago → returns 5
/// - Only planned transactions ever → returns days since first transaction
int calculateStreak(
  List<AppTransaction> transactions, {
  DateTime? referenceDate,
}) {
  // Edge case: No transactions at all
  if (transactions.isEmpty) return 0;

  // Get today's date without time component for accurate comparison
  final target = referenceDate ?? DateTime.now();
  final targetDate = DateTime(target.year, target.month, target.day);

  // Get all impulse transaction dates (unique days only)
  final impulseDays = transactions
      .where((t) => t.type == SpendType.impulse)
      .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
      .toSet(); // Set ensures unique days

  // If no impulse transactions ever, streak is days since first transaction
  if (impulseDays.isEmpty) {
    // Find the oldest transaction date
    final oldestTransaction = transactions
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .reduce((a, b) => a.isBefore(b) ? a : b);

    // Count days from oldest transaction to today
    return _daysBetween(oldestTransaction, targetDate);
  }

  // Find the most recent impulse day
  final mostRecentImpulse = impulseDays.reduce((a, b) => a.isAfter(b) ? a : b);

  // Calculate days since last impulse
  final daysSinceLastImpulse = _daysBetween(mostRecentImpulse, targetDate);

  // If last impulse was today, streak is 0
  if (daysSinceLastImpulse == 0) return 0;

  // Otherwise, return the number of clean days
  return daysSinceLastImpulse;
}

/// Calculates the number of days between two dates (ignores time components).
///
/// Example: _daysBetween(Jan 1, Jan 3) returns 2
int _daysBetween(DateTime from, DateTime to) {
  return to.difference(from).inDays;
}
