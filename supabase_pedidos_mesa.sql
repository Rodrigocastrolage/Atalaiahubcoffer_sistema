-- Pedidos feitos pelo cliente via QR Code da mesa.
-- Rode uma vez no Supabase: SQL Editor > New query > colar > Run.

create table if not exists public.pedidos_mesa (
  id        bigint generated always as identity primary key,
  mesa      int          not null,
  cliente   text,
  itens     jsonb        not null default '[]'::jsonb,   -- [{id, nome, qtd, preco}]
  obs       text,
  total     numeric(10,2) not null default 0,
  status    text         not null default 'novo',         -- novo | preparando | entregue | pago | cancelado
  criado_em timestamptz  not null default now()
);

create index if not exists pedidos_mesa_status_idx on public.pedidos_mesa (status);
create index if not exists pedidos_mesa_mesa_idx   on public.pedidos_mesa (mesa);

alter table public.pedidos_mesa enable row level security;

-- O sistema e o cardapio usam a chave anon. O cliente so pode criar pedido "novo";
-- ler e atualizar (mudar status) e usado pelo painel.
drop policy if exists "pedidos_mesa select" on public.pedidos_mesa;
drop policy if exists "pedidos_mesa insert" on public.pedidos_mesa;
drop policy if exists "pedidos_mesa update" on public.pedidos_mesa;

create policy "pedidos_mesa select" on public.pedidos_mesa for select to anon, authenticated using (true);
create policy "pedidos_mesa insert" on public.pedidos_mesa for insert to anon, authenticated
  with check (status = 'novo' and mesa > 0 and jsonb_typeof(itens) = 'array');
create policy "pedidos_mesa update" on public.pedidos_mesa for update to anon, authenticated using (true) with check (true);
