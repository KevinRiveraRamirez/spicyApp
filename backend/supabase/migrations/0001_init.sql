-- =========================================================
-- SPICY STREETWEAR CO. — Esquema inicial (Supabase / Postgres)
-- App de administración para el dueño: inventario, compras,
-- ventas y finanzas.
--
-- Cómo usarlo:
--   1. Crea un proyecto gratuito en https://supabase.com
--   2. Ve a "SQL Editor" en el panel de Supabase
--   3. Pega y ejecuta este archivo completo
--   4. Luego ejecuta backend/supabase/seed/seed_data.sql (opcional,
--      datos de ejemplo para probar la app de inmediato)
-- =========================================================

create extension if not exists "uuid-ossp";

-- ---------------------------------------------------------
-- PERFIL DEL NEGOCIO (uno por usuario dueño autenticado)
-- ---------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  biz_name text not null default 'SPICY',
  owner_name text,
  currency text not null default 'MXN',
  dark_mode boolean not null default false,
  pin_hash text,                -- hash del PIN de 4 dígitos para bloqueo rápido en el dispositivo
  auto_lock_minutes int not null default 5,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------
-- PROVEEDORES
-- ---------------------------------------------------------
create table if not exists public.suppliers (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  contact text,
  phone text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------
-- PRODUCTOS / INVENTARIO
-- ---------------------------------------------------------
create table if not exists public.products (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  category text not null default 'Otro',
  sku text not null,
  emoji text default '📦',
  cost numeric(12,2) not null default 0,
  price numeric(12,2) not null default 0,
  stock int not null default 0,
  min_stock int not null default 5,
  unit text not null default 'pza',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, sku)
);
create index if not exists idx_products_owner on public.products (owner_id);
create index if not exists idx_products_category on public.products (owner_id, category);

-- ---------------------------------------------------------
-- VENTAS
-- ---------------------------------------------------------
create table if not exists public.sales (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  sold_at date not null default current_date,
  payment_method text not null default 'Efectivo',
  total numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists idx_sales_owner_date on public.sales (owner_id, sold_at);

create table if not exists public.sale_items (
  id uuid primary key default uuid_generate_v4(),
  sale_id uuid not null references public.sales (id) on delete cascade,
  product_id uuid references public.products (id) on delete set null,
  product_name text not null,   -- snapshot del nombre al momento de la venta
  qty int not null check (qty > 0),
  price numeric(12,2) not null
);
create index if not exists idx_sale_items_sale on public.sale_items (sale_id);

-- ---------------------------------------------------------
-- COMPRAS
-- ---------------------------------------------------------
create table if not exists public.purchases (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  supplier_id uuid references public.suppliers (id) on delete set null,
  supplier_name text not null,  -- snapshot
  status text not null default 'Pendiente' check (status in ('Pendiente','Recibida')),
  total numeric(12,2) not null default 0,
  ordered_at date not null default current_date,
  received_at date,
  created_at timestamptz not null default now()
);
create index if not exists idx_purchases_owner on public.purchases (owner_id);

create table if not exists public.purchase_items (
  id uuid primary key default uuid_generate_v4(),
  purchase_id uuid not null references public.purchases (id) on delete cascade,
  product_id uuid references public.products (id) on delete set null,
  product_name text not null,
  qty int not null check (qty > 0),
  cost numeric(12,2) not null
);
create index if not exists idx_purchase_items_purchase on public.purchase_items (purchase_id);

-- ---------------------------------------------------------
-- GASTOS
-- ---------------------------------------------------------
create table if not exists public.expenses (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  category text not null default 'Otro',
  description text,
  amount numeric(12,2) not null check (amount > 0),
  expense_date date not null default current_date,
  created_at timestamptz not null default now()
);
create index if not exists idx_expenses_owner_date on public.expenses (owner_id, expense_date);

-- =========================================================
-- SEGURIDAD: ROW LEVEL SECURITY
-- Cada dueño solo puede ver y modificar sus propios datos.
-- =========================================================
alter table public.profiles enable row level security;
alter table public.suppliers enable row level security;
alter table public.products enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.purchases enable row level security;
alter table public.purchase_items enable row level security;
alter table public.expenses enable row level security;

-- profiles: solo el propio usuario
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

-- tablas con owner_id: CRUD solo sobre filas propias
create policy "suppliers_all_own" on public.suppliers for all
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "products_all_own" on public.products for all
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "sales_all_own" on public.sales for all
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "purchases_all_own" on public.purchases for all
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "expenses_all_own" on public.expenses for all
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

-- sale_items / purchase_items: se autorizan a través de la venta/compra dueña
create policy "sale_items_all_own" on public.sale_items for all
  using (exists (select 1 from public.sales s where s.id = sale_id and s.owner_id = auth.uid()))
  with check (exists (select 1 from public.sales s where s.id = sale_id and s.owner_id = auth.uid()));

create policy "purchase_items_all_own" on public.purchase_items for all
  using (exists (select 1 from public.purchases p where p.id = purchase_id and p.owner_id = auth.uid()))
  with check (exists (select 1 from public.purchases p where p.id = purchase_id and p.owner_id = auth.uid()));

-- =========================================================
-- TRIGGERS: updated_at automático
-- =========================================================
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_products_updated_at on public.products;
create trigger trg_products_updated_at before update on public.products
  for each row execute function public.set_updated_at();

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

-- Crea automáticamente un perfil cuando alguien se registra
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, biz_name) values (new.id, 'SPICY');
  return new;
