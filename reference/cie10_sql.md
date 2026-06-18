# Ejecutar consultas SQL sobre CIE-10 Chile

Ejecutar consultas SQL sobre CIE-10 Chile

## Usage

``` r
cie10_sql(query, close = lifecycle::deprecated())
```

## Arguments

- query:

  String SQL valido SQLite (SELECT/WHERE/JOIN)

- close:

  **\[deprecated\]** Ignorado - la conexion es pooled y se gestiona
  automaticamente. Sera eliminado en una version futura.

## Value

tibble resultado query

## See also

[`cie10_clear_cache()`](https://rodotasso.github.io/ciecl/reference/cie10_clear_cache.md),
[`cie10_disconnect()`](https://rodotasso.github.io/ciecl/reference/cie10_disconnect.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)

Other sql_backend:
[`cie10_clear_cache()`](https://rodotasso.github.io/ciecl/reference/cie10_clear_cache.md),
[`cie10_disconnect()`](https://rodotasso.github.io/ciecl/reference/cie10_disconnect.md)

## Examples

``` r
# Buscar diabetes
cie10_sql("SELECT codigo, descripcion FROM cie10 WHERE codigo LIKE 'E11%'")
#> # A tibble: 11 × 2
#>    codigo descripcion                                                           
#>    <chr>  <chr>                                                                 
#>  1 E11    Diabetes mellitus no insulinodependiente                              
#>  2 E11.0  Diabetes mellitus tipo 2 con coma                                     
#>  3 E11.1  Diabetes mellitus tipo 2 con cetoacidosis                             
#>  4 E11.2  Diabetes mellitus tipo 2 con complicaciones renales                   
#>  5 E11.3  Diabetes mellitus tipo 2 con complicaciones oftálmicas                
#>  6 E11.4  Diabetes mellitus tipo 2 con complicaciones neurológicas              
#>  7 E11.5  Diabetes mellitus tipo 2 con complicaciones  circulatorias periféricas
#>  8 E11.6  Diabetes mellitus tipo 2 con otras complicaciones  especificadas      
#>  9 E11.7  Diabetes mellitus tipo 2 con complicaciones múltiples                 
#> 10 E11.8  Diabetes mellitus tipo 2 con complicaciones no especificadas          
#> 11 E11.9  Diabetes mellitus tipo 2 sin complicaciones                           

if (FALSE) { # interactive()
# Contar por capitulo
cie10_sql("SELECT capitulo, COUNT(*) n FROM cie10 GROUP BY capitulo")
}
```
