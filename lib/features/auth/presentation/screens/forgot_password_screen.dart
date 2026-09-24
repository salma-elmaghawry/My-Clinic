import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/app_validators.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_state.dart';
import 'package:my_clinic/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_clinic/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:my_clinic/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:my_clinic/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _codeSent = false;
  int _errorCount = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
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
    final cubit = context.read<AuthCubit>();
    if (_codeSent) {
      cubit.resetPassword(
        email: _emailController.text,
        code: _codeController.text,
        newPassword: _passwordController.text,
      );
    } else {
      cubit.sendResetCode(_emailController.text);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state.succeeded(AuthAction.sendResetCode)) {
      setState(() => _codeSent = true);
      _showSnackBar('auth.forgot.code_sent_snackbar'.tr());
    } else if (state.succeeded(AuthAction.resetPassword)) {
      _showSnackBar('auth.forgot.success_snackbar'.tr());
      context.pushNamedAndRemoveUntil(Routes.main, predicate: (_) => false);
    } else if (state.isFailure) {
      setState(() => _errorCount++);
      _showSnackBar(state.message ?? 'errors.unexpected_error'.tr());
    }
  }

  List<Widget> _codeAndPasswordFields() {
    return [
      verticalSpace(16),
      AuthTextField(
        controller: _codeController,
        label: 'auth.verify.code_label'.tr(),
        hint: 'auth.verify.code_hint'.tr(),
        icon: Icons.pin_outlined,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        validator: AppValidators.validateOtpCode,
      ),
      verticalSpace(16),
      AuthTextField(
        controller: _passwordController,
        label: 'auth.forgot.new_password_label'.tr(),
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
        validator: (value) => AppValidators.validateConfirmPassword(
          value,
          _passwordController.text,
        ),
        onFieldSubmitted: (_) => _onSubmit(),
      ),
    ].animateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: _onStateChanged,
          builder: (context, state) {
            final isBusy = state.isLoading;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        title: 'auth.forgot.title'.tr(),
                        subtitle: _codeSent
                            ? 'auth.forgot.code_sent_subtitle'.tr(
                                args: [_emailController.text.trim()],
                              )
                            : 'auth.forgot.subtitle'.tr(),
                      ),
                      verticalSpace(28),
                      AuthTextField(
                        controller: _emailController,
                        label: 'auth.login.email_label'.tr(),
                        hint: 'auth.login.email_hint'.tr(),
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: _codeSent
                            ? TextInputAction.next
                            : TextInputAction.done,
                        validator: AppValidators.validateEmail,
                        onFieldSubmitted: _codeSent ? null : (_) => _onSubmit(),
                      ).fadeInSlideUp(),
                      if (_codeSent) ..._codeAndPasswordFields(),
                      verticalSpace(24),
                      AuthSubmitButton(
                        label: _codeSent
                            ? 'auth.forgot.submit'.tr()
                            : 'auth.forgot.send_code'.tr(),
                        isLoading:
                            state.isLoadingFor(AuthAction.sendResetCode) ||
                            state.isLoadingFor(AuthAction.resetPassword),
                        errorCount: _errorCount,
                        onPressed: _onSubmit,
                      ),
                      if (_codeSent) ...[
                        verticalSpace(16),
                        AuthSwitchPrompt(
                          prompt: 'auth.verify.no_code'.tr(),
                          actionLabel: 'auth.verify.resend'.tr(),
                          onPressed: isBusy
                              ? null
                              : () => context.read<AuthCubit>().sendResetCode(
                                  _emailController.text,
                                ),
                        ),
                      ],
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
