-- =========================================================
-- SPICY STREETWEAR CO. — Datos de ejemplo (opcional)
--
-- Cómo usarlo:
--   1. Corre primero la app Flutter una vez y crea tu cuenta
--      (o créala en Supabase → Authentication → Users → Add user)
--   2. Copia tu User UID desde Authentication → Users
--   3. Reemplaza TODAS las apariciones de 'REPLACE_WITH_YOUR_USER_ID'
--      en este archivo por ese UID (Ctrl+H / buscar y reemplazar)
--   4. Pega y ejecuta este archivo en el SQL Editor de Supabase
-- =========================================================

do $$
declare
  v_owner uuid := 'REPLACE_WITH_YOUR_USER_ID';
  v_sup1 uuid;
  v_sup2 uuid;
  v_p1 uuid; v_p2 uuid; v_p3 uuid; v_p4 uuid; v_p5 uuid; v_p6 uuid; v_p7 uuid; v_p8 uuid;
begin
  -- Proveedores
  insert into public.suppliers (owner_id, name, contact, phone) values
    (v_owner, 'Textiles Norte SA', 'Ana Beltrán', '81 2233 4455') returning id into v_sup1;
  insert into public.suppliers (owner_id, name, contact, phone) values
    (v_owner, 'Estampados Urbanos MX', 'Diego Salas', '55 6677 8899') returning id into v_sup2;

  -- Productos
  insert into public.products (owner_id, name, category, sku, emoji, cost, price, stock, min_stock) values
    (v_owner,'Playera Fractura Negra','Playeras','SPC-001','👕',90,249,48,15) returning id into v_p1;
  insert into public.products (owner_id, name, category, sku, emoji, cost, price, stock, min_stock) values
    (v_owner,'Playera Destello Roja','Playeras','SPC-002','👕',95,259,12,15) returning id into v_p2;
  insert into public.products (owner_id, name, category, sku, emoji, cost, price, stock, min_stock) values
    (v_owner,'Hoodie Actitud Negro','Hoodies','SPC-003','🧥',220,549,26,10) returning id into v_p3;
  insert into public.products (owner_id, name, category, sku, emoji, cost, price, stock, min_stock) values
    (v_owner,'Hoodie Velocidad Rojo','Hoodies','SPC-004','🧥',230,579,4,10) returning id into v_p4;
  insert into public.products (owner_id, name, category, sku, emoji, cost, price, stock, min_stock) values
    (v_owner,'Gorra SPICY Bold','Gorras','SPC-005','🧢',60,189,34,12) returning id into v_p5;
  insert into public.products (owner_id, name, category, sku, emoji, cost, price, stock, min_stock) values
    (v_owner,'Cargo Pants Carbón','Pantalones','SPC-006','👖',260,649,15,10) returning id into v_p6;
  insert into public.products (owner_id, name, category, sku, emoji, cost, price, stock, min_stock) values
    (v_owner,'Tote Bag Sin Filtros','Accesorios','SPC-007','🎒',45,129,20,8) returning id into v_p7;
  insert into public.products (owner_id, name, category, sku, emoji, cost, price, stock, min_stock) values
    (v_owner,'Calcetas Statement (Pack)','Accesorios','SPC-008','🧦',35,99,3,10) returning id into v_p8;

  -- Compra recibida (aumenta historial, no vuelve a tocar stock aquí)
  insert into public.purchases (owner_id, supplier_id, supplier_name, status, total, ordered_at, received_at)
  values (v_owner, v_sup1, 'Textiles Norte SA', 'Recibida', 30*90 + 20*95, current_date - 9, current_date - 7)
  returning id into v_p1; -- reutilizamos la variable solo como contenedor temporal
  insert into public.purchase_items (purchase_id, product_id, product_name, qty, cost) values
    (v_p1, (select id from public.products where owner_id=v_owner and sku='SPC-001'), 'Playera Fractura Negra', 30, 90),
    (v_p1, (select id from public.products where owner_id=v_owner and sku='SPC-002'), 'Playera Destello Roja', 20, 95);

  -- Orden de compra pendiente
  insert into public.purchases (owner_id, supplier_id, supplier_name, status, total, ordered_at)
  values (v_owner, v_sup2, 'Estampados Urbanos MX', 'Pendiente', 25*60, current_date - 2)
  returning id into v_p2;
  insert into public.purchase_items (purchase_id, product_id, product_name, qty, cost) values
    (v_p2, (select id from public.products where owner_id=v_owner and sku='SPC-005'), 'Gorra SPICY Bold', 25, 60);

  -- Gastos de ejemplo (últimos ~13 días)
  insert into public.expenses (owner_id, category, description, amount, expense_date) values
    (v_owner,'Renta','Gasto operativo', 4500, current_date - 12),
    (v_owner,'Nómina','Gasto operativo', 6200, current_date - 10),
    (v_owner,'Maquila/Estampado','Gasto operativo', 1800, current_date - 8),
    (v_owner,'Marketing','Gasto operativo', 900, current_date - 6),
    (v_owner,'Envíos','Gasto operativo', 650, current_date - 4),
    (v_owner,'Renta','Gasto operativo', 1200, current_date - 2);

  -- Ventas de ejemplo usando la función atómica register_sale
  -- (nota: register_sale usa auth.uid(), así que si corres esto desde el
  -- SQL Editor como administrador, insertamos directo en su lugar)
  insert into public.sales (owner_id, sold_at, payment_method, total) values
    (v_owner, current_date - 1, 'Efectivo', 249) returning id into v_p3;
  insert into public.sale_items (sale_id, product_id, product_name, qty, price) values
    (v_p3, (select id from public.products where owner_id=v_owner and sku='SPC-001'), 'Playera Fractura Negra', 1, 249);

  insert into public.sales (owner_id, sold_at, payment_method, total) values
    (v_owner, current_date - 1, 'Tarjeta', 549+189) returning id into v_p4;
  insert into public.sale_items (sale_id, product_id, product_name, qty, price) values
    (v_p4, (select id from public.products where owner_id=v_owner and sku='SPC-003'), 'Hoodie Actitud Negro', 1, 549),
    (v_p4, (select id from public.products where owner_id=v_owner and sku='SPC-005'), 'Gorra SPICY Bold', 1, 189);

  insert into public.sales (owner_id, sold_at, payment_method, total) values
    (v_owner, current_date - 3, 'Transferencia', 129) returning id into v_p5;
  insert into public.sale_items (sale_id, product_id, product_name, qty, price) values
    (v_p5, (select id from public.products where owner_id=v_owner and sku='SPC-007'), 'Tote Bag Sin Filtros', 1, 129);

  raise notice 'Datos de ejemplo insertados correctamente para el usuario %', v_owner;
end $$;
