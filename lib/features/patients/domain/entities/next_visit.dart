import 'package:equatable/equatable.dart';

class NextVisit extends Equatable {
  final DateTime dateTime;
  final bool reminderSet;

  const NextVisit({required this.dateTime, required this.reminderSet});

  @override
  List<Object?> get props => [dateTime, reminderSet];
}
