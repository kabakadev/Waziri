// lib/features/gamification/domain/streak_repository.dart

// import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';

/// Repository responsible for calculating user streaks based on impulse-free days
class StreakRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Returns the current streak of consecutive days without an impulse transaction
  /// 
  /// Examples:
  /// - No transactions ever → returns 0
  /// - Impulse transaction today → returns 0
  /// - Last impulse was yesterday → returns 1
  /// - Last impulse was 5 days ago → returns 5
  /// - Only planned transactions ever → returns days since first transaction
  Future<int> getCurrentStreak() async {
    try {
      // Check if user has any transactions at all
      final hasAnyTransaction = await _hasAnyTransaction();
      if (!hasAnyTransaction) return 0;

      // Get all impulse transaction dates
      final impulseDates = await _getImpulseDates();
      
      // If no impulse transactions ever, streak is days since first transaction
      if (impulseDates.isEmpty) {
        return await _daysSinceFirstTransaction();
      }
      
      // Get today's date (without time component for accurate comparison)
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      // Most recent impulse date
      final mostRecentImpulse = impulseDates.first;
      final daysSinceLastImpulse = _daysBetween(mostRecentImpulse, todayDate);
      
      // If last impulse was today, streak is 0
      if (daysSinceLastImpulse == 0) return 0;
      
      return daysSinceLastImpulse;
    } catch (e) {
      // If database error occurs, return 0 as safe fallback
      return 0;
    }
  }

  /// Returns the best (longest) streak the user has ever achieved
  /// Useful for future enhancement to show personal best
  Future<int> getBestStreak() async {
    try {
      final impulseDates = await _getImpulseDates();
      if (impulseDates.isEmpty) {
        final daysSinceFirst = await _daysSinceFirstTransaction();
        return daysSinceFirst;
      }
      
      int bestStreak = 0;
      int currentStreak = 0;
      
      // Calculate gaps between impulse dates to find longest streak
      for (int i = 0; i < impulseDates.length - 1; i++) {
        final daysBetween = _daysBetween(impulseDates[i + 1], impulseDates[i]);
        if (daysBetween > 1) {
          // Streak broken
          currentStreak = 0;
        } else {
          currentStreak++;
          if (currentStreak > bestStreak) {
            bestStreak = currentStreak;
          }
        }
      }
      
      // Check streak from last impulse to today
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final daysSinceLast = _daysBetween(impulseDates.first, todayDate);
      if (daysSinceLast > bestStreak) {
        bestStreak = daysSinceLast;
      }
      
      return bestStreak;
    } catch (e) {
      return 0;
    }
  }

  /// Gets all unique dates where an impulse transaction occurred
  /// Returns dates in descending order (most recent first)
  Future<List<DateTime>> _getImpulseDates() async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT DISTINCT date(date) as impulse_day 
      FROM transactions 
      WHERE type = 'impulse'
      ORDER BY impulse_day DESC
    ''');
    
    return result.map((row) {
      final dateStr = row['impulse_day'] as String;
      final date = DateTime.parse(dateStr);
      // Normalize to date only (no time component)
      return DateTime(date.year, date.month, date.day);
    }).toList();
  }

  /// Checks if there are any transactions in the database
  Future<bool> _hasAnyTransaction() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
    final count = result.first['count'] as int;
    return count > 0;
  }

  /// Returns number of days since the very first transaction
  /// Used when user has never made an impulse transaction
  Future<int> _daysSinceFirstTransaction() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT MIN(date) as first_date FROM transactions');
    final firstDateStr = result.first['first_date'] as String?;
    
    if (firstDateStr == null) return 0;
    
    final firstDate = DateTime.parse(firstDateStr);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final firstDateOnly = DateTime(firstDate.year, firstDate.month, firstDate.day);
    
    return _daysBetween(firstDateOnly, todayDate);
  }

  /// Calculates days between two dates (ignores time components)
  int _daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }
}