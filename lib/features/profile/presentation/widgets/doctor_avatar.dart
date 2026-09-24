import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

/// The doctor's own photo when they have picked one, otherwise the clinic
/// logo. Rebuilds whenever the profile changes.
class DoctorAvatar extends StatelessWidget {
  final double size;
  final BorderRadius borderRadius;

  const DoctorAvatar({
    super.key,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<DoctorProfileCubit>().state.profile;
    final logo = Image.asset(
      profile.logoAssetPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: profile.hasPhoto
          ? Image.file(
              File(profile.photoPath!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => logo,
            )
          : logo,
    );
  }
}
