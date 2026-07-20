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

---

## Tabla de contenido

1. [Descripción general](#descripción-general)
2. [Características](#características)
3. [Stack tecnológico](#stack-tecnológico)
4. [Arquitectura](#arquitectura)
5. [Puesta en marcha](#puesta-en-marcha)
   - [Requisitos previos](#1-requisitos-previos)
   - [Backend: Supabase](#2-backend-crear-tu-proyecto-de-supabase)
   - [Frontend: Flutter en VS Code](#3-frontend-preparar-el-proyecto-flutter-en-vs-code)
   - [Conectar y correr la app](#4-conectar-la-app-a-tu-supabase-y-correrla)
   - [Primer uso](#5-primer-uso)
6. [Seguridad](#seguridad)
7. [Estado del proyecto](#estado-del-proyecto)
8. [Roadmap](#roadmap)

---

## Descripción general

SPICY Admin es la aplicación interna para el dueño de **SPICY Streetwear Co.**
Centraliza en un solo lugar la operación diaria de la tienda: qué hay en
bodega, qué se vendió hoy, qué se le debe a los proveedores y cómo va la
utilidad del negocio — todo con la identidad visual de la marca (rojo,
negro y blanco) y pensada primero para iPhone, pero totalmente usable en
tablet y computadora.

Los montos de la app se manejan en **colones costarricenses (₡)**.

## Características

| Módulo | Qué permite hacer |
|---|---|
| **Dashboard** | Ventas del día/semana, utilidad a 30 días, alertas de stock bajo, tendencia de ventas y top de productos, de un vistazo. |
| **Inventario** | Alta, edición y control de stock por SKU, con mínimos y alertas automáticas. |
| **Ventas (POS)** | Registro de ventas por método de pago, con descuento de stock atómico en el servidor. |
| **Compras** | Órdenes a proveedores, recepción de mercancía y actualización de stock al recibir. |
| **Finanzas** | Registro de gastos, utilidad neta y panorama de ingresos vs. egresos. |
| **Acceso** | Correo/contraseña (Supabase Auth) + PIN local de 4 dígitos + biometría (Face ID / huella) para desbloqueos rápidos. |

## Stack tecnológico

- **Frontend:** Flutter (Dart), Material 3, [`provider`](https://pub.dev/packages/provider) para estado global, [`fl_chart`](https://pub.dev/packages/fl_chart) para gráficas, [`google_fonts`](https://pub.dev/packages/google_fonts) (Lato) para tipografía de marca.
- **Backend:** Supabase — Postgres, Auth, Row Level Security y funciones RPC para operaciones atómicas. Sin servidor intermedio: la API REST/RPC la genera Supabase directo desde el esquema.
- **Seguridad local:** `flutter_secure_storage` (PIN cifrado) + `local_auth` (biometría).

## Arquitectura

```
spicy-admin-app/
├── backend/
│   └── supabase/
│       ├── migrations/0001_init.sql   ← esquema completo (tablas + RLS + funciones)
│       └── seed/seed_data.sql         ← datos de ejemplo opcionales (colones)
└── frontend/                          ← proyecto Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── core/        (tema, colores de marca, utilidades/métricas)
    │   ├── models/      (Product, Sale, Purchase, Expense, Supplier)
    │   ├── services/    (llamadas a Supabase, auth, PIN/biometría)
    │   ├── state/       (AppState — estado global con Provider)
    │   ├── features/    (una carpeta por pantalla: auth, dashboard,
    │   │                  inventory, sales, purchases, finance, settings)
    │   └── widgets/      (componentes compartidos: logo, layout responsivo)
    └── pubspec.yaml
```

No usamos un servidor Node/Express intermedio: Supabase genera la API
REST/RPC automáticamente a partir del esquema de Postgres, y la
seguridad se aplica directamente en la base de datos con **Row Level
Security** (cada dueño solo puede ver y modificar sus propios datos).
La lógica de negocio sensible (descontar stock al vender, sumar stock
al recibir una compra) vive en **funciones de Postgres** (`register_sale`,
`receive_purchase`) que se ejecutan de forma atómica en el servidor, no
en el teléfono — así se evitan condiciones de carrera si el dueño vende
desde dos dispositivos a la vez.

## Puesta en marcha

### 1. Requisitos previos

- [VS Code](https://code.visualstudio.com/) con las extensiones **Flutter** y **Dart** (Marketplace)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (`flutter doctor` sin errores)
- Una cuenta gratuita en [supabase.com](https://supabase.com)
- Xcode (para iOS, solo en Mac) y/o Android Studio (para el emulador de Android)

### 2. Backend: crear tu proyecto de Supabase

1. Entra a [supabase.com](https://supabase.com) → **New project**. Elige nombre, contraseña de base de datos y región.
2. Cuando el proyecto esté listo, ve a **SQL Editor** (menú lateral).
3. Abre `backend/supabase/migrations/0001_init.sql` de este repo, copia todo el contenido, pégalo en el SQL Editor y dale **Run**. Esto crea las tablas, la seguridad (RLS) y las funciones de negocio.
4. Ve a **Project Settings → API**. Copia:
   - **Project URL** (algo como `https://xxxxx.supabase.co`)
   - **anon / publishable key**

   Los vas a necesitar en el paso 4.
5. Crea tu usuario dueño desde la propia app (paso 5) o manualmente en **Authentication → Users → Add user**.
6. *(Opcional)* Para probar la app con datos de ejemplo (en colones): abre `backend/supabase/seed/seed_data.sql`, reemplaza `REPLACE_WITH_YOUR_USER_ID` por tu User UID (lo ves en **Authentication → Users**), y ejecútalo en el SQL Editor.

### 3. Frontend: preparar el proyecto Flutter en VS Code

El código fuente (`lib/`, `pubspec.yaml`) ya está listo; solo falta generar
las carpetas nativas (`android/`, `ios/`, etc.). Se hace una sola vez:

1. Abre una terminal en la carpeta `frontend/` de este proyecto.
2. Corre:
   ```bash
   flutter create --org com.spicy --project-name spicy_admin .
   ```
   Esto genera `android/`, `ios/`, `web/`, etc. **sin sobrescribir** tu `lib/` ni tu `pubspec.yaml` existentes. Si te pregunta si sobrescribir algún archivo, responde que **no**.
3. Instala las dependencias:
   ```bash
   flutter pub get
   ```
4. Abre la carpeta `frontend/` en VS Code (`code .`).

**Habilitar biometría (Face ID / huella):**

- **Android** — en `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:
  ```xml
  <uses-permission android:name="android.permission.USE_BIOMETRIC" />
  ```
- **iOS** — en `ios/Runner/Info.plist`:
  ```xml
  <key>NSFaceIDUsageDescription</key>
  <string>Usamos Face ID para desbloquear SPICY Admin rápidamente.</string>
  ```

### 4. Conectar la app a tu Supabase y correrla

Ya existe `frontend/.vscode/launch.json`; solo edítalo y reemplaza los
valores de ejemplo por los tuyos (del paso 2.4):

```json
"args": [
  "--dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co",
  "--dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY_AQUI"
]
```

Luego, en VS Code: abre `lib/main.dart`, ve a **Run and Debug**
(<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>D</kbd>), elige **"SPICY Admin (dev)"**
y presiona ▶. También puedes usar un emulador Android, un simulador de
iOS, o Chrome (Flutter Web) como destino.

Por terminal, en vez del botón ▶:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY_AQUI
```

### 5. Primer uso

1. Al abrir la app por primera vez verás la pantalla de **Crear cuenta**: registra tu correo y contraseña (crea tu usuario en Supabase Auth y tu perfil de negocio automáticamente).
2. La app te pedirá crear un **PIN de 4 dígitos** — tu desbloqueo rápido local, guardado cifrado en el sistema operativo del teléfono (Keychain/Keystore), nunca en texto plano.
3. Si corriste el `seed_data.sql`, ya verás productos, ventas, compras y gastos de ejemplo en colones. Si no, la app empieza vacía y puedes ir creando todo desde los botones **+**.

## Seguridad

- **Row Level Security** en Postgres: cada fila de cada tabla está protegida por una política que exige `owner_id = auth.uid()`; nadie puede leer o modificar datos de otra cuenta aunque conozca la URL de la API.
- **PIN local + biometría**: capa adicional de bloqueo en el propio dispositivo, con auto-bloqueo al mandar la app a segundo plano.
- **Operaciones atómicas en el servidor**: `register_sale` y `receive_purchase` corren dentro de una transacción de Postgres con bloqueo de fila (`FOR UPDATE`), evitando que dos ventas simultáneas dejen el stock en un estado inconsistente.
- **Sin llaves ni secretos en el código**: la URL y la anon/publishable key se inyectan en tiempo de compilación (`--dart-define`), nunca quedan hardcodeadas en el repositorio. La *secret key* de Supabase nunca se usa en el cliente.

## Estado del proyecto

| Pantalla | Estado |
|---|---|
| Acceso (login / PIN / biometría) | ✅ Terminado — identidad de marca aplicada, responsivo iOS/tablet/PC |
| Dashboard | ✅ Terminado — fondo de marca, cajitas responsivas, moneda en colones |
| Inventario | 🔲 Pendiente de rediseño visual (funcional) |
| Ventas (POS) | 🔲 Pendiente de rediseño visual (funcional) |
| Compras | 🔲 Pendiente de rediseño visual (funcional) |
| Finanzas | 🔲 Pendiente de rediseño visual (funcional) |

## Roadmap

- Aplicar la misma identidad visual (rojo/negro/blanco, layout responsivo) a Inventario, Ventas, Compras y Finanzas.
- Roles y permisos para dar acceso a empleados (hoy el esquema asume un solo dueño por cuenta; se puede extender con tablas `businesses` + `staff` sin romper lo existente).
- Modo offline con sincronización diferida (Supabase soporta esto vía `drift`/`sqflite` + reconciliación).
- Notificaciones push (stock bajo, meta de ventas del día) con Supabase Edge Functions + FCM/APNs.
- Publicar en Google Play / App Store (`flutter build appbundle` / `flutter build ipa`).

---

<div align="center">

**SPICY Streetwear Co.** — proyecto privado, todos los derechos reservados.

</div>
