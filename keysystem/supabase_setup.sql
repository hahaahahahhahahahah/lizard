-- ============================================================
-- Lizard key/license system - Supabase setup
-- 1) Run this in Supabase Dashboard > SQL Editor > New query
-- 2) Then set the script body (obfuscated main script) on row id='main'
-- ============================================================

-- Licenses: one key bound to one Roblox UserId (anti-sharing)
create table if not exists public.licenses (
    key        text primary key,
    userid     bigint not null,
    expires_at timestamptz,
    created_at timestamptz not null default now(),
    note       text
);

alter table public.licenses enable row level security;

-- Block ALL direct reads/writes from the client (anon role).
-- Only the server function below can see the keys, so the list stays private.
drop policy if exists "licenses_anon_block" on public.licenses;
create policy "licenses_anon_block" on public.licenses
    for all using (false) with check (false);

-- Scripts: holds the obfuscated main script. Never fetched directly.
create table if not exists public.scripts (
    id   text primary key,
    body text
);

insert into public.scripts (id, body)
values ('main', '-- script body goes here (obfuscated)')
on conflict (id) do nothing;

alter table public.scripts enable row level security;

drop policy if exists "scripts_anon_block" on public.scripts;
create policy "scripts_anon_block" on public.scripts
    for all using (false) with check (false);

-- ============================================================
-- get_script: THE ONLY thing the Roblox client can call.
-- Checks key + userid + expiry server-side, returns the code
-- only if the license is valid. Keys are never exposed.
-- ============================================================
create or replace function public.get_script(p_key text, p_userid bigint)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
    v_row  public.licenses%rowtype;
    v_body text;
begin
    select * into v_row
    from public.licenses
    where key = p_key
      and userid = p_userid
      and (expires_at is null or expires_at > now())
    limit 1;

    if not found then
        raise exception 'invalid_license';
    end if;

    select body into v_body from public.scripts where id = 'main';
    return v_body;
end;
$$;

-- Allow clients to call ONLY this function.
revoke execute on function public.get_script(text, bigint) from public, anon, authenticated;
grant execute on function public.get_script(text, bigint) to anon;
