// lib/features/gamification/presentation/streak_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/streak_repository.dart';

part 'streak_provider.g.dart';

/// Provider that exposes the current impulse-free streak
/// Automatically recomputes when transactions change
@riverpod
Future<int> impulseFreeStreak(ImpulseFreeStreakRef ref) async {
  final repository = StreakRepository();
  return await repository.getCurrentStreak();
}

/// Provider that exposes the best streak ever achieved
/// Useful for showing "Personal Best" in the UI
@riverpod
Future<int> bestStreak(BestStreakRef ref) async {
  final repository = StreakRepository();
  return await repository.getBestStreak();
}