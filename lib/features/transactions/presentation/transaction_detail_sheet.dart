import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure you have the intl package for date formatting
import '../models/transaction.dart'; // Adjust this import based on your exact path

class TransactionDetailSheet extends StatelessWidget {
  final AppTransaction transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Determine if it was an impulse buy to color-code the UI
    final isImpulse = transaction.type == SpendType.impulse;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Wrap content, don't take full screen
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle for sliding down
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // 1. The Badge (Visual cue for the behavior)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isImpulse
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isImpulse ? '🚨 IMPULSE SPEND' : '✅ PLANNED',
                  style: TextStyle(
                    color: isImpulse
                        ? Colors.red.shade900
                        : Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Large readable font
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. The Massive Amount
            Center(
              child: Text(
                'Ksh ${NumberFormat('#,##0').format(transaction.amount)}',
                style: const TextStyle(
                  fontSize: 44, // MASSIVE font for easy reading
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 3. Category
            Center(
              child: Text(
                transaction.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Divider(height: 48, thickness: 1.5),

            // 4. The Breakdown (When it happened)
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              // Example: Monday, April 12, 2026
              value: DateFormat('EEEE, MMMM d, y').format(transaction.date),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Time',
              // Example: 10:30 AM
              value: DateFormat('h:mm a').format(transaction.date),
            ),
            const SizedBox(height: 24),

            // 5. The Narrative / Note (Using singular 'note')
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              const Text(
                'Note / Reason:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  transaction.note!, // Changed to singular
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 6. The Regret Flag (Using your isRegretted boolean!)
            if (transaction.isRegretted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Marked as a regretted purchase.',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper widget to keep the tree clean
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ), // Big and bold
          ],
        ),
      ],
    );
  }
}
