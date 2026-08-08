-- 999XXX core schema foundation
create extension if not exists pgcrypto;

create table if not exists creator_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  display_name text not null,
  verification_status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table if not exists performer_verifications (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid references creator_profiles(id) on delete cascade,
  legal_name text not null,
  date_of_birth date not null,
  provider_reference text,
  status text not null default 'pending',
  verified_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists rights_agreements (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid references creator_profiles(id) on delete cascade,
  agreement_version text not null,
  license_type text not null,
  territory text,
  term_text text,
  signed_at timestamptz,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table if not exists content_submissions (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid references creator_profiles(id) on delete cascade,
  title text not null,
  storage_key text,
  moderation_status text not null default 'pending',
  rights_status text not null default 'pending',
  publish_status text not null default 'blocked',
  created_at timestamptz not null default now()
);

create table if not exists content_performers (
  content_id uuid references content_submissions(id) on delete cascade,
  verification_id uuid references performer_verifications(id) on delete restrict,
  consent_status text not null default 'pending',
  primary key(content_id, verification_id)
);

create table if not exists moderation_reports (
  id uuid primary key default gen_random_uuid(),
  content_id uuid references content_submissions(id) on delete cascade,
  reporter_user_id uuid,
  reason text not null,
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create table if not exists takedown_requests (
  id uuid primary key default gen_random_uuid(),
  content_id uuid references content_submissions(id) on delete cascade,
  requester text not null,
  reason text not null,
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create table if not exists audit_log (
  id bigint generated always as identity primary key,
  actor_user_id uuid,
  action text not null,
  entity_type text not null,
  entity_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
