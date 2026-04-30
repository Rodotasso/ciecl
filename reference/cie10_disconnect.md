# Cerrar conexion pooled SQLite

Cierra la conexion reutilizable al archivo SQLite. Util para liberar el
lock del archivo .db.

## Usage

``` r
cie10_disconnect()
```

## Value

No return value, called for side effects.

## See also

[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md),
[`cie10_clear_cache()`](https://rodotasso.github.io/ciecl/reference/cie10_clear_cache.md)

Other sql:
[`cie10_clear_cache()`](https://rodotasso.github.io/ciecl/reference/cie10_clear_cache.md),
[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)

## Examples

``` r
# Verificar si hay conexion activa
is.null(ciecl:::.ciecl_env$con)
#> [1] TRUE

if (FALSE) { # interactive()
cie10_disconnect()
}
```
