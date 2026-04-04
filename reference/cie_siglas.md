# Listar siglas medicas soportadas

Muestra todas las siglas medicas que pueden usarse en cie_search().

## Usage

``` r
cie_siglas(categoria = NULL)
```

## Arguments

- categoria:

  Character opcional, filtrar por categoria. Valores validos:
  "cardiovascular", "respiratoria", "metabolica", "gastrointestinal",
  "infecciosa", "oncologica", "reumatologica", "neurologica",
  "psiquiatrica", "traumatologica", "pediatrica", "gineco_obstetrica".
  Si es NULL (default), retorna todas las siglas.

## Value

tibble con columnas: sigla, termino_busqueda, categoria

## See also

[`cie_search`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

Other busqueda:
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)

## Examples

``` r
# Ver todas las siglas
cie_siglas()
#> # A tibble: 89 × 3
#>    sigla   termino_busqueda         categoria     
#>    <chr>   <chr>                    <chr>         
#>  1 iam     infarto agudo miocardio  cardiovascular
#>  2 iamcest infarto agudo miocardio  cardiovascular
#>  3 iamsest infarto agudo miocardio  cardiovascular
#>  4 sca     sindrome coronario agudo cardiovascular
#>  5 hta     hipertension arterial    cardiovascular
#>  6 aha     hipertension arterial    cardiovascular
#>  7 icc     insuficiencia cardiaca   cardiovascular
#>  8 ic      insuficiencia cardiaca   cardiovascular
#>  9 fa      fibrilacion auricular    cardiovascular
#> 10 tep     embolia pulmonar         cardiovascular
#> # ℹ 79 more rows

# Filtrar por categoria
cie_siglas("cardiovascular")
#> # A tibble: 15 × 3
#>    sigla   termino_busqueda              categoria     
#>    <chr>   <chr>                         <chr>         
#>  1 iam     infarto agudo miocardio       cardiovascular
#>  2 iamcest infarto agudo miocardio       cardiovascular
#>  3 iamsest infarto agudo miocardio       cardiovascular
#>  4 sca     sindrome coronario agudo      cardiovascular
#>  5 hta     hipertension arterial         cardiovascular
#>  6 aha     hipertension arterial         cardiovascular
#>  7 icc     insuficiencia cardiaca        cardiovascular
#>  8 ic      insuficiencia cardiaca        cardiovascular
#>  9 fa      fibrilacion auricular         cardiovascular
#> 10 tep     embolia pulmonar              cardiovascular
#> 11 tvp     trombosis venosa profunda     cardiovascular
#> 12 eap     edema agudo pulmon            cardiovascular
#> 13 acv     accidente cerebrovascular     cardiovascular
#> 14 ave     accidente vascular encefalico cardiovascular
#> 15 ait     isquemico transitorio         cardiovascular
cie_siglas("oncologica")
#> # A tibble: 9 × 3
#>   sigla termino_busqueda             categoria 
#>   <chr> <chr>                        <chr>     
#> 1 ca    carcinoma                    oncologica
#> 2 neo   neoplasia                    oncologica
#> 3 lma   leucemia mieloide aguda      oncologica
#> 4 lmc   leucemia mieloide cronica    oncologica
#> 5 lla   leucemia linfoblastica aguda oncologica
#> 6 llc   leucemia linfocitica cronica oncologica
#> 7 lnh   linfoma no hodgkin           oncologica
#> 8 lh    linfoma hodgkin              oncologica
#> 9 mm    mieloma multiple             oncologica

# Buscar una sigla especifica
cie_siglas() |> dplyr::filter(sigla == "iam")
#> # A tibble: 1 × 3
#>   sigla termino_busqueda        categoria     
#>   <chr> <chr>                   <chr>         
#> 1 iam   infarto agudo miocardio cardiovascular
```
