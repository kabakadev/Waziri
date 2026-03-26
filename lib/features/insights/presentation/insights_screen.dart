import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Spend Insights'), elevation: 0),
      body: transactionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) =>
            const Center(child: Text('Failed to load chart data')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'Not enough data to generate insights.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 7 Days',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Coral indicates unplanned impulse spending.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),

                // The Chart Container
                Expanded(child: _buildChart(transactions)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(List<AppTransaction> transactions) {
    // 1. Prepare the data for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(
      7,
      (index) => now.subtract(Duration(days: 6 - index)),
    );

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < last7Days.length; i++) {
      final targetDate = last7Days[i];

      // Filter transactions for this specific day
      final dailyTxs = transactions.where(
        (tx) =>
            tx.date.year == targetDate.year &&
            tx.date.month == targetDate.month &&
            tx.date.day == targetDate.day,
      );

      // Sum the planned and impulse amounts
      double plannedSum = 0;
      double impulseSum = 0;
      for (var tx in dailyTxs) {
        if (tx.type == SpendType.planned) {
          plannedSum += tx.amount;
        } else {
          impulseSum += tx.amount;
        }
      }

      final dailyTotal = plannedSum + impulseSum;
      if (dailyTotal > maxY) maxY = dailyTotal;

      // 2. Create the Stacked Bar
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyTotal,
              width: 20,
              borderRadius: BorderRadius.circular(4),
              rodStackItems: [
                // Bottom part: Planned (Amber)
                BarChartRodStackItem(0, plannedSum, AppColors.primary),
                // Top part: Impulse (Coral) stacked on top
                BarChartRodStackItem(plannedSum, dailyTotal, AppColors.impulse),
              ],
            ),
          ],
        ),
      );
    }

    // Add a little padding to the top of the chart
    maxY = maxY + (maxY * 0.2);
    if (maxY == 0) maxY = 100; // Fallback if no spend

    // 3. Render the fl_chart
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: false,
        ), // Keep it simple, no touch tooltips for V1
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                // Map the 0-6 index to the actual day abbreviation
                final date = last7Days[value.toInt()];
                final dayStr = DateFormat(
                  'E',
                ).format(date); // e.g., 'Mon', 'Tue'
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dayStr,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false), // Hide the ugly grid
        borderData: FlBorderData(show: false), // Hide the bounding box
        barGroups: barGroups,
      ),
    );
  }
}
