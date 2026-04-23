import '../../features/transactions/models/mpesa_receipt.dart';
import 'package:intl/intl.dart';

class MpesaParser {
  static MpesaReceipt? parse(String message) {
    final lowerMsg = message.toLowerCase();

    // 🔴 Kill switch (Fuliza summaries)
    if (lowerMsg.contains('fuliza m-pesa amount is') ||
        lowerMsg.contains('outstanding fuliza')) {
      print('Waziri: Ignored Fuliza summary message.');
      return null;
    }

    // 🔴 Basic validation
    if (!lowerMsg.contains('confirmed') || !message.contains('Ksh')) {
      return null;
    }

    try {
      // ✅ 1. Transaction ID
      final idMatch = RegExp(r'^[A-Z0-9]{10}').firstMatch(message);
      final transactionId = idMatch?.group(0) ?? 'UNKNOWN';

      // ✅ 2. Amount (handles "Ksh14.83" & "Ksh 14.83")
      final amountMatch = RegExp(
        r'Ksh\s*([\d,]+\.\d{2})',
        caseSensitive: false,
      ).firstMatch(message);

      final amountString = amountMatch?.group(1)?.replaceAll(',', '');
      final amount = amountString != null
          ? double.tryParse(amountString) ?? 0.0
          : 0.0;

      // ✅ 3. Date
      DateTime parsedDate = DateTime.now();

      final dateMatch = RegExp(
        r'on (\d{1,2}/\d{1,2}/\d{2} at \d{1,2}:\d{2} [AP]M)',
      ).firstMatch(message);

      if (dateMatch != null) {
        try {
          parsedDate = DateFormat(
            "d/M/yy 'at' h:mm a",
          ).parse(dateMatch.group(1)!);
        } catch (e) {
          print('Waziri Date Error: $e');
        }
      }

      // ✅ 4. Recipient extraction
      String recipient = 'Unknown';

      if (lowerMsg.contains('sent to')) {
        recipient =
            RegExp(r'sent to (.*?) on ').firstMatch(message)?.group(1) ??
            'Unknown';
      } else if (lowerMsg.contains('paid to')) {
        recipient =
            RegExp(r'paid to (.*?) on ').firstMatch(message)?.group(1) ??
            'Unknown';
      } else if (lowerMsg.contains('withdraw')) {
        recipient =
            RegExp(r'from (.*?) New').firstMatch(message)?.group(1) ??
            'M-Pesa Agent';
      } else if (lowerMsg.contains('received')) {
        recipient =
            RegExp(r'from (.*?) on ').firstMatch(message)?.group(1) ??
            'Unknown Sender';
      } else if (lowerMsg.contains('airtime')) {
        recipient = 'Safaricom Airtime';
      }

      // Clean trailing dots
      recipient = recipient.replaceAll(RegExp(r'[.]+$'), '').trim();

      // ✅ Final object
      return MpesaReceipt(
        transactionId: transactionId,
        amount: amount,
        recipient: recipient,
        date: parsedDate,
      );
    } catch (e) {
      print('Waziri Parser Error: $e');
      return null;
    }
  }
}
