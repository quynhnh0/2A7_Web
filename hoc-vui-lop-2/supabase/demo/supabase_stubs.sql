-- Giả lập các đối tượng có sẵn của Supabase để chạy migration trên PGlite
-- (chế độ Demo trong trình duyệt và script kiểm thử). KHÔNG chạy file này trên Supabase thật.
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
end $$;

create schema if not exists auth;
create table if not exists auth.users (
  id    uuid primary key,
  email text
);
create or replace function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('demo.uid', true), '')::uuid
$$;