end;
$$;

drop trigger if exists trg_on_auth_user_created on auth.users;
create trigger trg_on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- =========================================================
-- FUNCIONES RPC: operaciones atómicas de negocio
-- Se llaman desde Flutter con supabase.rpc(...) para evitar
-- condiciones de carrera (ej. dos ventas descontando el mismo
-- stock al mismo tiempo).
-- =========================================================

-- Registra una venta completa y descuenta stock de forma atómica.
-- items: jsonb array de {"product_id": uuid, "qty": int}
create or replace function public.register_sale(
  p_items jsonb,
  p_payment_method text default 'Efectivo'
)
returns uuid
language plpgsql security definer as $$
declare
  v_owner uuid := auth.uid();
  v_sale_id uuid;
  v_total numeric(12,2) := 0;
  v_item jsonb;
  v_product record;
  v_qty int;
begin
  if v_owner is null then
    raise exception 'No autenticado';
  end if;

  if jsonb_array_length(p_items) = 0 then
    raise exception 'La venta necesita al menos un artículo';
  end if;

  insert into public.sales (owner_id, payment_method, total)
  values (v_owner, p_payment_method, 0)
  returning id into v_sale_id;

  for v_item in select * from jsonb_array_elements(p_items) loop
    v_qty := (v_item->>'qty')::int;

    select * into v_product from public.products
      where id = (v_item->>'product_id')::uuid and owner_id = v_owner
      for update; -- bloquea la fila para evitar condiciones de carrera

    if v_product is null then
      raise exception 'Producto no encontrado';
    end if;
    if v_product.stock < v_qty then
      raise exception 'Stock insuficiente para %', v_product.name;
    end if;

    insert into public.sale_items (sale_id, product_id, product_name, qty, price)
    values (v_sale_id, v_product.id, v_product.name, v_qty, v_product.price);

    update public.products set stock = stock - v_qty where id = v_product.id;

    v_total := v_total + (v_qty * v_product.price);
  end loop;

  update public.sales set total = v_total where id = v_sale_id;
  return v_sale_id;
end;
$$;

-- Marca una orden de compra como recibida y suma el stock de forma atómica.
create or replace function public.receive_purchase(p_purchase_id uuid)
returns void
language plpgsql security definer as $$
declare
  v_owner uuid := auth.uid();
  v_item record;
begin
  if not exists (select 1 from public.purchases where id = p_purchase_id and owner_id = v_owner) then
    raise exception 'Orden de compra no encontrada';
  end if;

  for v_item in select * from public.purchase_items where purchase_id = p_purchase_id loop
    if v_item.product_id is not null then
      update public.products set stock = stock + v_item.qty where id = v_item.product_id and owner_id = v_owner;
    end if;
  end loop;

  update public.purchases set status = 'Recibida', received_at = current_date where id = p_purchase_id;
end;
$$;
