enum SpendType { planned, impulse }

class AppTransaction {
  final int? id;
  final double amount;
  final String category;
  final SpendType type;
  final bool isRegretted;
  final String? note;
  final DateTime date;
  final bool isDebt;
  final String? debtReason;
  final bool isSavingsDrawdown;

  AppTransaction({
    this.id,
    required this.amount,
    required this.category,
    required this.type,
    this.isRegretted = false,
    this.note,
    required this.date,
    this.isDebt = false,
    this.debtReason,
    this.isSavingsDrawdown = false,
  });

  // Convert a Transaction into a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'type': type.name, // Stores 'planned' or 'impulse' as a String
      'is_regretted': isRegretted ? 1 : 0, // SQLite doesn't have booleans
      'note': note,
      'date': date.toIso8601String(),
      'is_debt': isDebt ? 1 : 0,
      'debt_reason': debtReason,
      'is_savings_drawdown': isSavingsDrawdown ? 1 : 0,
    };
  }

  // Extract a Transaction from a SQLite Map
  factory AppTransaction.fromMap(Map<String, dynamic> map) {
    return AppTransaction(
      id: map['id'] as int,
      amount: map['amount'] as double,
      category: map['category'] as String,
      type: SpendType.values.byName(map['type'] as String),
      isRegretted: (map['is_regretted'] as int) == 1,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      isDebt: (map['is_debt'] as int) == 1,
      debtReason: map['debt_reason'] as String?,
      isSavingsDrawdown: (map['is_savings_drawdown'] as int) == 1,
    );
  }

  // copyWith for immutable state updates (like toggling 'Regret')
  AppTransaction copyWith({
    int? id,
    double? amount,
    String? category,
    SpendType? type,
    bool? isRegretted,
    String? note,
    DateTime? date,
    bool? isDebt,
    String? debtReason,
    bool? isSavingsDrawdown,
  }) {
    return AppTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      isRegretted: isRegretted ?? this.isRegretted,
      note: note ?? this.note,
      date: date ?? this.date,
      isDebt: isDebt ?? this.isDebt,
      debtReason: debtReason ?? this.debtReason,
      isSavingsDrawdown: isSavingsDrawdown ?? this.isSavingsDrawdown,
    );
  }
}
