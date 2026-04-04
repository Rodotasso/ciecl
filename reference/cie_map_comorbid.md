# Mapeo manual grupos comorbilidad Chile-especifico

Agrupa codigos CIE-10 chilenos en categorias comorbilidad MINSAL. Basado
en Decreto 1301/2016 MINSAL + icd::icd10_map_charlson.

## Usage

``` r
cie_map_comorbid(codigos)
```

## Arguments

- codigos:

  Character vector codigos CIE-10

## Value

tibble con codigo + categoria_comorbilidad

## See also

[`cie_comorbid`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md),
[`cie_normalizar`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md)

Other comorbilidades:
[`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)

## Examples

``` r
cie_map_comorbid(c("E11.0", "I50.9", "C50.9"))
#> # A tibble: 3 × 2
#>   codigo categoria             
#>   <chr>  <chr>                 
#> 1 E11.0  Diabetes              
#> 2 I50.9  Insuficiencia cardiaca
#> 3 C50.9  Neoplasia maligna     
```
