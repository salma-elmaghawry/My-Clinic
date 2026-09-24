import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _errorCount = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorCount++);
      return;
    }
    context.read<AuthCubit>().signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state.succeeded(AuthAction.signIn)) {
      context.pushNamedAndRemoveUntil(Routes.main, predicate: (_) => false);
      return;
    }
    if (!state.isFailure) return;
    setState(() => _errorCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message ?? 'errors.unexpected_error'.tr())),
    );
    if (state.failure is EmailNotConfirmedFailure) {
      context.pushNamed(
        Routes.verifyEmail,
        arguments: _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: _onStateChanged,
          builder: (context, state) {
            final isLoading = state.isLoadingFor(AuthAction.signIn);
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        title: 'auth.login.title'.tr(),
                        subtitle: 'auth.login.subtitle'.tr(),
                      ),
                      verticalSpace(32),
                      ...[
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
                          hint: 'auth.login.password_hint'.tr(),
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          validator: AppValidators.validatePassword,
                          onFieldSubmitted: (_) => _onSubmit(),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.pushNamed(
                                    Routes.forgotPassword,
                                    arguments: _emailController.text.trim(),
                                  ),
                            child: Text('auth.login.forgot_password'.tr()),
                          ),
                        ),
                        verticalSpace(8),
                        AuthSubmitButton(
                          label: 'auth.login.submit'.tr(),
                          isLoading: isLoading,
                          errorCount: _errorCount,
                          onPressed: _onSubmit,
                        ),
                        verticalSpace(16),
                        AuthSwitchPrompt(
                          prompt: 'auth.login.no_account'.tr(),
                          actionLabel: 'auth.login.sign_up_link'.tr(),
                          onPressed: isLoading
                              ? null
                              : () => context.pushNamed(Routes.signUp),
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
