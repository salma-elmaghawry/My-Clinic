import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/app_validators.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_state.dart';
import 'package:my_clinic/features/profile/presentation/widgets/profile_photo_picker.dart';

/// Lets any doctor set their own photo, name, specialty and clinic name, replacing
/// what used to be a single hardcoded profile. Specialty is a plain text
/// field on purpose — the app makes no assumption about which medical
/// specialty is using it.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _clinicNameController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<DoctorProfileCubit>().state.profile;
    _nameController = TextEditingController(text: profile.name);
    _specialtyController = TextEditingController(text: profile.specialty);
    _clinicNameController = TextEditingController(text: profile.clinicName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _clinicNameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await context.read<DoctorProfileCubit>().save(
      name: _nameController.text,
      specialty: _specialtyController.text,
      clinicName: _clinicNameController.text,
    );
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.saved_snackbar'.tr())),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr())),
      body: SafeArea(
        child: BlocConsumer<DoctorProfileCubit, DoctorProfileState>(
          listenWhen: (previous, current) => current.isFailure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'errors.unexpected_error'.tr())),
            );
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  const ProfilePhotoPicker(),
                  verticalSpace(12),
                  Text(
                    'profile.subtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  verticalSpace(20),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'profile.doctor_name_label'.tr(),
                      hintText: 'profile.doctor_name_hint'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: AppValidators.validateName,
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _specialtyController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'profile.specialty_label'.tr(),
                      hintText: 'profile.specialty_hint'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: (value) => AppValidators.validateRequired(
                      value,
                      'profile.specialty_required'.tr(),
                    ),
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _clinicNameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'profile.clinic_name_label'.tr(),
                      hintText: 'profile.clinic_name_hint'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  verticalSpace(28),
                  FilledButton(
                    onPressed: state.isLoading ? null : _onSave,
                    child: state.isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('profile.save'.tr()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
