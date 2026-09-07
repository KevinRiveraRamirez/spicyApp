<div align="center">

# SPICY Admin

**App de administración para SPICY Streetwear Co.**

Inventario · Punto de venta · Compras · Finanzas — una sola base de código en Flutter, web y Android, con Supabase como backend.

[![Flutter](https://img.shields.io/badge/Flutter-web%20%2B%20android-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Firebase Hosting](https://img.shields.io/badge/Hosting-Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)
![Identidad](https://img.shields.io/badge/Identidad-Tech--Speed%202026-003BFD)

</div>

---

Los datos viven en un proyecto propio de Supabase (Postgres administrado), protegidos con seguridad a nivel de fila (RLS) — sin terceros, sin filtros.

## Índice

- [Identidad visual — Tech-Speed 2026](#identidad-visual--tech-speed-2026)
- [Módulos](#módulos)
- [Stack técnico](#stack-técnico)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Base de datos](#base-de-datos)
- [Puesta en marcha](#puesta-en-marcha)
- [Despliegue](#despliegue)
- [Seguridad](#seguridad)

## Identidad visual — Tech-Speed 2026

La app pasó por un rediseño completo: nueva identidad **"SPICY Tech-Speed"**, tipografía Inter, navegación responsiva de verdad (no un layout de escritorio encogido) y una librería propia de ~15 componentes reutilizables que mantiene todas las pantallas consistentes.

| Token | Valor | Uso |
|---|---|---|
| Azul de marca | `#003BFD` | Acciones primarias, estado activo de navegación, enlaces |
| Fondo | `#F5F7FB` (claro) / `#090D16` (oscuro) | Base de cada pantalla |
| Superficie | `#FFFFFF` (claro) / `#111827` (oscuro) | Tarjetas, hojas, diálogos |
| Borde | `#E4E7EC` (claro) / `#273449` (oscuro) | Separadores sutiles |
| Éxito / Alerta / Peligro / Info | verde / naranja / rojo / azul | Solo para estado, nunca para marca |

Todo vive en `frontend/lib/core/theme/` (`app_colors.dart`, `app_spacing.dart`, `app_text.dart`, `app_theme.dart`) como `ThemeExtension`, con variante clara y oscura resueltas automáticamente vía `context.colors`.

**Navegación, según el ancho de pantalla — nunca dos formas a la vez:**

| Ancho | Navegación | Acción principal |
|---|---|---|
| < 600 dp (teléfono) | Barra inferior de 5 destinos | FAB extendido con etiqueta |
| 600–1023 dp (tablet) | `NavigationRail` compacto | FAB extendido con etiquea |
| ≥ 1024 dp (escritorio) | Sidebar colapsable (220 dp ↔ 80 dp) | Botón en el encabezado de contenido |

En cualquier ancho, si una sección está vacía el único CTA visible es el del estado vacío en contexto ("Registrar primera venta", "Agregar primer producto"...); el FAB o el botón de encabezado reaparece automáticamente en cuanto hay datos — nunca dos controles para la misma acción.

## Módulos

**Inicio** — Saludo contextual con fecha, KPIs clave (ventas de hoy, utilidad a 30 días, inventario en alerta, compras en tránsito) en grilla 2×2 en móvil / fila en escritorio, accesos rápidos a las acciones más frecuentes, tendencia de ventas de 14 días y alertas de inventario accionables.

**Inventario** — Productos organizados en 6 categorías fijas del negocio. Estado de stock en 3 niveles (disponible / poco stock / agotado) según un mínimo configurable por producto, búsqueda y filtro por categoría, alta/edición de productos.

**Ventas (punto de venta)** — Carrito de venta con flujo por pasos, métodos de pago (Efectivo, Sinpe, Transferencia), montos en colones (CRC), hora exacta de Costa Rica en cada venta. Descuenta stock de forma atómica vía función RPC (`register_sale`) para evitar condiciones de carrera si hay dos ventas simultáneas.

**Compras** — Flujo de 3 estados (Pedido → En tránsito → Recibida) que refleja el proceso real de importar desde China, con filtro rápido por estado. Cada proveedor tiene un origen (China / Estados Unidos / Costa Rica): las órdenes a proveedores extranjeros se registran en dólares con tipo de cambio, las de Costa Rica van directo en colones. Proveedores con link de referencia (Alibaba, WhatsApp, sitio web) y opción de borrado. Al marcar una orden como recibida, el stock se suma de forma atómica vía RPC (`receive_purchase`).

**Finanzas** — Movimientos de ventas y compras sincronizados automáticamente, más gastos manuales ("otros gastos") por categoría. Gráfico de ingresos vs. egresos con rango configurable (6 / 12 semanas), filtros por tipo y periodo.

**Ajustes** — Organizados por sección: Seguridad (cambiar PIN, bloquear ahora), Apariencia (modo oscuro), Datos (exportar respaldo), Aplicación (descarga del APK de Android, solo en la versión web) y Sesión (cerrar sesión, con confirmación).

**Acceso** — Pantalla de bloqueo con PIN de 4 dígitos y biometría (huella / Face ID vía `local_auth`).

## Stack técnico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (web + Android), un solo código fuente |
| Estado | Provider (`ChangeNotifier`) |
| Backend | Supabase (Postgres, Auth, RLS, funciones RPC) |
| Gráficos | fl_chart |
| Tipografía | Inter vía `google_fonts` |
| Seguridad local | `local_auth` (biometría), `flutter_secure_storage` (PIN), `crypto` |
| Íconos de app | `flutter_launcher_icons`, regenerados en cada build de CI |
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
    ├── assets/images/       # wordmark y monograma (azul y blanco), ícono de app
    ├── lib/
    │   ├── core/
    │   │   ├── theme/       # app_colors, app_spacing, app_text, app_theme
    │   │   └── utils/       # formatters, métricas, íconos de categoría
    │   ├── features/        # una carpeta por módulo (dashboard, inventory,
    │   │                    # sales, purchases, finance, settings, auth, shell)
    │   ├── models/          # modelos de datos (product, sale, purchase, supplier, expense)
    │   ├── services/        # capa de acceso a Supabase, una por entidad
    │   ├── state/           # AppState (estado global compartido vía Provider)
    │   └── widgets/         # librería de componentes: SpicyNavigation, SpicyTopBar,
    │                        # MetricCard, ActionCard, EmptyState, ContentCard,
    │                        # SpicyBottomSheet, ConfirmDialog, StatusChip, etc.
    ├── web/                 # manifest, íconos e index.html de la PWA
    ├── deploy_web.ps1       # despliegue manual a Firebase Hosting (Windows)
    └── pubspec.yaml
```

Cada módulo bajo `features/` sigue el mismo patrón: una pantalla principal, sus widgets propios en una subcarpeta, y los componentes compartidos de `widgets/` (`SpicyScreen`, `ContentCard`, `EmptyState`...) para mantener la identidad visual consistente en las 5 pestañas.

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

El rediseño visual **no tocó el esquema**: mismas tablas, mismas RPC, mismas migraciones.

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

1. `flutter pub get`
2. Regenera los íconos nativos de la app (`flutter_launcher_icons`) a partir de los assets de marca.
3. **Web** → compila y publica en Firebase Hosting.
4. **Android** → compila un APK release firmado con la llave de producción y lo sube como GitHub Release con tag `latest` (el link de descarga en Ajustes siempre apunta a ese tag, nunca hay que actualizarlo a mano).

> La app instalada en el teléfono **no se autoactualiza**: cada deploy sube un APK nuevo al mismo link, pero hay que volver a descargarlo e instalarlo manualmente. La versión web sí queda al día sola en cada deploy.

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

---

<div align="center">

Hecho para **SPICY Streetwear Co.** — sin terceros, sin filtros.

</div>
