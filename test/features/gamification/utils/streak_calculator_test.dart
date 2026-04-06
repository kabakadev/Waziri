// test/features/gamification/utils/streak_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:waziri/features/transactions/models/transaction.dart';
import 'package:waziri/features/gamification/utils/streak_calculator.dart';

void main() {
  group('calculateStreak', () {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final twoDaysAgo = DateTime(today.year, today.month, today.day - 2);
    final threeDaysAgo = DateTime(today.year, today.month, today.day - 3);
    final fourDaysAgo = DateTime(today.year, today.month, today.day - 4);
    final fiveDaysAgo = DateTime(today.year, today.month, today.day - 5);

    test('returns 0 when transaction list is empty', () {
      final transactions = <AppTransaction>[];
      
      final result = calculateStreak(transactions);
      
      expect(result, 0);
    });

    test('returns 0 when impulse transaction occurred today', () {
      final transactions = [
        AppTransaction(
          amount: 10.0,
          category: 'Impulse/Wants',
          type: SpendType.impulse,
          date: today,
        ),
      ];
      
      final result = calculateStreak(transactions);
      
      expect(result, 0);
    });

    test('returns 1 when last impulse was yesterday (today is clean)', () {
      final transactions = [
        AppTransaction(
          amount: 10.0,
          category: 'Impulse/Wants',
          type: SpendType.impulse,
          date: yesterday,
        ),
        AppTransaction(
          amount: 5.0,
          category: 'Food & Groceries',
          type: SpendType.planned,
          date: today,
        ),
      ];
      
      final result = calculateStreak(transactions);
      
      expect(result, 1);
    });

    test('returns 5 when last impulse was 5 days ago', () {
      final transactions = [
        AppTransaction(
          amount: 10.0,
          category: 'Impulse/Wants',
          type: SpendType.impulse,
          date: fiveDaysAgo,
        ),
        AppTransaction(
          amount: 5.0,
          category: 'Food & Groceries',
          type: SpendType.planned,
          date: fourDaysAgo,
        ),
        AppTransaction(
          amount: 20.0,
          category: 'Transport',
          type: SpendType.planned,
          date: threeDaysAgo,
        ),
        AppTransaction(
          amount: 15.0,
          category: 'Housing',
          type: SpendType.planned,
          date: yesterday,
        ),
        AppTransaction(
          amount: 8.0,
          category: 'Food & Groceries',
          type: SpendType.planned,
          date: today,
        ),
      ];
      
      final result = calculateStreak(transactions);
      
      expect(result, 5);
    });

    test('returns days since first transaction when no impulse transactions exist', () {
      final transactions = [
        AppTransaction(
          amount: 10.0,
          category: 'Food & Groceries',
          type: SpendType.planned,
          date: fiveDaysAgo,
        ),
        AppTransaction(
          amount: 15.0,
          category: 'Transport',
          type: SpendType.planned,
          date: threeDaysAgo,
        ),
        AppTransaction(
          amount: 8.0,
          category: 'Food & Groceries',
          type: SpendType.planned,
          date: today,
        ),
      ];
      
      final result = calculateStreak(transactions);
      
      // First transaction was 5 days ago, so streak should be 5
      expect(result, 5);
    });

    test('handles multiple impulses on same day (only counts once)', () {
      final transactions = [
        AppTransaction(
          amount: 10.0,
          category: 'Impulse/Wants',
          type: SpendType.impulse,
          date: twoDaysAgo,
        ),
        AppTransaction(
          amount: 15.0,
          category: 'Impulse/Wants',
          type: SpendType.impulse,
          date: twoDaysAgo, // Same day, different transaction
        ),
        AppTransaction(
          amount: 5.0,
          category: 'Food & Groceries',
          type: SpendType.planned,
          date: yesterday,
        ),
        AppTransaction(
          amount: 8.0,
          category: 'Food & Groceries',
          type: SpendType.planned,
          date: today,
        ),
      ];
      
      final result = calculateStreak(transactions);
      
      // Last impulse was 2 days ago, so streak should be 2 (yesterday and today)
      expect(result, 2);
    });
  });
}