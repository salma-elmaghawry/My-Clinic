import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/theme/app_colors.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';

enum AppointmentMenuAction { complete, cancel, reschedule, edit, delete }

class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final ValueChanged<AppointmentMenuAction>? onAction;
  final bool showDate;

  const AppointmentTile({
    super.key,
    required this.appointment,
    this.onTap,
    this.onAction,
    this.showDate = false,
  });

  static Color statusColor(AppointmentStatus status) => switch (status) {
    AppointmentStatus.scheduled => AppColors.info,
    AppointmentStatus.completed => AppColors.success,
    AppointmentStatus.cancelled => AppColors.grey500,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.toString();
    final time = DateFormat.jm(locale).format(appointment.dateTime);
    final date = DateFormat.yMMMEd(locale).format(appointment.dateTime);
    final color = statusColor(appointment.status);
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showDate ? '$date · $time' : time,
                      style: theme.textTheme.labelMedium,
                    ),
                    verticalSpace(2),
                    Text(
                      appointment.patientName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: isCancelled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (appointment.note != null) ...[
                      verticalSpace(2),
                      Text(
                        appointment.note!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'appointments.status.${appointment.status.name}'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
              if (onAction != null)
                PopupMenuButton<AppointmentMenuAction>(
                  onSelected: onAction,
                  itemBuilder: (_) => [
                    if (appointment.isScheduled) ...[
                      _item(
                        AppointmentMenuAction.complete,
                        Icons.check_circle_outline,
                        'appointments.actions.complete',
                      ),
                      _item(
                        AppointmentMenuAction.cancel,
                        Icons.cancel_outlined,
                        'appointments.actions.cancel',
                      ),
                    ] else
                      _item(
                        AppointmentMenuAction.reschedule,
                        Icons.replay,
                        'appointments.actions.reschedule',
                      ),
                    _item(
                      AppointmentMenuAction.edit,
                      Icons.edit_outlined,
                      'appointments.actions.edit',
                    ),
                    _item(
                      AppointmentMenuAction.delete,
                      Icons.delete_outline,
                      'appointments.actions.delete',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<AppointmentMenuAction> _item(
    AppointmentMenuAction action,
    IconData icon,
    String labelKey,
  ) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(labelKey.tr()),
        ],
      ),
    );
  }
}
