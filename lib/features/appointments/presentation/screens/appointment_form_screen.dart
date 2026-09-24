import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointment_form_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/screens/appointment_form_args.dart';
import 'package:my_clinic/features/patients/presentation/widgets/patient_picker_sheet.dart';

class AppointmentFormScreen extends StatefulWidget {
  final AppointmentFormArgs args;

  const AppointmentFormScreen({super.key, required this.args});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  late String? _patientId;
  late String? _patientName;
  late DateTime _date;
  late TimeOfDay _time;
  late final TextEditingController _noteController;

  bool get _isEditing => widget.args.appointment != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.appointment;
    _patientId = existing?.patientId ?? widget.args.patientId;
    _patientName = existing?.patientName ?? widget.args.patientName;
    final now = DateTime.now();
    final base = existing?.dateTime ?? widget.args.initialDate ?? now;
    _date = DateTime(base.year, base.month, base.day);
    _time = existing != null
        ? TimeOfDay.fromDateTime(existing.dateTime)
        : TimeOfDay(hour: now.hour + 1 > 23 ? 23 : now.hour + 1, minute: 0);
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPatient() async {
    final patient = await showPatientPickerSheet(context);
    if (patient != null) {
      setState(() {
        _patientId = patient.id;
        _patientName = patient.name;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    context.read<AppointmentFormCubit>().save(
      existing: widget.args.appointment,
      patientId: _patientId,
      patientName: _patientName,
      dateTime: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ),
      note: _noteController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.toString();
    final patientLocked = _isEditing || widget.args.patientId != null;
    return BlocConsumer<AppointmentFormCubit, AppointmentFormState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('appointments.form.saved'.tr())),
          );
          Navigator.of(context).pop(true);
        } else if (state.isFailure && state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              (_isEditing
                      ? 'appointments.form.edit_title'
                      : 'appointments.form.new_title')
                  .tr(),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.person_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      _patientName ?? 'appointments.form.choose_patient'.tr(),
                    ),
                    subtitle: Text('appointments.form.patient_label'.tr()),
                    trailing: patientLocked
                        ? null
                        : const Icon(Icons.chevron_right),
                    onTap: patientLocked ? null : _pickPatient,
                  ),
                ),
                verticalSpace(12),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.event_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(DateFormat.yMMMMEEEEd(locale).format(_date)),
                    subtitle: Text('appointments.form.date_label'.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickDate,
                  ),
                ),
                verticalSpace(12),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.schedule_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(_time.format(context)),
                    subtitle: Text('appointments.form.time_label'.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickTime,
                  ),
                ),
                verticalSpace(16),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: 'appointments.form.note_label'.tr(),
                    hintText: 'appointments.form.note_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                verticalSpace(28),
                FilledButton(
                  onPressed: state.isLoading ? null : _save,
                  child: state.isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text('common.save'.tr()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
