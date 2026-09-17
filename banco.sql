-- =========================================================
-- Meu fluxo de caixa — estrutura do banco
-- Rode isto no Supabase: SQL Editor > New query > Run
-- Pode rodar mais de uma vez sem problema.
-- =========================================================

-- 1) Tabela de lançamentos ---------------------------------
create table if not exists public.transactions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid()
              references auth.users(id) on delete cascade,
  date        date not null,
  description text not null default '',
  category    text not null,
  type        text not null check (type in ('entrada','saida')),
  amount      numeric(12,2) not null check (amount > 0),
  created_at  timestamptz not null default now()
);

-- 2) Índice para busca rápida por mês ----------------------
create index if not exists transactions_user_date_idx
  on public.transactions (user_id, date desc);

-- 3) Segurança: cada pessoa só enxerga o que é dela --------
alter table public.transactions enable row level security;

drop policy if exists "ver os proprios lancamentos"      on public.transactions;
drop policy if exists "inserir os proprios lancamentos"  on public.transactions;
drop policy if exists "alterar os proprios lancamentos"  on public.transactions;
drop policy if exists "excluir os proprios lancamentos"  on public.transactions;

create policy "ver os proprios lancamentos"
  on public.transactions for select
  to authenticated
  using (auth.uid() = user_id);

create policy "inserir os proprios lancamentos"
  on public.transactions for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "alterar os proprios lancamentos"
  on public.transactions for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "excluir os proprios lancamentos"
  on public.transactions for delete
  to authenticated
  using (auth.uid() = user_id);

-- =========================================================
-- Pronto. Não precisa criar tabela de usuários:
-- o Supabase já cria e gerencia auth.users sozinho.
--
-- Conferir depois (opcional):
--   select * from public.transactions;
-- =========================================================
