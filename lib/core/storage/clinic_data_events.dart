import 'dart:async';

/// App-wide "clinic data changed" signal.
///
/// Screens in the bottom-nav shell live in an [IndexedStack], so they stay
/// mounted while the doctor edits data on other screens. Repositories call
/// [notifyChanged] after every write, and list cubits listen to [stream] to
/// reload, so Home, Patients, Appointments and Stats never show stale data.
class ClinicDataEvents {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notifyChanged() => _controller.add(null);
}
