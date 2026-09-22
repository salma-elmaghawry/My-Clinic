import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// A single local, on-device notification nudging the doctor to open the
/// app and log today's patients. No server, no push infrastructure —
/// entirely offline, which also means it costs nothing and works with no
/// internet connection (relevant for the offline-first goal of this app).
///
/// This deliberately schedules with [AndroidScheduleMode.inexactAllowWhileIdle]
/// rather than an exact alarm: Google Play gates the exact-alarm permission
/// behind a declared-use policy meant for alarm/calendar-class apps, and a
/// "did you log today's patients?" nudge has no need to fire at the exact
/// minute, so it isn't worth that extra review friction.
class DailyReminderService {
  static const String _enabledKey = 'daily_reminder_enabled';
  static const String _hourKey = 'daily_reminder_hour';
  static const String _minuteKey = 'daily_reminder_minute';
  static const int _notificationId = 1001;

  final FlutterLocalNotificationsPlugin _plugin;
  final SharedPreferences _prefs;
  bool _initialized = false;

  DailyReminderService(this._prefs) : _plugin = FlutterLocalNotificationsPlugin();

  bool get isEnabled => _prefs.getBool(_enabledKey) ?? false;

  /// Defaults to 9:00 AM local time — end of the typical morning clinic
  /// rush, before doctors move on to the next thing and forget.
  int get hour => _prefs.getInt(_hourKey) ?? 9;
  int get minute => _prefs.getInt(_minuteKey) ?? 0;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (_) {
      // Falls back to the timezone package's default (UTC) if the platform
      // lookup fails — the reminder still fires, just potentially at the
      // wrong local hour until this succeeds on a later launch.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  /// Requests OS notification permission (Android 13+, iOS) and returns
  /// whether it was granted. Safe to call even where it's a no-op
  /// (Android 12 and below grant this at install time).
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  Future<bool> setEnabled(bool enabled, {int? hour, int? minute}) async {
    await _ensureInitialized();
    await _prefs.setBool(_enabledKey, enabled);
    if (hour != null) await _prefs.setInt(_hourKey, hour);
    if (minute != null) await _prefs.setInt(_minuteKey, minute);

    if (!enabled) {
      await _plugin.cancel(id: _notificationId);
      return true;
    }

    final granted = await requestPermission();
    if (!granted) {
      await _prefs.setBool(_enabledKey, false);
      return false;
    }
    await _schedule();
    return true;
  }

  /// Re-arms the daily reminder on app start if it was left enabled — the
  /// OS can drop scheduled notifications across an app update or a device
  /// reboot depending on manufacturer, so this is cheap insurance.
  Future<void> rescheduleIfEnabled() async {
    if (!isEnabled) return;
    await _ensureInitialized();
    await _schedule();
  }

  Future<void> _schedule() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'notifications.daily_reminder.title'.tr(),
      body: 'notifications.daily_reminder.body'.tr(),
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily patient log reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
