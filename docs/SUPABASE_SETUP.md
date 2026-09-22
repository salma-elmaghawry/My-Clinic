# Supabase setup

Status today: the app still runs fully on-device (SharedPreferences +
in-memory demo data), exactly as before. This document is what to do to
turn on the Supabase backend; nothing here happens automatically.

## 1. Create the project

1. Go to https://supabase.com/dashboard and create a new project.
   - Pick a region close to your users (e.g. an EU or Middle East region)
     for lower latency — this is the practical version of "keep the data
     local": you get your own private Postgres database, in a region you
     choose, that no other app or customer shares.
   - Note the database password somewhere safe (a password manager). You
     won't need it for the Flutter app itself, only if you ever connect
     directly to Postgres.
2. In your new project, open **SQL Editor > New query**, paste the entire
   contents of `supabase/schema.sql` from this repo, and run it. This
   creates the `doctors`, `patients`, `patient_medical_history`, `drugs`,
   `prescriptions` and `prescription_drugs` tables with Row Level Security
   already turned on, so one doctor's data is never visible to another —
   enforced by Postgres itself, not by app code.
3. Open **Project Settings > API**. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **Publishable key** (this used to be called the "anon" key) →
     `SUPABASE_PUBLISHABLE_KEY`

## 2. Run the app against it

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxxxxxxxxx
```

For a release build, add the same two `--dart-define` flags to
`flutter build apk --release ...` / `flutter build appbundle --release ...`.
Keep them out of any file that gets committed — pass them as CI secrets or
in a local, gitignored `.env` you load into your shell before building
(`.env*` is already in `.gitignore`).

With no `--dart-define` passed, `SupabaseConfig.isConfigured` is false,
`Supabase.initialize()` is skipped in `lib/main.dart`, and the app behaves
exactly as it does today — this is safe to merge and ship before the
project even exists.

## 3. What's NOT done yet (the next pass)

Creating the project and running the schema does **not** by itself move any
data. The four local datasources still serve local/demo data:

- `PatientsLocalDataSourceImpl` (in-memory demo patients — resets on restart)
- `PrescriptionsLocalDataSourceImpl`
- `DrugsLocalDataSourceImpl`
- `DoctorProfileLocalDataSourceImpl` (real persistence via SharedPreferences)

The intended next step, sized as its own piece of work:

1. **Add Supabase Auth** (email/password or phone OTP) as a real sign-in
   screen — `assets/translations/*.json` already has the `auth.*` copy
   keys reserved for this, and `core/error_handling/failures.dart`
   already has the matching `Failure` subclasses
   (`InvalidCredentialsFailure`, `EmailAlreadyInUseFailure`, etc.).
2. **Write one new datasource class per feature**
   (`PatientsSupabaseDataSource`, `PrescriptionsSupabaseDataSource`, ...)
   implementing the *same* abstract datasource interface the local ones
   already implement, then swap which one `injection_container.dart`
   wires up. Nothing above the datasource layer (repositories, cubits,
   screens) needs to change — that seam is why the repository pattern is
   there.
3. **Offline-first sync**: keep a local cache (the existing in-memory
   layer is a natural starting point to evolve into a real local database,
   e.g. `drift`/sqflite) as the source of truth for the UI, write through
   to Supabase when online, and queue writes made offline to replay on
   reconnect. This preserves the app's current "works with no internet in
   the clinic" behavior while adding sync — matching the requirement that
   the app keep working when the clinic's internet is unstable.
4. **Drug database**: seed `public.drugs` from the same list currently
   hardcoded in `DrugsLocalDataSourceImpl`, then point
   `DrugsSupabaseDataSource` at it — this becomes one shared, maintained
   list every doctor benefits from instead of a per-install copy.
