import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/home/domain/patient_milestone.dart';

/// Lightweight gamification: turns "how many patients has this doctor
/// treated" into a badge + progress bar instead of a bare number, as a
/// small motivational nudge to keep records up to date.
class PatientMilestoneCard extends StatelessWidget {
  final int totalPatientsCount;

  const PatientMilestoneCard({super.key, required this.totalPatientsCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = PatientMilestoneProgress.fromCount(totalPatientsCount);
    final tierInfo = _tierInfo(progress.tier);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: tierInfo.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(tierInfo.emoji, style: TextStyle(fontSize: 22.sp)),
          ),
          horizontalSpace(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'home.milestone.tier'.tr(
                          namedArgs: {'tier': tierInfo.labelKey.tr()},
                        ),
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    Text(
                      'home.milestone.count'.tr(
                        namedArgs: {'count': '$totalPatientsCount'},
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: tierInfo.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                verticalSpace(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: progress.progressToNextTier,
                    minHeight: 8.h,
                    backgroundColor: tierInfo.color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(tierInfo.color),
                  ),
                ),
                verticalSpace(6),
                Text(
                  progress.nextTierThreshold == null
                      ? 'home.milestone.top_tier'.tr()
                      : 'home.milestone.remaining'.tr(
                          namedArgs: {
                            'count': '${progress.remainingToNextTier}',
                          },
                        ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _TierInfo _tierInfo(PatientMilestoneTier tier) {
    switch (tier) {
      case PatientMilestoneTier.starting:
        return const _TierInfo(
          'home.milestone.tiers.starting',
          '🌱',
          Color(0xFF2E7D32),
        );
      case PatientMilestoneTier.bronze:
        return const _TierInfo(
          'home.milestone.tiers.bronze',
          '🥉',
          Color(0xFFB08D57),
        );
      case PatientMilestoneTier.silver:
        return const _TierInfo(
          'home.milestone.tiers.silver',
          '🥈',
          Color(0xFF8E9AAF),
        );
      case PatientMilestoneTier.gold:
        return const _TierInfo(
          'home.milestone.tiers.gold',
          '🥇',
          Color(0xFFD4AF37),
        );
      case PatientMilestoneTier.platinum:
        return const _TierInfo(
          'home.milestone.tiers.platinum',
          '💎',
          Color(0xFF4FA8D8),
        );
    }
  }
}

class _TierInfo {
  final String labelKey;
  final String emoji;
  final Color color;

  const _TierInfo(this.labelKey, this.emoji, this.color);
}
