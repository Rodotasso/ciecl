# Limpiar cache SQLite (forzar rebuild)

Limpiar cache SQLite (forzar rebuild)

## Usage

``` r
cie10_clear_cache()
```

## Value

No return value, called for side effects (deletes SQLite cache).

## See also

[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md),
[`cie10_disconnect()`](https://rodotasso.github.io/ciecl/reference/cie10_disconnect.md)

Other sql_backend:
[`cie10_disconnect()`](https://rodotasso.github.io/ciecl/reference/cie10_disconnect.md),
[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)

## Examples

``` r
# Ver ubicacion del cache
tools::R_user_dir("ciecl", "data")
#> [1] "/home/runner/.local/share/R/ciecl"

if (FALSE) { # interactive()
cie10_clear_cache() # Elimina cie10.db local
}
```
