import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointments_state.dart';
import 'package:my_clinic/features/appointments/presentation/screens/appointment_form_args.dart';
import 'package:my_clinic/features/appointments/presentation/widgets/appointment_actions.dart';
import 'package:my_clinic/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:my_clinic/features/appointments/presentation/widgets/week_date_strip.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentsCubit>().load();
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final cubit = context.read<AppointmentsCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) cubit.selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentsCubit, AppointmentsState>(
      listenWhen: (prev, curr) => curr.isFailure && curr.message != null,
      listener: (context, state) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message!))),
      builder: (context, state) {
        final theme = Theme.of(context);
        final cubit = context.read<AppointmentsCubit>();
        final day = state.dayAppointments;
        return Scaffold(
          appBar: AppBar(
            title: Text('nav.appointments'.tr()),
            actions: [
              IconButton(
                tooltip: 'appointments.today'.tr(),
                icon: const Icon(Icons.today_outlined),
                onPressed: () => cubit.selectDate(DateTime.now()),
              ),
              IconButton(
                tooltip: 'appointments.pick_date'.tr(),
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () => _pickDate(context, state.selectedDate),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'appointments_fab',
            onPressed: () => context.pushNamed(
              Routes.appointmentForm,
              arguments: AppointmentFormArgs(initialDate: state.selectedDate),
            ),
            icon: const Icon(Icons.add),
            label: Text('appointments.add'.tr()),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  child: WeekDateStrip(
                    selectedDate: state.selectedDate,
                    busyDays: state.busyDays,
                    onSelect: cubit.selectDate,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    DateFormat.yMMMMEEEEd(
                      context.locale.toString(),
                    ).format(state.selectedDate),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                verticalSpace(8),
                Expanded(
                  child: day.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_available_outlined,
                                  size: 48.sp,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                                verticalSpace(12),
                                Text(
                                  'appointments.empty_day'.tr(),
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ).fadeInScale(),
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 88.h),
                          children: day
                              .map(
                                (appointment) => AppointmentTile(
                                  appointment: appointment,
                                  onTap: () => context.pushNamed(
                                    Routes.patientDetail,
                                    arguments: appointment.patientId,
                                  ),
                                  onAction: (action) => handleAppointmentAction(
                                    context,
                                    cubit,
                                    appointment,
                                    action,
                                  ),
                                ),
                              )
                              .toList()
                              .animateList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
