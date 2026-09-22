import 'package:equatable/equatable.dart';

class DailyReminderState extends Equatable {
  final bool enabled;
  final int hour;
  final int minute;
  final bool permissionDenied;

  const DailyReminderState({
    this.enabled = false,
    this.hour = 9,
    this.minute = 0,
    this.permissionDenied = false,
  });

  DailyReminderState copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    bool? permissionDenied,
  }) {
    return DailyReminderState(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      permissionDenied: permissionDenied ?? false,
    );
  }

  @override
  List<Object?> get props => [enabled, hour, minute, permissionDenied];
}
