import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_helper.dart';
import '../models/transaction.dart';
import '../models/mpesa_receipt.dart';

// This is the generated file. It will show as an error until we run the build_runner
part 'transaction_provider.g.dart';

@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<AppTransaction>> build() async {
    return _fetchTransactions();
  }

  // Private method to read from SQLite
  Future<List<AppTransaction>> _fetchTransactions() async {
    final db = await DatabaseHelper.instance.database;
    // Fetch newest transactions first
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => AppTransaction.fromMap(map)).toList();
  }

  // Public method for the "Add Transaction" FAB
  Future<void> addTransaction(AppTransaction transaction) async {
    // 1. Set state to loading while writing to DB
    state = const AsyncValue.loading();

    // 2. Insert into SQLite
    final db = await DatabaseHelper.instance.database;
    await db.insert('transactions', transaction.toMap());

    // 3. Refresh the Riverpod state from the database
    state = await AsyncValue.guard(() => _fetchTransactions());
  }

  // Public method for the "Regret Log" toggle
  Future<void> toggleRegret(AppTransaction transaction) async {
    if (transaction.id == null) return;

    final db = await DatabaseHelper.instance.database;
    final newRegretState = !transaction.isRegretted;

    // Update SQLite
    await db.update(
      'transactions',
      {'is_regretted': newRegretState ? 1 : 0},
      where: 'id = ?',
      whereArgs: [transaction.id],
    );

    // Refresh state
    state = await AsyncValue.guard(() => _fetchTransactions());
  }

  Future<int> importMpesaTransactions(List<MpesaReceipt> receipts) async {
    int newlyAddedCount = 0;

    // 1. Get current transactions to check for duplicates
    final currentTransactions = state.value ?? [];

    for (final receipt in receipts) {
      // 2. Deduplication Check: Does any existing transaction have this M-Pesa ID in its note?
      final isDuplicate = currentTransactions.any(
        (tx) => tx.note != null && tx.note!.contains(receipt.transactionId),
      );

      if (!isDuplicate) {
        // 3. Convert MpesaReceipt into an AppTransaction
        final newTx = AppTransaction(
          amount: receipt.amount,
          category:
              'M-PESA', // Default category for now. Natasha's ML can categorize this later!
          type:
              SpendType.planned, // Default to planned, user can change it later
          date: receipt.date,
          note:
              '[M-PESA ID: ${receipt.transactionId}] Sent to: ${receipt.recipient}',
        );

        // 4. Save to SQLite (Call your existing add method)
        // Assuming you have a method like addTransaction(AppTransaction tx) in your provider
        await addTransaction(newTx);
        newlyAddedCount++;
      }
    }

    return newlyAddedCount;
  }
}
