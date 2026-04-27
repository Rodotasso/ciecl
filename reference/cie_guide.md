# Guia de funciones de busqueda CIE-10

Muestra tabla comparativa de cuando usar cada funcion de busqueda.

## Usage

``` r
cie_guide()
```

## Value

tibble con guia comparativa de funciones de busqueda

## See also

[`cie_search`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_short`](https://rodotasso.github.io/ciecl/reference/cie_short.md)

Other busqueda:
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md),
[`cie_siglas()`](https://rodotasso.github.io/ciecl/reference/cie_siglas.md)

## Examples

``` r
cie_guide()
#> # A tibble: 8 × 3
#>   Tengo...                     `Usar funcion`                            Ejemplo
#>   <chr>                        <chr>                                     <chr>  
#> 1 Codigo exacto (E11.0)        cie_lookup()                              "cie_l…
#> 2 Codigo sin punto (e110)      cie_lookup()                              "cie_l…
#> 3 Codigo con espacios (E 11.0) cie_lookup()                              "cie_l…
#> 4 Codigo con prefijos/sufijos  cie_lookup(extract = TRUE)                "cie_l…
#> 5 Codigo categoria (E11)       cie_lookup() o cie_lookup(expandir = TRU… "cie_l…
#> 6 Descripcion (diabetes)       cie_search()                              "cie_s…
#> 7 Sigla medica (IAM, DM2)      cie_lookup(check_siglas = TRUE)           "cie_l…
#> 8 No se que tengo              cie_search() con threshold bajo           "cie_s…
```
