import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/app_validators.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_form_cubit.dart';

/// Add a new patient, or edit an existing one when [patient] is given.
class PatientFormScreen extends StatefulWidget {
  final Patient? patient;

  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _phone;
  late final TextEditingController _reason;
  late Gender _gender;

  bool get _isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _name = TextEditingController(text: p?.name ?? '');
    _age = TextEditingController(text: p == null ? '' : '${p.age}');
    _phone = TextEditingController(text: p?.phone ?? '');
    _reason = TextEditingController(text: p?.reasonForVisit ?? '');
    _gender = p?.gender ?? Gender.male;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<PatientFormCubit>().save(
      existing: widget.patient,
      name: _name.text,
      age: int.parse(_age.text.trim()),
      gender: _gender,
      phone: _phone.text,
      reasonForVisit: _reason.text,
    );
  }

  String? _validateAge(String? value) {
    final age = int.tryParse(value?.trim() ?? '');
    if (age == null || age < 0 || age > 130) {
      return 'patients.form.age_invalid'.tr();
    }
    return null;
  }

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientFormCubit, PatientFormState>(
      listener: (context, state) {
        if (state.isSuccess && state.savedPatient != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('patients.form.saved'.tr())));
          if (_isEditing) {
            Navigator.of(context).pop();
          } else {
            // Go straight to the new patient's file.
            Navigator.of(context).pushReplacementNamed(
              Routes.patientDetail,
              arguments: state.savedPatient!.id,
            );
          }
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
                      ? 'patients.form.edit_title'
                      : 'patients.form.new_title')
                  .tr(),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: _decoration('patients.form.name_label'.tr()),
                    validator: (v) => AppValidators.validateRequired(
                      v,
                      'patients.form.name_required'.tr(),
                    ),
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _age,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _decoration('patients.form.age_label'.tr()),
                    validator: _validateAge,
                  ),
                  verticalSpace(16),
                  SegmentedButton<Gender>(
                    segments: [
                      ButtonSegment(
                        value: Gender.male,
                        label: Text('patients.gender.male'.tr()),
                        icon: const Icon(Icons.male),
                      ),
                      ButtonSegment(
                        value: Gender.female,
                        label: Text('patients.gender.female'.tr()),
                        icon: const Icon(Icons.female),
                      ),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (s) =>
                        setState(() => _gender = s.first),
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _phone,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    decoration: _decoration(
                      'patients.form.phone_label'.tr(),
                      hint: '01xxxxxxxxx',
                    ),
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _reason,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: _decoration(
                      'patients.form.reason_label'.tr(),
                      hint: 'patients.form.reason_hint'.tr(),
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
          ),
        );
      },
    );
  }
}
