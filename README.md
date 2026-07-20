# SPICY Streetwear Co. — App de administración

App móvil para el dueño de SPICY: inventario, compras, ventas (punto de
venta) y finanzas. Construida con **Flutter** (frontend, iOS/Android) y
**Supabase** (backend: Postgres + Auth + seguridad a nivel de fila).

Este documento es la guía completa para abrir el proyecto en VS Code,
levantar el backend y correr la app por primera vez.

## Arquitectura

```
spicy-admin-app/
├── backend/
│   └── supabase/
│       ├── migrations/0001_init.sql   ← esquema completo (tablas + RLS + funciones)
│       └── seed/seed_data.sql         ← datos de ejemplo opcionales
└── frontend/                          ← proyecto Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── core/        (tema, config, utilidades/métricas)
    │   ├── models/       (Product, Sale, Purchase, Expense, Supplier)
    │   ├── services/     (llamadas a Supabase, auth, PIN/biometría)
    │   ├── state/        (AppState — estado global con Provider)
    │   ├── features/     (una carpeta por pantalla: auth, dashboard,
    │   │                   inventory, sales, purchases, finance, settings)
    │   └── widgets/       (componentes compartidos)
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

## 1. Requisitos previos

- [VS Code](https://code.visualstudio.com/) con las extensiones **Flutter** y **Dart** (Marketplace)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (`flutter doctor` sin errores)
- Una cuenta gratuita en [supabase.com](https://supabase.com)
- Xcode (para iOS, solo en Mac) y/o Android Studio (para el emulador de Android)

## 2. Backend: crear tu proyecto de Supabase

1. Entra a [supabase.com](https://supabase.com) → **New project**. Elige nombre, contraseña de base de datos y región.
2. Cuando el proyecto esté listo, ve a **SQL Editor** (menú lateral).
3. Abre `backend/supabase/migrations/0001_init.sql` de este repo, copia todo el contenido, pégalo en el SQL Editor y dale **Run**. Esto crea las tablas, la seguridad (RLS) y las funciones de negocio.
4. Ve a **Project Settings → API**. Copia:
   - **Project URL** (algo como `https://xxxxx.supabase.co`)
   - **anon public key**
   Los vas a necesitar en el paso 4.
5. (Opcional pero recomendado) Crea tu usuario dueño desde la propia app en el paso 5, o manualmente en **Authentication → Users → Add user**.
6. (Opcional) Para probar la app con datos de ejemplo: abre `backend/supabase/seed/seed_data.sql`, reemplaza `REPLACE_WITH_YOUR_USER_ID` por tu User UID (lo ves en **Authentication → Users**), y ejecútalo en el SQL Editor.

## 3. Frontend: preparar el proyecto Flutter en VS Code

El SDK de Flutter no estuvo disponible en el entorno donde se generó este
código, así que el código fuente (`lib/`, `pubspec.yaml`) está listo,
pero **falta generar las carpetas nativas** (`android/`, `ios/`, etc.).
Se hace una sola vez, así:

1. Abre una terminal en la carpeta `frontend/` de este proyecto.
2. Corre:
   ```bash
   flutter create --org com.spicy --project-name spicy_admin .
   ```
   Esto genera `android/`, `ios/`, `web/`, etc. **sin sobrescribir** tu `lib/` ni tu `pubspec.yaml` existentes (Flutter detecta que ya existen y solo agrega lo que falta). Si te pregunta si sobrescribir `pubspec.yaml` o algún archivo de `lib/`, responde que **no**.
3. Instala las dependencias:
   ```bash
   flutter pub get
   ```
4. Abre la carpeta `frontend/` en VS Code (`code .`).

### Habilitar biometría (Face ID / huella)

- **Android**: abre `android/app/src/main/AndroidManifest.xml` y agrega dentro de `<manifest>`:
  ```xml
  <uses-permission android:name="android.permission.USE_BIOMETRIC" />
  ```
- **iOS**: abre `ios/Runner/Info.plist` y agrega:
  ```xml
  <key>NSFaceIDUsageDescription</key>
  <string>Usamos Face ID para desbloquear SPICY Admin rápidamente.</string>
  ```

## 4. Conectar la app a tu Supabase y correrla

Ya existe `frontend/.vscode/launch.json` con la configuración de VS Code,
solo edítalo y reemplaza los valores de ejemplo por los tuyos (del paso 2.4):

```json
"args": [
  "--dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co",
  "--dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY_AQUI"
]
```

Luego, en VS Code: abre `lib/main.dart`, ve a la pestaña **Run and Debug**
(Ctrl+Shift+D / Cmd+Shift+D), elige **"SPICY Admin (dev)"** y presiona ▶.
También puedes usar un emulador Android, un simulador de iOS, o Chrome
(Flutter Web) como destino.

Si prefieres la terminal en vez del botón ▶ de VS Code:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY_AQUI
```

## 5. Primer uso

1. Al abrir la app por primera vez verás la pantalla de **Crear cuenta**: registra tu correo y contraseña (esto crea tu usuario en Supabase Auth y, automáticamente, tu perfil de negocio).
2. La app te pedirá crear un **PIN de 4 dígitos** — es tu desbloqueo rápido local (independiente de tu contraseña), guardado cifrado en el sistema operativo del teléfono (Keychain/Keystore), nunca en texto plano.
3. Si corriste el `seed_data.sql` del paso 2.6, ya verás productos, ventas, compras y gastos de ejemplo. Si no, la app empieza vacía y puedes ir creando todo desde los botones **+**.

## Seguridad — resumen de lo implementado

- **Row Level Security** en Postgres: cada fila de cada tabla está protegida por una política que exige `owner_id = auth.uid()`; nadie puede leer o modificar datos de otra cuenta aunque conozca la URL de la API.
- **PIN local + biometría**: capa adicional de bloqueo en el propio dispositivo, con auto-bloqueo al mandar la app a segundo plano.
- **Operaciones atómicas en el servidor**: `register_sale` y `receive_purchase` corren dentro de una transacción de Postgres con bloqueo de fila (`FOR UPDATE`), evitando que dos ventas simultáneas dejen el stock en un estado inconsistente.
- **Sin llaves ni secretos en el código**: la URL y la anon key se inyectan en tiempo de compilación (`--dart-define`), nunca quedan hardcodeadas en el repositorio.

## Próximos pasos sugeridos

- Roles y permisos si más adelante quieres dar acceso a empleados (hoy el esquema asume un solo dueño por cuenta; se puede extender con una tabla `businesses` + `staff` sin romper lo existente).
- Modo offline con sincronización diferida (Supabase soporta esto vía `drift`/`sqflite` + reconciliación).
- Notificaciones push (stock bajo, meta de ventas del día) con Supabase Edge Functions + FCM/APNs.
- Publicar en Google Play / App Store cuando el negocio esté listo para eso (`flutter build appbundle` / `flutter build ipa`).
