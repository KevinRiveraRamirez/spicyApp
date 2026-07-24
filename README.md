<div align="center">

# 🔥 SPICY Streetwear Co. — App de Administración

**Inventario · Punto de venta · Compras · Finanzas**
App móvil privada para la gestión integral del negocio, construida con Flutter y Supabase.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Postgres%20%2B%20Auth-3ECF8E?logo=supabase&logoColor=white)
![Platform](https://img.shields.io/badge/Plataforma-iOS%20%7C%20Android%20%7C%20Web-333333)
![License](https://img.shields.io/badge/Uso-Privado-red)

</div>


## Índice

- [Módulos](#módulos)
- [Stack técnico](#stack-técnico)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Base de datos](#base-de-datos)
- [Puesta en marcha](#puesta-en-marcha)
- [Despliegue](#despliegue)
- [Seguridad](#seguridad)
- [Identidad de marca](#identidad-de-marca)

## Módulos

**Dashboard** — KPIs del negocio (ventas, ganancia, órdenes), alertas de stock agotado por producto y por categoría completa, top de productos, gráfico de tendencia de ventas, accesos rápidos a los otros módulos.

**Inventario** — Productos organizados en 6 categorías fijas del negocio. Modelo de stock simple (agotado / disponible), búsqueda y filtro por categoría, alta/edición de productos.

**Ventas (punto de venta)** — Carrito de venta, métodos de pago (Efectivo, Sinpe, Transferencia), montos en colones (CRC), hora exacta de Costa Rica en cada venta. Descuenta stock de forma atómica vía función RPC (`register_sale`) para evitar condiciones de carrera si hay dos ventas simultáneas.

**Compras** — Flujo de 3 estados (Pedido → En tránsito → Recibida) que refleja el proceso real de importar desde China. Cada proveedor tiene un origen (China / Estados Unidos / Costa Rica): las órdenes a proveedores extranjeros se registran en dólares con tipo de cambio, las de Costa Rica van directo en colones. Proveedores con link de referencia (Alibaba, WhatsApp, sitio web) y opción de borrado. Al marcar una orden como recibida, el stock se suma de forma atómica vía RPC (`receive_purchase`).

**Finanzas** — Movimientos de ventas y compras sincronizados automáticamente, más gastos manuales ("otros gastos") por categoría. KPIs con color según signo (ingreso/egreso), gráfico de ingresos vs. egresos.

**Ajustes** — Cambio de PIN, modo oscuro, exportar respaldo de datos, descarga del APK de Android (solo en la versión web), bloqueo manual, cerrar sesión.

**Acceso** — Pantalla de bloqueo con PIN de 4 dígitos y biometría (huella / Face ID vía `local_auth`).

## Stack técnico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (web + Android), un solo código fuente |
| Estado | Provider (`ChangeNotifier`) |
| Backend | Supabase (Postgres, Auth, RLS, funciones RPC) |
| Gráficos | fl_chart |
| Seguridad local | `local_auth` (biometría), `flutter_secure_storage` (PIN), `crypto` |
| Tipografía / fuentes | google_fonts |
| CI/CD | GitHub Actions |
| Hosting web | Firebase Hosting |
| Distribución Android | GitHub Releases (APK firmado, publicado automáticamente) |

## Estructura del proyecto

```
spicy-admin-app/
├── backend/supabase/
│   ├── migrations/        # 0001–0005, en orden, corridas una sola vez cada una
│   └── seed/               # datos de ejemplo y script de limpieza
└── frontend/
    ├── android/             # proyecto Android nativo (firma, manifest)
    ├── lib/
    │   ├── core/            # config, tema, utilidades (formatters, métricas)
    │   ├── features/        # una carpeta por módulo (dashboard, inventory,
    │   │                    # sales, purchases, finance, settings, auth, shell)
    │   ├── models/          # modelos de datos (product, sale, purchase, supplier, expense)
    │   ├── services/        # capa de acceso a Supabase, una por entidad
    │   ├── state/           # AppState (estado global compartido vía Provider)
    │   └── widgets/         # componentes reusables (BrandScreen, BrandCard, etc.)
    ├── deploy_web.ps1       # despliegue manual a Firebase Hosting (Windows)
    └── pubspec.yaml
```

Cada módulo bajo `features/` sigue el mismo patrón: una pantalla principal, sus widgets propios en una subcarpeta, y un `BrandScreen`/`BrandCard` compartido para mantener la identidad visual consistente en las 5 pestañas.

## Base de datos

Tablas: `profiles`, `suppliers`, `products`, `sales` + `sale_items`, `purchases` + `purchase_items`, `expenses`. Todas con Row Level Security: cada fila pertenece a un `owner_id` y solo el dueño autenticado puede leerla o modificarla.

Dos funciones RPC hacen las operaciones de negocio críticas de forma atómica (con bloqueo de fila, `for update`) para que no se descuadren con uso concurrente:

- `register_sale(items, payment_method)` — crea la venta, sus líneas, y descuenta stock.
- `receive_purchase(purchase_id)` — marca la compra como recibida y suma el stock.

Migraciones, en orden (`backend/supabase/migrations/`):

1. `0001_init.sql` — esquema completo inicial, RLS, triggers, funciones RPC.
2. `0002_sales_timestamp.sql` — `sales.sold_at` pasa de fecha a fecha+hora exacta.
3. `0003_purchases_status_usd.sql` — flujo de 3 estados en compras, columnas de dólares y tipo de cambio.
4. `0004_suppliers_link.sql` — campo de link en proveedores.
5. `0005_supplier_origin_currency.sql` — origen del proveedor y moneda por orden de compra.

## Puesta en marcha

**1. Backend (Supabase)**

1. Crear un proyecto gratuito en [supabase.com](https://supabase.com).
2. En el SQL Editor, correr las 5 migraciones de `backend/supabase/migrations/` **en orden**.
3. Opcional: correr `backend/supabase/seed/seed_data.sql` para datos de ejemplo. `clean_data.sql` borra todo lo cargado de prueba (irreversible) cuando esté listo para usar la app con datos reales.
4. Copiar la URL del proyecto y la `anon key` desde Project Settings → API.

**2. Frontend (Flutter)**

Requiere Flutter SDK (canal stable) y, para compilar Android, JDK 17.

```bash
cd frontend
flutter pub get

flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu_anon_key
```

Si corrés sin esas variables, la app muestra una pantalla de aviso en vez de fallar en silencio. Para VS Code, copiar `frontend/.vscode/launch.json` y completar ahí la URL y la key — así queda guardado para cada sesión de debug.

## Despliegue

Automático en cada push a `main` (`.github/workflows/firebase-hosting-merge.yml`):

- **Web** → compila y publica en Firebase Hosting.
- **Android** → compila un APK release firmado con la llave de producción y lo sube como GitHub Release con tag `latest` (el link de descarga en Ajustes siempre apunta a ese tag, nunca hay que actualizarlo a mano).

Secrets requeridos en GitHub (Settings → Secrets and variables → Actions): `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`, `FIREBASE_SERVICE_ACCOUNT_SPICY_ADMIN_F61A1`.

Despliegue manual de la web (sin pasar por CI), desde `frontend/`:

```powershell
.\deploy_web.ps1
```

## Seguridad

- Row Level Security en todas las tablas — sin RLS no hay acceso, cada dueño ve solo lo suyo.
- PIN de 4 dígitos + biometría para desbloquear la app en el dispositivo (no reemplaza el login de Supabase, es una capa extra local).
- Llave de firma de Android (`key.properties`, `release.jks`) excluida de git; en CI se reconstruye desde un secret en base64.
- Nunca se hardcodean credenciales de Supabase en el código — se inyectan en build time vía `--dart-define`.

## Identidad de marca

Paleta oficial (manual de marca 2026): rojo `#E4131A`, negro `#111111` y blanco como base — proporción 60% rojo/negro, 30% blanco, 10% hueso/gris asfalto. Definida en `frontend/lib/core/theme/app_colors.dart`, con variantes de tema claro y oscuro.