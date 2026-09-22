import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/features/settings/presentation/cubit/daily_reminder_cubit.dart';
import 'package:my_clinic/features/settings/presentation/cubit/daily_reminder_state.dart';

/// A single switch: "remind me every day to log today's patients". Backed
/// by an on-device local notification, so it needs no server and works
/// with no internet connection.
class DailyReminderSwitcher extends StatelessWidget {
  const DailyReminderSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DailyReminderCubit, DailyReminderState>(
      listenWhen: (previous, current) => current.permissionDenied,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('notifications.permission_denied'.tr())),
        );
      },
      builder: (context, state) {
        return SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text('notifications.daily_reminder.settings_label'.tr()),
          subtitle: Text(
            'notifications.daily_reminder.settings_subtitle'.tr(
              namedArgs: {
                'time': TimeOfDay(hour: state.hour, minute: state.minute)
                    .format(context),
              },
            ),
          ),
          value: state.enabled,
          onChanged: (value) => context.read<DailyReminderCubit>().toggle(value),
        );
      },
    );
  }
}
