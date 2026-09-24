import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

import 'doctor_avatar.dart';

/// Large tappable avatar at the top of the profile screen. Tapping it lets
/// the doctor take a photo, choose one from the gallery, or remove it.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({super.key});

  Future<void> _showOptions(BuildContext context) async {
    final cubit = context.read<DoctorProfileCubit>();
    final hasPhoto = cubit.state.profile.hasPhoto;

    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('profile.photo_camera'.tr()),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('profile.photo_gallery'.tr()),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(sheetContext).colorScheme.error,
                ),
                title: Text(
                  'profile.photo_remove'.tr(),
                  style: TextStyle(color: Theme.of(sheetContext).colorScheme.error),
                ),
                onTap: () => Navigator.pop(sheetContext, _PhotoAction.remove),
              ),
          ],
        ),
      ),
    );
    if (action == null) return;

    if (action == _PhotoAction.remove) {
      await cubit.removePhoto();
      return;
    }

    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: action == _PhotoAction.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.photo_error'.tr())),
        );
      }
      return;
    }
    if (picked == null) return;
    await cubit.updatePhoto(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = 112.w;

    return Center(
      child: Column(
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _showOptions(context),
            child: Stack(
              children: [
                DoctorAvatar(
                  size: size,
                  borderRadius: BorderRadius.circular(size / 2),
                ),
                PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 18.w,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showOptions(context),
            child: Text('profile.photo_change'.tr()),
          ),
        ],
      ),
    );
  }
}

enum _PhotoAction { camera, gallery, remove }
