/// Single hardcoded doctor profile — this pass has no auth / multi-doctor
/// support, so the profile is a plain constant rather than repository-backed.
class DoctorProfile {
  final String name;
  final String titleKey;
  final String logoAssetPath;
  final String? signatureAssetPath;

  const DoctorProfile({
    required this.name,
    required this.titleKey,
    required this.logoAssetPath,
    this.signatureAssetPath,
  });
}

/// No signature image asset exists yet, so [signatureAssetPath] stays null
/// and the prescription preview renders the name in a cursive GoogleFonts
/// style instead (see AppTextStyles.signatureCursive).
const kDoctorProfile = DoctorProfile(
  name: 'Dr. Ahmed Elmaghawry',
  titleKey: 'doctor.title',
  logoAssetPath: 'assets/logo.png',
  signatureAssetPath: null,
);
