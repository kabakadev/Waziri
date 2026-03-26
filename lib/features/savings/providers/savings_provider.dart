import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../main.dart'; // To access your synchronous sharedPreferencesProvider

part 'savings_provider.g.dart';

@riverpod
class SavingsBalance extends _$SavingsBalance {
  static const _key = 'waziri_savings_balance';

  @override
  double build() {
    // Synchronous read! No loading screens.
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getDouble(_key) ?? 0.0;
  }

  void addFunds(double amount) {
    final prefs = ref.read(sharedPreferencesProvider);
    final newBalance = state + amount;
    prefs.setDouble(_key, newBalance);
    state = newBalance; // Triggers UI rebuild
  }

  void drawDown(double amount) {
    final prefs = ref.read(sharedPreferencesProvider);
    // Prevent negative savings
    final newBalance = state - amount >= 0 ? state - amount : 0.0;
    prefs.setDouble(_key, newBalance);
    state = newBalance;
  }
}
