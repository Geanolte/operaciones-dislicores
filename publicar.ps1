# Genera index.html (con la URL y la clave PUBLISHABLE de Supabase) y publica en GitHub.
# Uso:   .\publicar.ps1                      -> genera, hace commit y push
#        .\publicar.ps1 -SoloGenerar         -> solo genera index.html (para revisar)
#        .\publicar.ps1 -Mensaje "texto"     -> mensaje del commit
param([string]$Mensaje = "Actualiza la app", [switch]$SoloGenerar)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# 1) Fuente: si existe la versión de OneDrive, se copia como app.html (fuente sin claves)
$origen = 'C:\Users\german.oliveros\OneDrive - DISLICORES\Claude\CODE\Super_App\App_Operaciones\index.html'
if (Test-Path $origen) { Copy-Item $origen .\app.html -Force; Write-Host 'Fuente actualizada desde OneDrive.' }

# 2) URL y clave publishable: se leen del repo de Semáforos (mismo proyecto de pruebas)
$sem = 'C:\Users\german.oliveros\repos\semaforos-vencimiento\index.html'
if (-not (Test-Path $sem)) { throw 'No se encontró el repo de Semáforos para leer la URL y la clave publishable.' }
$t   = [IO.File]::ReadAllText($sem)
$url = [regex]::Match($t, 'SUPABASE_URL\s*=\s*"([^"]+)"').Groups[1].Value
$key = [regex]::Match($t, 'SUPABASE_KEY\s*=\s*"([^"]+)"').Groups[1].Value
if ($url -notmatch '^https://[a-z0-9]+\.supabase\.co$') { throw 'La URL de Supabase no es válida.' }
if ($key -notmatch '^sb_publishable_')                   { throw 'La clave debe ser la publishable (sb_publishable_...). Nunca use claves secret.' }

# 3) Inyección y controles de seguridad
$app = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'app.html'), [Text.Encoding]::UTF8)
if ($app -notmatch 'var SUPA_URL = "";') { throw 'app.html ya trae constantes inyectadas: use la fuente limpia.' }
$idx = $app.Replace('var SUPA_URL = "";', ('var SUPA_URL = "{0}";' -f $url)).Replace('var SUPA_KEY = "";', ('var SUPA_KEY = "{0}";' -f $key))
if ($idx -match '@dislicores\.com')    { throw 'Hay un correo corporativo en el archivo.' }
if ($idx -match 'sb_secret_[A-Za-z0-9]') { throw 'Hay una clave secret en el archivo.' }
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'index.html'), $idx, (New-Object Text.UTF8Encoding $false))
Write-Host 'index.html generado.'
if ($SoloGenerar) { return }

# 4) Publicación (la autenticación de GitHub la hace usted)
git add app.html index.html README.md supabase_setup.sql publicar.ps1 .gitignore
git commit -m $Mensaje
git push -u origin HEAD
