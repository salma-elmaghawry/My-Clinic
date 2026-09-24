import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/screens/appointment_form_args.dart';
import 'package:my_clinic/features/appointments/presentation/widgets/appointment_actions.dart';
import 'package:my_clinic/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';

/// A patient's appointments: the next upcoming one highlighted at the top,
/// then the rest newest first, plus a button to schedule a new visit.
class PatientVisitsTab extends StatelessWidget {
  final Patient patient;
  final List<Appointment> appointments;
  final Appointment? nextAppointment;

  const PatientVisitsTab({
    super.key,
    required this.patient,
    required this.appointments,
    required this.nextAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AppointmentsCubit>();
    final others = appointments.reversed
        .where((a) => a.id != nextAppointment?.id)
        .toList();

    Widget tile(Appointment a) => AppointmentTile(
      appointment: a,
      showDate: true,
      onAction: (action) => handleAppointmentAction(context, cubit, a, action),
    );

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        OutlinedButton.icon(
          onPressed: () => context.pushNamed(
            Routes.appointmentForm,
            arguments: AppointmentFormArgs(
              patientId: patient.id,
              patientName: patient.name,
            ),
          ),
          icon: const Icon(Icons.event_available_outlined),
          label: Text('patients.detail.visits.schedule'.tr()),
        ),
        verticalSpace(16),
        Text(
          'patients.detail.visits.next'.tr(),
          style: theme.textTheme.labelLarge,
        ),
        verticalSpace(8),
        if (nextAppointment != null)
          tile(nextAppointment!)
        else
          Text(
            'patients.detail.visits.none_upcoming'.tr(),
            style: theme.textTheme.bodySmall,
          ),
        if (others.isNotEmpty) ...[
          verticalSpace(16),
          Text(
            'patients.detail.visits.all'.tr(),
            style: theme.textTheme.labelLarge,
          ),
          verticalSpace(8),
          ...others.map(tile),
        ],
      ],
    );
  }
}
