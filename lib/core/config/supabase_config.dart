/// Supabase project credentials, read at build time via --dart-define so
/// they never live in source control (see .gitignore's .env* entries and
/// docs/SUPABASE_SETUP.md for how to obtain and pass them).
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
///
/// Uses Supabase's current "publishable key" naming (what used to be
/// called the anon key) — see docs/SUPABASE_SETUP.md for exactly where to
/// copy these from the Supabase dashboard.
///
/// Deliberately optional: with no project configured yet, [isConfigured]
/// is false, main.dart skips Supabase.initialize(), and the app keeps
/// working exactly as it does today, fully on-device. This lets the
/// rebrand/signing/profile/notifications/dictation work in this pass ship
/// and be tested independently of when the Supabase project itself is
/// actually created.
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
