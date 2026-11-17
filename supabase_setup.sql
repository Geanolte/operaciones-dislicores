-- Operaciones Dislicores · tablas de PRUEBA para listas y resultados compartidos entre celulares
-- Ejecutar UNA VEZ en Supabase → SQL Editor (mismo proyecto de Semáforos).
-- IMPORTANTE: reglas abiertas para pruebas. Usar SOLO datos ficticios hasta tener inicio de sesión real.

-- 1) Listas de trabajo que publica el supervisor (una por operario o por vehículo)
create table if not exists public.ops_listas (
  id          text primary key,              -- "<sesión>|<operario o placa>"
  tipo        text not null,                 -- 'alist' (alistamiento) o 'desp' (despacho)
  sid         text not null,                 -- código de la sesión o planilla
  nom         text not null,                 -- operario o placa
  titulo      text,
  fecha       date not null default current_date,
  items       jsonb not null default '[]',   -- [[ref, descripción, barras, empaque, total, grupo, línea], ...]
  actualizado timestamptz not null default now()
);

-- 2) Avance que envía cada operario, línea por línea
create table if not exists public.ops_res (
  id    text primary key,                    -- igual al id de la lista
  tipo  text not null,
  sid   text not null,
  nom   text not null,
  e     jsonb not null default '[]',         -- [[ref, estado, cantidad hecha, escaneado], ...]
  ts    timestamptz not null default now()
);

create index if not exists ops_listas_fecha_idx on public.ops_listas (fecha desc);
create index if not exists ops_listas_sid_idx   on public.ops_listas (sid);
create index if not exists ops_res_sid_idx      on public.ops_res (sid);

-- 3) Seguridad por filas: activada, con políticas abiertas SOLO PARA PRUEBAS (prefijo "prueba_")
alter table public.ops_listas enable row level security;
alter table public.ops_res    enable row level security;

drop policy if exists prueba_listas_leer   on public.ops_listas;
drop policy if exists prueba_listas_crear  on public.ops_listas;
drop policy if exists prueba_listas_editar on public.ops_listas;
drop policy if exists prueba_listas_borrar on public.ops_listas;
create policy prueba_listas_leer   on public.ops_listas for select to anon using (true);
create policy prueba_listas_crear  on public.ops_listas for insert to anon with check (true);
create policy prueba_listas_editar on public.ops_listas for update to anon using (true) with check (true);
create policy prueba_listas_borrar on public.ops_listas for delete to anon using (true);

drop policy if exists prueba_res_leer   on public.ops_res;
drop policy if exists prueba_res_crear  on public.ops_res;
drop policy if exists prueba_res_editar on public.ops_res;
drop policy if exists prueba_res_borrar on public.ops_res;
create policy prueba_res_leer   on public.ops_res for select to anon using (true);
create policy prueba_res_crear  on public.ops_res for insert to anon with check (true);
create policy prueba_res_editar on public.ops_res for update to anon using (true) with check (true);
create policy prueba_res_borrar on public.ops_res for delete to anon using (true);

grant select, insert, update, delete on public.ops_listas, public.ops_res to anon;

-- 4) Limpieza opcional de pruebas viejas (se ejecuta a mano desde el SQL Editor: select public.ops_limpiar(7);)
create or replace function public.ops_limpiar(dias int default 7)
returns void language sql security definer set search_path = public as $$
  delete from public.ops_listas where actualizado < now() - make_interval(days => dias);
  delete from public.ops_res    where ts          < now() - make_interval(days => dias);
$$;
revoke all on function public.ops_limpiar(int) from public, anon, authenticated;

-- Para cerrar las pruebas más adelante: borrar las políticas "prueba_*" y crear políticas por rol
-- cuando exista inicio de sesión real (Microsoft 365).
