# Guia de funciones de busqueda (deprecated)

**\[deprecated\]** Use
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md).

## Usage

``` r
cie_guia_busqueda()
```

## Value

tibble con guia comparativa

## See also

Other search:
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)

## Examples

``` r
# Deprecated: usar cie_guide()
cie_guia_busqueda()
#> Warning: `cie_guia_busqueda()` was deprecated in ciecl 0.9.8.
#> ℹ Please use `cie_guide()` instead.
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
