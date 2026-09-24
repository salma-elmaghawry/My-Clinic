import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/app_validators.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_state.dart';
import 'package:my_clinic/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_clinic/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:my_clinic/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:my_clinic/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _errorCount = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorCount++);
      return;
    }
    context.read<AuthCubit>().signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _saveNameToProfile() {
    final profileCubit = context.read<DoctorProfileCubit>();
    final profile = profileCubit.state.profile;
    profileCubit.save(
      name: _nameController.text.trim(),
      specialty: profile.specialty,
      clinicName: profile.clinicName,
    );
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state.succeeded(AuthAction.signUp)) {
      _saveNameToProfile();
      if (state.signUpOutcome == SignUpOutcome.needsEmailVerification) {
        context.pushReplacementNamed(
          Routes.verifyEmail,
          arguments: _emailController.text.trim(),
        );
      } else {
        context.pushNamedAndRemoveUntil(Routes.main, predicate: (_) => false);
      }
      return;
    }
    if (!state.isFailure) return;
    setState(() => _errorCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message ?? 'errors.unexpected_error'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: _onStateChanged,
          builder: (context, state) {
            final isLoading = state.isLoadingFor(AuthAction.signUp);
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        title: 'auth.signup.title'.tr(),
                        subtitle: 'auth.signup.subtitle'.tr(),
                      ),
                      verticalSpace(28),
                      ...[
                        AuthTextField(
                          controller: _nameController,
                          label: 'auth.signup.name_label'.tr(),
                          hint: 'auth.signup.name_hint'.tr(),
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.name],
                          validator: AppValidators.validateName,
                        ),
                        verticalSpace(16),
                        AuthTextField(
                          controller: _emailController,
                          label: 'auth.login.email_label'.tr(),
                          hint: 'auth.login.email_hint'.tr(),
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: AppValidators.validateEmail,
                        ),
                        verticalSpace(16),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'auth.login.password_label'.tr(),
                          hint: 'auth.signup.password_hint'.tr(),
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: AppValidators.validateNewPassword,
                        ),
                        verticalSpace(16),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: 'auth.signup.confirm_password_label'.tr(),
                          hint: 'auth.signup.confirm_password_hint'.tr(),
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              AppValidators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                          onFieldSubmitted: (_) => _onSubmit(),
                        ),
                        verticalSpace(24),
                        AuthSubmitButton(
                          label: 'auth.signup.submit'.tr(),
                          isLoading: isLoading,
                          errorCount: _errorCount,
                          onPressed: _onSubmit,
                        ),
                        verticalSpace(16),
                        AuthSwitchPrompt(
                          prompt: 'auth.signup.have_account'.tr(),
                          actionLabel: 'auth.signup.sign_in_link'.tr(),
                          onPressed: isLoading ? null : context.pop,
                        ),
                      ].animateList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
