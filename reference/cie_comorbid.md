# Calcular comorbilidades Charlson/Elixhauser para Chile

Calcular comorbilidades Charlson/Elixhauser para Chile

## Usage

``` r
cie_comorbid(data, id, code, map = c("charlson", "elixhauser"), assign0 = TRUE)
```

## Arguments

- data:

  data.frame con columnas id paciente + codigos CIE-10

- id:

  String nombre columna identificador paciente

- code:

  String nombre columna con codigos CIE-10 (uno por fila)

- map:

  Character, esquema comorbilidad ("charlson" o "elixhauser")

- assign0:

  Logical, asignar 0 si sin comorbilidad (default TRUE)

## Value

data.frame ancho con scores comorbilidad por paciente

## See also

[`cie_map_comorbid`](https://rodotasso.github.io/ciecl/reference/cie_map_comorbid.md),
[`cie_norm`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)

Other comorbilidades:
[`cie_map_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_map_comorbid.md)

## Examples

``` r
# Ver documentacion de parametros
args(cie_comorbid)
#> function (data, id, code, map = c("charlson", "elixhauser"), 
#>     assign0 = TRUE) 
#> NULL

# \donttest{
df <- data.frame(
  id_pac = c(1, 1, 2, 2),
  diag = c("E11.0", "I21.0", "C50.9", "E10.9")
)
cie_comorbid(df, id = "id_pac", code = "diag", map = "charlson")
#> # A tibble: 2 × 19
#>   id_pac    mi   chf   pvd  cevd dementia   cpd rheumd   pud   mld  diab diabwc
#>    <dbl> <int> <int> <int> <int>    <int> <int>  <int> <int> <int> <int>  <int>
#> 1      1     1     0     0     0        0     0      0     0     0     1      0
#> 2      2     0     0     0     0        0     0      0     0     0     1      0
#> # ℹ 7 more variables: hp <int>, rend <int>, canc <int>, msld <int>,
#> #   metacanc <int>, aids <int>, score_charlson <dbl>
# }
```
