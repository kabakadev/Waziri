import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import '../../../core/utils/permission_manager.dart';
import '../../../core/utils/mpesa_parser.dart';
import '../models/mpesa_receipt.dart';

class SmsSyncService {
  final SmsQuery _query = SmsQuery();

  /// Scans the user's inbox for M-Pesa messages and parses them.
  Future<List<MpesaReceipt>> syncMpesaHistory() async {
    // 1. Ensure we have OS permission (Uses your plumbing!)
    final hasPermission = await PermissionManager.requestSmsPermission();
    if (!hasPermission) {
      print('Waziri: SMS Permission denied by user.');
      return [];
    }

    print('Waziri: Permission granted. Scanning inbox...');

    try {
      // 2. Query the Android SMS Inbox
      // We limit to the last 100 messages to keep it fast, and only look at the Inbox
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 100,
      );

      final List<MpesaReceipt> extractedReceipts = [];

      // 3. Filter and Parse
      for (var msg in messages) {
        // M-Pesa messages usually come from "MPESA"
        if (msg.sender == 'MPESA' && msg.body != null) {
          // Feed the raw text into the Brain you just built
          final receipt = MpesaParser.parse(msg.body!);

          if (receipt != null) {
            extractedReceipts.add(receipt);
          }
        }
      }

      print(
        'Waziri: Successfully extracted ${extractedReceipts.length} M-Pesa receipts!',
      );
      return extractedReceipts;
    } catch (e) {
      print('Waziri: Error reading SMS inbox: $e');
      return [];
    }
  }
}
