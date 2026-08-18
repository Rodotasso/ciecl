# Guía de Instalación y Configuración

## Instalación

La forma más simple de instalar `ciecl` es con el paquete
[`pak`](https://pak.r-lib.org/), que resuelve automáticamente las
dependencias de R y del sistema operativo.

### Desde CRAN (versión estable)

``` r

install.packages("ciecl")
```

### Desde GitHub (versión de desarrollo)

``` r

install.packages("pak")
pak::pak("RodoTasso/ciecl")
```

Para instalar además todas las dependencias opcionales (comorbilidades,
tablas GT, API CIE-11):

``` r

pak::pak("RodoTasso/ciecl", dependencies = TRUE)
```

### Dependencias por funcionalidad

El núcleo del paquete (búsqueda y consulta de códigos CIE-10) no
requiere paquetes opcionales. Estas son las dependencias sugeridas según
la tarea:

| Funcionalidad | Paquete | Instalación |
|----|----|----|
| Índices de comorbilidad Charlson/Elixhauser con [`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md) | `comorbidity` | `install.packages("comorbidity")` |
| Tablas HTML formateadas con [`cie_table()`](https://rodotasso.github.io/ciecl/reference/cie_table.md) | `gt` | `install.packages("gt")` |
| Leer archivos Excel del MINSAL | `readxl` | `install.packages("readxl")` |
| Exportar resultados a Excel | `writexl` | `install.packages("writexl")` |

## Requisitos del sistema

### Windows

No requiere dependencias adicionales: la instalación funciona
directamente.

### macOS

Instala las Xcode Command Line Tools si compilas desde fuente:

``` bash
xcode-select --install
```

### Linux (Ubuntu/Debian)

``` bash
sudo apt-get update
sudo apt-get install -y \
  r-base-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev
```

### Linux (Fedora/RHEL/CentOS)

``` bash
sudo dnf install -y \
  R-devel \
  libcurl-devel \
  openssl-devel \
  libxml2-devel
```

## Configuración de la API CIE-11 (opcional)

Las funciones de CIE-10 (núcleo del paquete) funcionan sin credenciales.
Solo para usar
[`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md),
que consulta la clasificación CIE-11 de la OMS, necesitas credenciales
gratuitas.

> **Seguridad:** nunca escribas la llave literal en tus scripts (ni con
> `api_key = "..."`): al compartir el código expondrías tus
> credenciales. La vía recomendada es la variable de entorno
> `ICD_API_KEY`, configurada con `usethis::edit_r_environ()` (Opción B)
> o vía `keyring` (Opción A). El argumento `api_key` de
> [`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)
> existe solo para casos excepcionales (p. ej. múltiples llaves o
> entornos sin variables de entorno).

### Paso 1: Obtener credenciales

1.  Visita <https://icd.who.int/icdapi>
2.  Regístrate con tu email (proceso gratuito)
3.  Obtendrás un `Client ID` y un `Client Secret`

### Paso 2: Guardar las credenciales

**Opción A: `keyring` (recomendado)**

El paquete [`keyring`](https://keyring.r-lib.org/) guarda secretos en el
keychain nativo del sistema operativo (macOS Keychain, Windows
Credential Store, Linux Secret Service), evitando que el `Client ID` y
el `Client Secret` queden en texto plano en `.Renviron`.

``` r

# Una sola vez: guarda "client_id:client_secret" en el keychain
keyring::key_set("ciecl_icd11")

# En cada sesión en la que uses la API
Sys.setenv(ICD_API_KEY = keyring::key_get("ciecl_icd11"))
```

**Opción B: Archivo `.Renviron`**

Crea o edita `~/.Renviron` (por ejemplo con `usethis::edit_r_environ()`
si tienes `usethis` instalado) y agrega:

    ICD_API_KEY=tu_client_id:tu_client_secret

Reinicia R para que tome efecto. No subas `.Renviron` a Git.

**Opción C: Solo en la sesión actual (temporal)**

``` r

Sys.setenv(ICD_API_KEY = "tu_client_id:tu_client_secret")
```

### Paso 3: Verificar la configuración

``` r

# Verificar que la variable de entorno esta definida
Sys.getenv("ICD_API_KEY")

# Probar una busqueda CIE-11
library(ciecl)
cie11_search("diabetes")
```

## Caché SQLite

El paquete usa una base SQLite local para búsquedas eficientes. Se crea
automáticamente en la primera consulta, en el directorio de datos del
usuario:

``` r

# Ver la ubicacion del cache
tools::R_user_dir("ciecl", "data")
```

Puedes cambiar esa ubicación definiendo la variable de entorno
`CIECL_CACHE_DIR` antes de cargar el paquete. Si necesitas forzar la
reconstrucción de la base (por ejemplo, tras actualizar el paquete):

``` r

library(ciecl)
cie10_clear_cache()
```

## Verificar la instalación

``` r

library(ciecl)

# Verificar que el paquete carga correctamente
packageVersion("ciecl")

# Verificar acceso al catálogo
nrow(cie10_cl)

# Probar búsqueda básica
cie_lookup("E11.0")

# Probar búsqueda fuzzy
cie_search("diabetes")
```

## Problemas comunes

### Error: “package ‘ciecl’ is not available”

Verifica que el repositorio de CRAN esté configurado en tu sesión de R y
luego instala normalmente:

``` r

install.packages("ciecl")
```

### Error de compilación en Linux

Instala las dependencias del sistema indicadas en la sección “Requisitos
del sistema” y vuelve a intentar la instalación.

### La API CIE-11 no responde

1.  Verifica que la credencial esté configurada:
    `Sys.getenv("ICD_API_KEY")` no debe retornar una cadena vacía.
2.  Verifica tu conexión a internet.
3.  Comprueba el estado del servicio de la OMS en
    <https://icd.who.int/icdapi>: si está caído, las funciones de CIE-10
    siguen operativas porque no dependen de la API.

### Caché corrupto

Limpia la caché y reinicia R:

``` r

ciecl::cie10_clear_cache()
```

## Soporte

- Reportar problemas: <https://github.com/RodoTasso/ciecl/issues>
- Documentación: <https://rodotasso.github.io/ciecl/>
