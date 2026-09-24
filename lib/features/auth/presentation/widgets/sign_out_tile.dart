import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/core/utils/app_text_styles.dart';
import 'package:my_clinic/core/widgets/confirm_dialog.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_state.dart';

class SignOutTile extends StatelessWidget {
  const SignOutTile({super.key});

  Future<void> _onTap(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'auth.sign_out.confirm_title'.tr(),
      message: 'auth.sign_out.confirm_message'.tr(),
      confirmLabel: 'auth.sign_out.confirm'.tr(),
    );
    if (!confirmed || !context.mounted) return;
    await context.read<AuthCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.succeeded(AuthAction.signOut)) {
          context.pushNamedAndRemoveUntil(
            Routes.login,
            predicate: (_) => false,
          );
        } else if (state.isFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message ?? '')));
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoadingFor(AuthAction.signOut);
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            iconColor: colorScheme.error,
            textColor: colorScheme.error,
            leading: const Icon(Icons.logout_rounded),
            title: Text('auth.sign_out.title'.tr()),
            subtitle: Text(
              context.read<AuthCubit>().currentEmail ??
                  'auth.sign_out.subtitle'.tr(),
              style: AppTextStyles.font14Normal.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: isLoading ? null : () => _onTap(context),
          ),
        );
      },
    );
  }
}
