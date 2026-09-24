import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/core/widgets/confirm_dialog.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/screens/appointment_form_args.dart';
import 'package:my_clinic/features/appointments/presentation/widgets/appointment_tile.dart';

/// Shared handler for an appointment tile's popup menu, used by both the
/// Appointments tab and a patient's Visits tab.
Future<void> handleAppointmentAction(
  BuildContext context,
  AppointmentsCubit cubit,
  Appointment appointment,
  AppointmentMenuAction action,
) async {
  switch (action) {
    case AppointmentMenuAction.complete:
      await cubit.markCompleted(appointment);
    case AppointmentMenuAction.cancel:
      await cubit.cancel(appointment);
    case AppointmentMenuAction.reschedule:
      await cubit.reschedule(appointment);
    case AppointmentMenuAction.edit:
      await context.pushNamed(
        Routes.appointmentForm,
        arguments: AppointmentFormArgs(appointment: appointment),
      );
    case AppointmentMenuAction.delete:
      final confirmed = await showConfirmDialog(
        context,
        title: 'appointments.delete_confirm.title'.tr(),
        message: 'appointments.delete_confirm.message'.tr(),
      );
      if (confirmed) await cubit.delete(appointment);
  }
}
