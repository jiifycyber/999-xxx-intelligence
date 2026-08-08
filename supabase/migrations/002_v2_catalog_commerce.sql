
create extension if not exists pg_trgm;

alter table content_submissions add column if not exists category text not null default 'Other';
alter table content_submissions add column if not exists thumbnail_url text;
alter table content_submissions add column if not exists playback_url text;
alter table content_submissions add column if not exists views bigint not null default 0;
alter table content_submissions add column if not exists rating numeric(3,2) not null default 0;
alter table content_submissions add column if not exists published_at timestamptz;

create table if not exists favorites(
  user_id uuid not null,
  content_id uuid references content_submissions(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id,content_id)
);

create table if not exists view_history(
  user_id uuid not null,
  content_id uuid references content_submissions(id) on delete cascade,
  viewed_at timestamptz not null default now(),
  progress_seconds integer not null default 0,
  primary key(user_id,content_id)
);

create table if not exists playlists(
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists playlist_items(
  playlist_id uuid references playlists(id) on delete cascade,
  content_id uuid references content_submissions(id) on delete cascade,
  position integer not null default 0,
  primary key(playlist_id,content_id)
);

create table if not exists subscriptions(
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  creator_id uuid references creator_profiles(id) on delete cascade,
  provider text,
  provider_subscription_id text,
  status text not null default 'pending',
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists purchases(
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  content_id uuid references content_submissions(id) on delete restrict,
  provider text,
  provider_payment_id text,
  amount_cents integer not null default 0,
  currency text not null default 'USD',
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table if not exists creator_payout_ledger(
  id uuid primary key default gen_random_uuid(),
  creator_id uuid references creator_profiles(id) on delete cascade,
  source_type text not null,
  source_id text,
  amount_cents integer not null,
  currency text not null default 'USD',
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create index if not exists idx_content_title_trgm on content_submissions using gin (title gin_trgm_ops);
create index if not exists idx_content_category on content_submissions(category);
create index if not exists idx_content_publish on content_submissions(publish_status,published_at desc);

create or replace view catalog_public as
select
  c.id,c.title,c.creator_id,p.display_name as creator_name,c.category,
  c.thumbnail_url,c.playback_url,c.views,c.rating,c.created_at,c.published_at
from content_submissions c
join creator_profiles p on p.id=c.creator_id
where c.publish_status='published'
  and c.rights_status='approved'
  and c.moderation_status='approved';

create or replace function can_publish_content(p_content_id uuid)
returns boolean language sql stable as $$
  select exists(
    select 1
    from content_submissions c
    where c.id=p_content_id
      and c.rights_status='approved'
      and c.moderation_status='approved'
      and exists (
        select 1 from creator_profiles cp
        where cp.id=c.creator_id and cp.verification_status='approved'
      )
      and not exists (
        select 1
        from content_performers x
        join performer_verifications pv on pv.id=x.verification_id
        where x.content_id=c.id
          and (x.consent_status<>'approved' or pv.status<>'approved')
      )
  );
$$;

create or replace function publish_content(p_content_id uuid)
returns void language plpgsql security definer as $$
begin
  if not can_publish_content(p_content_id) then
    raise exception 'Publishing gates not satisfied';
  end if;
  update content_submissions
  set publish_status='published', published_at=now()
  where id=p_content_id;
end $$;
