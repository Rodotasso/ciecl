# Limpiar caché SQLite local (forzar rebuild)

`ciecl` construye, en el primer uso, un archivo SQLite (`cie10.db`) a
partir del dataset
[cie10_cl](https://rodotasso.github.io/ciecl/reference/cie10_cl.md) y lo
guarda en una carpeta de datos del usuario (ver
`tools::R_user_dir("ciecl", "data")`). Esa "caché" evita reconstruir la
base en cada sesión. Esta función la elimina y fuerza que la próxima
consulta
([`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md),
etc.) la reconstruya desde cero.

Es necesario forzar el rebuild cuando: (1) se actualiza el paquete a una
version con un dataset CIE-10 corregido y la caché vieja quedó
desactualizada, (2) se sospecha que el archivo `.db` está corrupto
(errores de lectura SQL inesperados), o (3) se quiere liberar el espacio
en disco que ocupa la caché.

## Usage

``` r
cie10_clear_cache()
```

## Value

Sin valor de retorno, se llama por sus efectos secundarios (elimina la
caché SQLite).

## See also

[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md),
[`cie10_disconnect()`](https://rodotasso.github.io/ciecl/reference/cie10_disconnect.md)

Other sql_backend:
[`cie10_disconnect()`](https://rodotasso.github.io/ciecl/reference/cie10_disconnect.md),
[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)

## Examples

``` r
# Ver ubicación de la caché
tools::R_user_dir("ciecl", "data")
#> [1] "/home/runner/.local/share/R/ciecl"

if (FALSE) { # interactive()
cie10_clear_cache() # Elimina cie10.db local
}
```
