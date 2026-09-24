# My Clinic (عيادتي)

A clinic assistant for doctors of any specialty. It runs fully offline on the
doctor's phone, in English or Arabic (right-to-left), in light or dark mode.

## Features

- **Patients.** Add, edit, search by name or phone, and delete patient files.
  Each file has medical history, current treatment, visits and prescriptions.
- **Prescriptions.** Pick a patient and drugs, set dose, frequency, duration
  and timing, and dictate the diagnosis by voice. Save a draft and finish it
  later, or issue it. An issued prescription becomes the patient's current
  treatment.
- **Share.** The preview renders the prescription on your letterhead with a
  QR code that holds the drug list. Share it as an image to WhatsApp, print,
  or files.
- **Appointments.** Week view with busy-day markers. Book, edit, mark done,
  cancel or delete visits. Marking a visit done updates the patient's last
  visit.
- **Drug database.** A built-in starter list plus your own drugs. Add drugs
  from this screen or straight from the prescription search.
- **Clinic stats.** Patient totals, monthly prescriptions and visits, gender
  split, and your most prescribed drugs.
- **Home.** Today's patients and appointments, recent patients, milestone
  tiers, and a daily reminder notification to log the day's patients.

## Run it

```bash
flutter pub get
flutter run
```

All data is stored on the device, so no setup or internet is needed. To
prepare the optional Supabase backend, see
[docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md).

## Test

```bash
flutter analyze
flutter test
```

The tests cover persistence, every repository, the main cubits, and two
full app walk-throughs, one in English and one in Arabic.

## Code layout

Feature-first Clean Architecture under `lib/features/<feature>/`:

- `data/` holds models and on-device datasources.
- `repository/` maps exceptions to typed failures with `dartz` `Either`.
- `presentation/` holds Cubits, screens and widgets.

Shared pieces live in `lib/core/`. That includes dependency injection
(`get_it`), routing, theming, the JSON store over SharedPreferences, and the
change signal that refreshes open screens after any edit.
