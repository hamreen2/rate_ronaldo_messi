-- Rate Cristiano Ronaldo and Lionel Messi.
-- Run in the Supabase SQL Editor (project class-wall, shared by all groups).

create table if not exists public.player_feedback (
  id          bigint generated always as identity primary key,
  player      text not null check (player in ('Cristiano Ronaldo', 'Lionel Messi')),
  name        text check (char_length(name) <= 40),
  comment     text check (char_length(comment) <= 280),
  rating      int  not null check (rating between 1 and 5),
  created_at  timestamptz not null default now()
);

-- Row Level Security: the public key may only READ and INSERT. No update, no delete.
alter table public.player_feedback enable row level security;

create policy "anyone can read"  on public.player_feedback for select to anon using (true);
create policy "anyone can post"  on public.player_feedback for insert to anon with check (true);

-- Realtime: lets the screen update the moment a row is inserted.
alter publication supabase_realtime add table public.player_feedback;
