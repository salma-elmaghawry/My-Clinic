import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/services/daily_reminder_service.dart';

import 'daily_reminder_state.dart';

class DailyReminderCubit extends Cubit<DailyReminderState> {
  final DailyReminderService _service;

  DailyReminderCubit(this._service)
    : super(DailyReminderState(
        enabled: _service.isEnabled,
        hour: _service.hour,
        minute: _service.minute,
      ));

  Future<void> toggle(bool enabled) async {
    final granted = await _service.setEnabled(enabled);
    emit(state.copyWith(enabled: granted && enabled, permissionDenied: enabled && !granted));
  }

  Future<void> setTime(int hour, int minute) async {
    if (!state.enabled) return;
    await _service.setEnabled(true, hour: hour, minute: minute);
    emit(state.copyWith(hour: hour, minute: minute));
  }
}
