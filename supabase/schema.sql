-- Ejecuta esto en Supabase: Dashboard > SQL Editor > New query > pega y dale "Run"

create table if not exists public.scores (
  id bigint generated always as identity primary key,
  username text not null check (char_length(username) between 1 and 20),
  score integer not null check (score >= 0),
  snake_color text,
  snake_color_name text,
  created_at timestamptz not null default now()
);

-- Si la tabla ya existía de antes (sin estas columnas), esto las agrega sin borrar nada:
alter table public.scores add column if not exists snake_color text;
alter table public.scores add column if not exists snake_color_name text;

create index if not exists scores_score_idx on public.scores (score desc);

alter table public.scores enable row level security;

-- Cualquiera puede leer el ranking
create policy "Public can read scores"
  on public.scores for select
  using (true);

-- Cualquiera puede guardar su puntaje (no hay login, es un juego casual)
create policy "Public can insert scores"
  on public.scores for insert
  with check (true);

-- No se crean políticas de update/delete: quedan bloqueadas por defecto con RLS activo.
