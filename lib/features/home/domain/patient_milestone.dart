/// Small, dependency-free gamification helper: turns a raw total-patients
/// count into a tier (badge + emoji), plus how far the doctor is from the
/// next one. Pure logic so it's trivial to unit test and has no opinion on
/// how it's rendered.
enum PatientMilestoneTier { starting, bronze, silver, gold, platinum }

class PatientMilestoneProgress {
  final PatientMilestoneTier tier;
  final int count;
  final int? nextTierThreshold;

  const PatientMilestoneProgress({
    required this.tier,
    required this.count,
    required this.nextTierThreshold,
  });

  /// 0.0-1.0 progress toward the next tier; 1.0 (full bar, no "X to go"
  /// caption) once the doctor is already at the top tier.
  double get progressToNextTier {
    if (nextTierThreshold == null) return 1.0;
    final previousThreshold = _thresholdBelow(tier);
    final span = nextTierThreshold! - previousThreshold;
    if (span <= 0) return 1.0;
    return ((count - previousThreshold) / span).clamp(0.0, 1.0);
  }

  int get remainingToNextTier =>
      nextTierThreshold == null ? 0 : (nextTierThreshold! - count).clamp(0, nextTierThreshold!);

  static int _thresholdBelow(PatientMilestoneTier tier) {
    switch (tier) {
      case PatientMilestoneTier.starting:
        return 0;
      case PatientMilestoneTier.bronze:
        return 10;
      case PatientMilestoneTier.silver:
        return 50;
      case PatientMilestoneTier.gold:
        return 100;
      case PatientMilestoneTier.platinum:
        return 250;
    }
  }

  static PatientMilestoneProgress fromCount(int count) {
    if (count < 10) {
      return PatientMilestoneProgress(
        tier: PatientMilestoneTier.starting,
        count: count,
        nextTierThreshold: 10,
      );
    }
    if (count < 50) {
      return PatientMilestoneProgress(
        tier: PatientMilestoneTier.bronze,
        count: count,
        nextTierThreshold: 50,
      );
    }
    if (count < 100) {
      return PatientMilestoneProgress(
        tier: PatientMilestoneTier.silver,
        count: count,
        nextTierThreshold: 100,
      );
    }
    if (count < 250) {
      return PatientMilestoneProgress(
        tier: PatientMilestoneTier.gold,
        count: count,
        nextTierThreshold: 250,
      );
    }
    return PatientMilestoneProgress(
      tier: PatientMilestoneTier.platinum,
      count: count,
      nextTierThreshold: null,
    );
  }
}
