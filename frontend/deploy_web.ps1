# Publica la version web en Firebase Hosting con las credenciales de
# Supabase incluidas. Corre esto desde la carpeta frontend cada vez que
# quieras subir cambios a https://spicy-admin-f61a1.web.app
#
# Uso:
#   .\deploy_web.ps1

$SUPABASE_URL = "https://iykxuswiwknjodbwkmdb.supabase.co"
$SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5a3h1c3dpd2tuam9kYndrbWRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ1NjY4ODAsImV4cCI6MjEwMDE0Mjg4MH0.h6l_Oi_J3capZMW0YHpkgW_jhLYnPb0YtQ2NXEvpR04"

flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
firebase deploy --only hosting
