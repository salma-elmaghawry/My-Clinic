-- My Clinic (عيادتي) — multi-tenant Supabase schema
--
-- Run this once in your Supabase project's SQL editor (Dashboard > SQL
-- Editor > New query) after creating the project. It is safe to re-run —
-- every statement is guarded with IF NOT EXISTS / OR REPLACE.
--
-- Design: every clinical table carries a doctor_id that always equals
-- auth.uid(). Row Level Security means a doctor's Postgres session can
-- only ever see their own rows — the multi-tenant isolation lives in the
-- database itself, not in app code, so a bug in a screen can't leak one
-- doctor's patients to another.
--
-- This file defines the target shape only. Wiring the Flutter data layer
-- to actually read/write these tables (swapping *LocalDataSourceImpl for a
-- Supabase-backed equivalent behind the existing repository interfaces) is
-- deliberately a separate, later pass — see docs/SUPABASE_SETUP.md.

-- ── doctors ───────────────────────────────────────────────────────────────
-- One row per signed-up doctor, keyed by their auth.users id. This is the
-- Supabase-backed successor to DoctorProfile (currently SharedPreferences).
create table if not exists public.doctors (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null default '',
  specialty text not null default '',   -- free text on purpose: any specialty
  clinic_name text not null default '',
  logo_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.doctors enable row level security;

drop policy if exists "Doctors manage their own profile" on public.doctors;
create policy "Doctors manage their own profile"
  on public.doctors
  for all
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- ── patients ─────────────────────────────────────────────────────────────
create table if not exists public.patients (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.doctors (id) on delete cascade,
  name text not null,
  age int,
  gender text not null check (gender in ('male', 'female')),
  phone text,
  reason_for_visit text,
  last_visit_at timestamptz,
  next_visit_at timestamptz,
  next_visit_reminder_set boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists patients_doctor_id_idx on public.patients (doctor_id);

alter table public.patients enable row level security;

drop policy if exists "Doctors manage their own patients" on public.patients;
create policy "Doctors manage their own patients"
  on public.patients
  for all
  using ((select auth.uid()) = doctor_id)
  with check ((select auth.uid()) = doctor_id);

-- ── patient_medical_history ─────────────────────────────────────────────
create table if not exists public.patient_medical_history (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients (id) on delete cascade,
  doctor_id uuid not null references public.doctors (id) on delete cascade,
  condition text not null,
  noted_at timestamptz not null default now()
);

create index if not exists patient_medical_history_patient_id_idx
  on public.patient_medical_history (patient_id);

alter table public.patient_medical_history enable row level security;

drop policy if exists "Doctors manage their own patients' history" on public.patient_medical_history;
create policy "Doctors manage their own patients' history"
  on public.patient_medical_history
  for all
  using ((select auth.uid()) = doctor_id)
  with check ((select auth.uid()) = doctor_id);

-- ── drugs ────────────────────────────────────────────────────────────────
-- A shared, read-only reference table (not per-doctor) so every clinic
-- benefits from the same maintained drug database. Doctors cannot write to
-- it from the client; update it via the dashboard or a service-role script.
create table if not exists public.drugs (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  generic_name text,
  category text,
  created_at timestamptz not null default now()
);

create index if not exists drugs_name_idx on public.drugs (name);

alter table public.drugs enable row level security;

drop policy if exists "Anyone signed in can read the drug database" on public.drugs;
create policy "Anyone signed in can read the drug database"
  on public.drugs
  for select
  using (auth.role() = 'authenticated');

-- ── prescriptions ────────────────────────────────────────────────────────
create table if not exists public.prescriptions (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.doctors (id) on delete cascade,
  patient_id uuid not null references public.patients (id) on delete cascade,
  diagnosis text,
  notes text,
  status text not null default 'draft' check (status in ('draft', 'issued')),
  issued_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists prescriptions_doctor_id_idx on public.prescriptions (doctor_id);
create index if not exists prescriptions_patient_id_idx on public.prescriptions (patient_id);

alter table public.prescriptions enable row level security;

drop policy if exists "Doctors manage their own prescriptions" on public.prescriptions;
create policy "Doctors manage their own prescriptions"
  on public.prescriptions
  for all
  using ((select auth.uid()) = doctor_id)
  with check ((select auth.uid()) = doctor_id);

-- ── prescription_drugs ───────────────────────────────────────────────────
create table if not exists public.prescription_drugs (
  id uuid primary key default gen_random_uuid(),
  prescription_id uuid not null references public.prescriptions (id) on delete cascade,
  doctor_id uuid not null references public.doctors (id) on delete cascade,
  drug_id uuid references public.drugs (id),
  drug_name text not null,
  generic_name text,
  dose text,
  frequency text,
  duration text,
  when_to_take text,
  notes text,
  sort_order int not null default 0
);

create index if not exists prescription_drugs_prescription_id_idx
  on public.prescription_drugs (prescription_id);

alter table public.prescription_drugs enable row level security;

drop policy if exists "Doctors manage their own prescription drugs" on public.prescription_drugs;
create policy "Doctors manage their own prescription drugs"
  on public.prescription_drugs
  for all
  using ((select auth.uid()) = doctor_id)
  with check ((select auth.uid()) = doctor_id);

-- ── keep updated_at fresh ────────────────────────────────────────────────
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_updated_at on public.doctors;
create trigger set_updated_at before update on public.doctors
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.patients;
create trigger set_updated_at before update on public.patients
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.prescriptions;
create trigger set_updated_at before update on public.prescriptions
  for each row execute function public.set_updated_at();

-- ── appointments ────────────────────────────────────────────────────────
-- Mirrors the app's Appointment entity. patient_name is denormalized on
-- purpose (same as prescriptions) so the day list renders without a join
-- and an old appointment still reads correctly if the patient is renamed.
create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.doctors (id) on delete cascade,
  patient_id uuid not null references public.patients (id) on delete cascade,
  patient_name text not null,
  scheduled_at timestamptz not null,
  note text,
  status text not null default 'scheduled'
    check (status in ('scheduled', 'completed', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- The day and week views filter by doctor and time range.
create index if not exists appointments_doctor_id_scheduled_at_idx
  on public.appointments (doctor_id, scheduled_at);
-- Foreign-key index: a patient's Visits tab and the on-delete cascade.
create index if not exists appointments_patient_id_idx
  on public.appointments (patient_id);

alter table public.appointments enable row level security;

drop policy if exists "Doctors manage their own appointments" on public.appointments;
create policy "Doctors manage their own appointments"
  on public.appointments
  for all
  to authenticated
  using ((select auth.uid()) = doctor_id)
  with check ((select auth.uid()) = doctor_id);

drop trigger if exists set_updated_at on public.appointments;
create trigger set_updated_at before update on public.appointments
  for each row execute function public.set_updated_at();

-- ── auto-create a doctors row on signup ─────────────────────────────────
-- So the app never has to special-case "doctor row doesn't exist yet"
-- right after sign-up — it's created the moment auth.users gets a row.
create or replace function public.handle_new_doctor()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.doctors (id) values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_doctor();
