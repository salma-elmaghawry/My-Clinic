# Supabase setup

Status today: the app runs fully on-device. Patients, prescriptions,
appointments, custom drugs and the doctor profile are all saved in
SharedPreferences and survive restarts. This document is what to do to
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
   `prescriptions`, `prescription_drugs` and `appointments` tables with Row Level Security
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

## 3. Authentication (email + password)

Auth is implemented in `lib/features/auth/`. It only turns on when the two
`--dart-define` values above are passed. Without them the splash goes
straight to the home screen, as before.

Flow:

- The splash sends a signed-out doctor to **Sign in**. A saved session skips it.
- **Create account** asks for name, email and password. The name is stored
  in the user's metadata, and the `handle_new_doctor` trigger copies it into
  `public.doctors.name`. It is also saved to the on-device profile.
- If **Confirm email** is on, the doctor lands on **Verify your email** and
  types the code from the email. Signing in with an unconfirmed email also
  goes there.
- **Forgot password** sends a code, then takes the code plus a new password.
  The doctor ends up signed in.
- **Settings > Sign out** ends the session and returns to Sign in.

Codes are typed into the app instead of opening links, so no deep-link setup
(Android intent filters, iOS URL schemes, redirect URLs) is needed.

### Dashboard settings this flow needs

1. **Authentication > Sign In / Providers > Email**: keep Email enabled.
   "Confirm email" can be on or off. The app handles both.
2. **Authentication > Emails > Templates**: the default templates only
   contain a link. Add the code to two of them:
   - **Confirm signup**: add `{{ .Token }}`, for example
     `<p>Your My Clinic code: <strong>{{ .Token }}</strong></p>`
   - **Reset password**: add `{{ .Token }}` the same way.
3. **Authentication > Sign In / Providers > Email > Email OTP length**:
   the app accepts 6 to 10 digits, so the default of 6 works.
4. The built-in email sender is rate-limited and meant for testing. Before
   real doctors sign up, set a custom SMTP server under
   **Authentication > Emails > SMTP Settings**.
5. If you ran `supabase/schema.sql` before this change, run it again. It is
   idempotent, and the re-run updates `handle_new_doctor` so it copies the name.

### Known gap

Patients, prescriptions and appointments are still stored on the device,
not per account. Two doctors who sign in on the same phone see the same
local data until the Supabase datasources below replace the local ones.

## 4. What's NOT done yet (the next pass)

Creating the project and running the schema does **not** by itself move any
data. These local datasources still serve on-device data:

- `PatientsLocalDataSourceImpl`
- `PrescriptionsLocalDataSourceImpl`
- `AppointmentsLocalDataSourceImpl`
- `DrugsLocalDataSourceImpl` (built-in list plus the doctor's custom drugs)
- `DoctorProfileLocalDataSourceImpl`

The intended next step, sized as its own piece of work:

1. ~~Add Supabase Auth~~ Done, see section 3.
2. **Write one new datasource class per feature**
   (`PatientsSupabaseDataSource`, `PrescriptionsSupabaseDataSource`,
   `AppointmentsSupabaseDataSource`, ...)
   implementing the *same* abstract datasource interface the local ones
   already implement, then swap which one `injection_container.dart`
   wires up. Nothing above the datasource layer (repositories, cubits,
   screens) needs to change — that seam is why the repository pattern is
   there.
3. **Offline-first sync**: keep the existing on-device store (today a JSON
   list per collection in SharedPreferences; move it to `drift`/sqflite once
   clinics hold thousands of records) as the source of truth for the UI, write through
   to Supabase when online, and queue writes made offline to replay on
   reconnect. This preserves the app's current "works with no internet in
   the clinic" behavior while adding sync — matching the requirement that
   the app keep working when the clinic's internet is unstable.
4. **Drug database**: seed `public.drugs` from the same list currently
   hardcoded in `DrugsLocalDataSourceImpl`, and add a `doctor_id`-scoped
   table (or nullable `doctor_id` on `drugs`) for each doctor's custom
   drugs, then point
   `DrugsSupabaseDataSource` at it — this becomes one shared, maintained
   list every doctor benefits from instead of a per-install copy.

Note: local ids are generated strings, not UUIDs. The first sync must map
them to the `uuid` primary keys in the schema (or switch `generateId()` in
`lib/core/helpers/id_generator.dart` to UUID v4 before real data exists).
