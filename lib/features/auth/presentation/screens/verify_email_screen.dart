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

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  int _errorCount = 0;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorCount++);
      return;
    }
    context.read<AuthCubit>().verifyEmail(
      email: widget.email,
      code: _codeController.text,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state.succeeded(AuthAction.verifyEmail)) {
      context.pushNamedAndRemoveUntil(Routes.main, predicate: (_) => false);
    } else if (state.succeeded(AuthAction.resendCode)) {
      _showSnackBar('auth.verify.resent_snackbar'.tr());
    } else if (state.isFailure) {
      setState(() => _errorCount++);
      _showSnackBar(state.message ?? 'errors.unexpected_error'.tr());
    }
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(
                      title: 'auth.verify.title'.tr(),
                      subtitle: 'auth.verify.subtitle'.tr(args: [widget.email]),
                    ),
                    verticalSpace(28),
                    ...[
                      AuthTextField(
                        controller: _codeController,
                        label: 'auth.verify.code_label'.tr(),
                        hint: 'auth.verify.code_hint'.tr(),
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        validator: AppValidators.validateOtpCode,
                        onFieldSubmitted: (_) => _onSubmit(),
                      ),
                      verticalSpace(24),
                      AuthSubmitButton(
                        label: 'auth.verify.submit'.tr(),
                        isLoading: state.isLoadingFor(AuthAction.verifyEmail),
                        errorCount: _errorCount,
                        onPressed: _onSubmit,
                      ),
                      verticalSpace(16),
                      AuthSwitchPrompt(
                        prompt: 'auth.verify.no_code'.tr(),
                        actionLabel: 'auth.verify.resend'.tr(),
                        onPressed: isBusy
                            ? null
                            : () => context.read<AuthCubit>().resendCode(
                                widget.email,
                              ),
                      ),
                    ].animateList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
