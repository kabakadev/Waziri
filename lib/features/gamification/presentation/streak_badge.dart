// lib/features/gamification/presentation/streak_badge.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/streak_provider.dart';

/// A premium-looking badge that displays the user's current impulse-free streak
///
/// Features:
/// - 🔥 Flame icon that changes color based on streak length
/// - Displays streak count with "day" / "days" formatting
/// - Greyed out when streak is 0
/// - Loading and error states handled gracefully
class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(impulseFreeStreakProvider);

    return streakAsync.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
      data: (streak) => _buildBadgeContent(streak),
    );
  }

  /// Builds the main badge content once streak data is loaded
  Widget _buildBadgeContent(int streak) {
    final isActive = streak > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFlameIcon(streak),
          const SizedBox(width: 6),
          _buildStreakText(streak),
        ],
      ),
    );
  }

  /// Builds the flame icon with color based on streak length
  Widget _buildFlameIcon(int streak) {
    Color flameColor;

    if (streak == 0) {
      flameColor = AppColors.textSecondary; // Greyed out
    } else if (streak <= 2) {
      flameColor = AppColors.impulse; // Coral for new streaks
    } else {
      flameColor = AppColors.primary; // Gold for established streaks
    }

    return Icon(Icons.local_fire_department, color: flameColor, size: 18);
  }

  /// Builds the streak text with proper pluralization
  Widget _buildStreakText(int streak) {
    Color textColor;

    if (streak == 0) {
      textColor = AppColors.textSecondary;
    } else if (streak <= 2) {
      textColor = AppColors.textPrimary;
    } else {
      textColor = AppColors.primary;
    }

    String text;
    if (streak == 0) {
      text = 'Start streak';
    } else if (streak == 1) {
      text = '1 day clean';
    } else {
      text = '$streak days clean';
    }

    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: streak > 2 ? FontWeight.w600 : FontWeight.w500,
        fontFamily: 'DM Mono',
      ),
    );
  }

  /// Loading state - shows a subtle shimmer effect
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppColors.textSecondary,
            size: 18,
          ),
          SizedBox(width: 6),
          Text(
            '...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'DM Mono',
            ),
          ),
        ],
      ),
    );
  }

  /// Error state - shows a fallback badge
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppColors.textSecondary,
            size: 18,
          ),
          SizedBox(width: 6),
          Text(
            '0 days',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'DM Mono',
            ),
          ),
        ],
      ),
    );
  }
}
