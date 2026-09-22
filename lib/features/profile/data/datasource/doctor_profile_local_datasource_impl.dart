import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_clinic/features/profile/domain/entities/doctor_profile.dart';

import 'doctor_profile_local_datasource.dart';

/// Persists the doctor's profile on-device via [SharedPreferences]. This is
/// deliberately a drop-in seam: a future `DoctorProfileSupabaseDataSource`
/// implementing the same interface can replace it once accounts sync to
/// Supabase, without any caller (repository, cubit, widgets) changing.
class DoctorProfileLocalDataSourceImpl implements DoctorProfileLocalDataSource {
  static const String _nameKey = 'doctor_profile_name';
  static const String _specialtyKey = 'doctor_profile_specialty';
  static const String _clinicNameKey = 'doctor_profile_clinic_name';

  final SharedPreferences _prefs;

  DoctorProfileLocalDataSourceImpl(this._prefs);

  @override
  Future<DoctorProfile> getProfile() async {
    return DoctorProfile(
      name: _prefs.getString(_nameKey) ?? '',
      specialty: _prefs.getString(_specialtyKey) ?? '',
      clinicName: _prefs.getString(_clinicNameKey) ?? '',
    );
  }

  @override
  Future<void> saveProfile(DoctorProfile profile) async {
    await _prefs.setString(_nameKey, profile.name.trim());
    await _prefs.setString(_specialtyKey, profile.specialty.trim());
    await _prefs.setString(_clinicNameKey, profile.clinicName.trim());
  }
}
