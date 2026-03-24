import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_helper.dart';
import '../models/transaction.dart';

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
}
