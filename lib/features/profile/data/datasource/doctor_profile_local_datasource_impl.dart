import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_clinic/features/profile/domain/entities/doctor_profile.dart';

import 'doctor_profile_local_datasource.dart';

/// Persists the doctor's profile on-device via [SharedPreferences]. This is
/// deliberately a drop-in seam: a future `DoctorProfileSupabaseDataSource`
/// implementing the same interface can replace it once accounts sync to
/// Supabase, without any caller (repository, cubit, widgets) changing.
///
/// The photo itself lives as a file in the app documents directory. Only its
/// file name goes into prefs, because on iOS the absolute path of the app's
/// container changes between app updates.
class DoctorProfileLocalDataSourceImpl implements DoctorProfileLocalDataSource {
  static const String _nameKey = 'doctor_profile_name';
  static const String _specialtyKey = 'doctor_profile_specialty';
  static const String _clinicNameKey = 'doctor_profile_clinic_name';
  static const String _photoFileKey = 'doctor_profile_photo_file';

  final SharedPreferences _prefs;

  DoctorProfileLocalDataSourceImpl(this._prefs);

  @override
  Future<DoctorProfile> getProfile() async {
    return DoctorProfile(
      name: _prefs.getString(_nameKey) ?? '',
      specialty: _prefs.getString(_specialtyKey) ?? '',
      clinicName: _prefs.getString(_clinicNameKey) ?? '',
      photoPath: await _storedPhotoPath(),
    );
  }

  @override
  Future<void> saveProfile(DoctorProfile profile) async {
    await _prefs.setString(_nameKey, profile.name.trim());
    await _prefs.setString(_specialtyKey, profile.specialty.trim());
    await _prefs.setString(_clinicNameKey, profile.clinicName.trim());
  }

  @override
  Future<String> savePhoto(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final extension = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.'))
        : '.jpg';
    // A fresh name per pick so Flutter's image cache never serves the old
    // photo for a path that was overwritten.
    final fileName =
        'doctor_photo_${DateTime.now().millisecondsSinceEpoch}$extension';
    final stored = await File(sourcePath).copy('${dir.path}/$fileName');

    await _deleteStoredPhotoFile();
    await _prefs.setString(_photoFileKey, fileName);
    return stored.path;
  }

  @override
  Future<void> removePhoto() async {
    await _deleteStoredPhotoFile();
    await _prefs.remove(_photoFileKey);
  }

  Future<String?> _storedPhotoPath() async {
    final fileName = _prefs.getString(_photoFileKey);
    if (fileName == null || fileName.isEmpty) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    return await file.exists() ? file.path : null;
  }

  Future<void> _deleteStoredPhotoFile() async {
    final path = await _storedPhotoPath();
    if (path != null) await File(path).delete();
  }
}
