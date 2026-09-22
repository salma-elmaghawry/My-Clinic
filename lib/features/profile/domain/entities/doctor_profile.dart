import 'package:equatable/equatable.dart';

/// The signed-in doctor's own profile: their name, free-text specialty and
/// clinic name. Specialty is plain user input (not a translation key) so
/// the app works for any medical specialty, not just the one it originally
/// shipped with.
class DoctorProfile extends Equatable {
  final String name;
  final String specialty;
  final String clinicName;
  final String logoAssetPath;

  const DoctorProfile({
    required this.name,
    required this.specialty,
    required this.clinicName,
    this.logoAssetPath = 'assets/logo.png',
  });

  /// True once the doctor has actually filled in their own details, as
  /// opposed to still showing the placeholder copy from a fresh install.
  bool get isComplete => name.trim().isNotEmpty && specialty.trim().isNotEmpty;

  DoctorProfile copyWith({
    String? name,
    String? specialty,
    String? clinicName,
    String? logoAssetPath,
  }) {
    return DoctorProfile(
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      clinicName: clinicName ?? this.clinicName,
      logoAssetPath: logoAssetPath ?? this.logoAssetPath,
    );
  }

  @override
  List<Object?> get props => [name, specialty, clinicName, logoAssetPath];
}
