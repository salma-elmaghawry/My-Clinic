import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/theme/app_colors.dart';
import 'package:my_clinic/features/home/presentation/widgets/stat_card.dart';
import 'package:my_clinic/features/stats/presentation/cubit/stats_cubit.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('home.quick_nav.notes_stats'.tr())),
      body: SafeArea(
        child: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            if (state.isLoading || state.isInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            final tiles = [
              (
                Icons.people_alt_outlined,
                state.totalPatients,
                'stats.total_patients',
                theme.colorScheme.primary,
              ),
              (
                Icons.person_add_alt_1_outlined,
                state.newPatientsThisMonth,
                'stats.new_patients_month',
                theme.colorScheme.secondary,
              ),
              (
                Icons.receipt_long_outlined,
                state.prescriptionsThisMonth,
                'stats.prescriptions_month',
                theme.colorScheme.primary,
              ),
              (
                Icons.check_circle_outline,
                state.visitsThisMonth,
                'stats.visits_month',
                theme.colorScheme.secondary,
              ),
              (
                Icons.event_outlined,
                state.upcomingAppointments,
                'stats.upcoming_appointments',
                theme.colorScheme.primary,
              ),
            ];
            return RefreshIndicator(
              onRefresh: context.read<StatsCubit>().load,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Rows of two that grow with their content, so long labels
                  // (and Arabic text) wrap instead of overflowing a fixed grid.
                  for (var i = 0; i < tiles.length; i += 2)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var j = i; j < i + 2; j++) ...[
                              if (j > i) horizontalSpace(12),
                              Expanded(
                                child: j < tiles.length
                                    ? StatCard(
                                        icon: tiles[j].$1,
                                        value: tiles[j].$2,
                                        label: tiles[j].$3.tr(),
                                        color: tiles[j].$4,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  verticalSpace(4),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.wc_outlined),
                      title: Text('stats.gender_split'.tr()),
                      subtitle: Text(
                        '${'patients.gender.male'.tr()}: ${state.malePatients}   ·   '
                        '${'patients.gender.female'.tr()}: ${state.femalePatients}',
                      ),
                    ),
                  ),
                  verticalSpace(24),
                  Text(
                    'stats.top_drugs'.tr(),
                    style: theme.textTheme.displaySmall,
                  ),
                  verticalSpace(4),
                  Text(
                    'stats.top_drugs_subtitle'.tr(),
                    style: theme.textTheme.bodySmall,
                  ),
                  verticalSpace(12),
                  if (state.topDrugs.isEmpty)
                    Text(
                      'stats.no_prescriptions'.tr(),
                      style: theme.textTheme.bodySmall,
                    )
                  else
                    _TopDrugsBars(drugs: state.topDrugs),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Single-series horizontal bars: one hue, thin rounded bars, the count as
/// a direct label in text color. One series needs no legend.
class _TopDrugsBars extends StatelessWidget {
  final List<DrugUsage> drugs;

  const _TopDrugsBars({required this.drugs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = drugs.first.count;
    return Column(
      children: drugs.map((d) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Semantics(
            label: '${d.name}: ${d.count}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.name,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${d.count}', style: theme.textTheme.labelLarge),
                  ],
                ),
                verticalSpace(4),
                LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      height: 8.h,
                      width: constraints.maxWidth * d.count / max,
                      decoration: BoxDecoration(
                        // Brand blue: passes contrast on both the light and
                        // dark surfaces, unlike the navy primary.
                        color: AppColors.third,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
