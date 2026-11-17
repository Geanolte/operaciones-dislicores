# Operaciones Dislicores – prototipo de pruebas

App de una sola página (`index.html`) para **alistamiento** y **despacho** desde el celular, con escaneo por cámara o pistola.

**Esta versión pública es solo para pruebas con datos ficticios.**
No suba aquí archivos de SIESA, planillas reales ni ningún dato de la empresa o de clientes.

## Cómo funciona
- Los Excel se leen en el celular. De cada archivo solo se conservan referencia, descripción del producto, código de barras, empaque y cantidades; los datos de clientes se descartan al cargar.
- El supervisor reparte el trabajo por **Grupo Shopper** y **Línea proveedor** (la bodega no necesita ubicaciones).
- Los operarios abren su lista y el avance se ve en vivo gracias a Supabase (tablas `ops_listas` y `ops_res`, ver `supabase_setup.sql`). La clave incluida es la **publishable** (pública por diseño).
- Las reglas de acceso son abiertas, válidas solo para datos ficticios. Se cerrarán por rol cuando exista inicio de sesión real.
- Sin las claves de Supabase, la app funciona igual, compartiendo las listas por archivo o código.

## Archivos
- `app.html`: fuente de la app (sin claves).
- `index.html`: la app lista para publicar (la genera `publicar.ps1`).
- `supabase_setup.sql`: crea las tablas de pruebas en Supabase.
- `publicar.ps1`: inyecta la URL y la clave publishable, y publica.
