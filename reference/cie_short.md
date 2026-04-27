# Listar siglas medicas soportadas

Muestra todas las siglas medicas que pueden usarse en
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md).
"Sigla" se conserva como termino local (concepto medico chileno) en la
columna de salida; el nombre de la funcion usa `cie_short` por
consistencia con el ecosistema R (verbos cortos en ingles).

## Usage

``` r
cie_short(category = NULL, categoria = lifecycle::deprecated())
```

## Arguments

- category:

  Character opcional, filtrar por categoria. Valores validos:
  "cardiovascular", "respiratoria", "metabolica", "gastrointestinal",
  "infecciosa", "oncologica", "reumatologica", "neurologica",
  "psiquiatrica", "traumatologica", "pediatrica", "gineco_obstetrica".
  Si es NULL (default), retorna todas las siglas.

- categoria:

  **\[deprecated\]** Use `category`.

## Value

tibble con columnas: sigla, termino_busqueda, categoria

## See also

[`cie_search`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

Other busqueda:
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_siglas()`](https://rodotasso.github.io/ciecl/reference/cie_siglas.md)

## Examples

``` r
# Ver todas las siglas
cie_short()
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
cie_short("cardiovascular")
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
cie_short("oncologica")
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
cie_short() |> dplyr::filter(sigla == "iam")
#> # A tibble: 1 × 3
#>   sigla termino_busqueda        categoria     
#>   <chr> <chr>                   <chr>         
#> 1 iam   infarto agudo miocardio cardiovascular
```
