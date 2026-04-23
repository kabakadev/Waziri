class MpesaReceipt {
  final String transactionId;
  final double amount;
  final String recipient;
  final DateTime date;

  MpesaReceipt({
    required this.transactionId,
    required this.amount,
    required this.recipient,
    required this.date,
  });

  @override
  String toString() => 'ID: $transactionId | Ksh $amount | To: $recipient';
}
