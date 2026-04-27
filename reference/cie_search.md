# Busqueda difusa (fuzzy) de terminos medicos CIE-10

Busca en descripciones CIE-10 usando multiples estrategias:

1.  Expansion de siglas medicas (IAM, TBC, DM, etc.)

2.  Busqueda exacta por subcadena (mas rapida)

3.  Busqueda fuzzy con Jaro-Winkler (tolera typos)

## Usage

``` r
cie_search(
  text,
  threshold = 0.7,
  max_results = 50,
  field = c("descripcion", "inclusion"),
  only_fuzzy = FALSE,
  verbose = TRUE,
  texto = lifecycle::deprecated(),
  campo = lifecycle::deprecated(),
  solo_fuzzy = lifecycle::deprecated()
)
```

## Arguments

- text:

  String termino medico en espanol o sigla (ej. "diabetes", "IAM",
  "TBC")

- threshold:

  Numeric entre 0 y 1, umbral similitud Jaro-Winkler (default 0.70)

- max_results:

  Integer, maximo resultados a retornar (default 50)

- field:

  Character, campo busqueda ("descripcion" o "inclusion")

- only_fuzzy:

  Logical, usar solo busqueda fuzzy sin busqueda exacta (default FALSE)

- verbose:

  Logical, mostrar mensajes informativos (default TRUE). Usar FALSE en
  scripts.

- texto:

  **\[deprecated\]** Use `text`.

- campo:

  **\[deprecated\]** Use `field`.

- solo_fuzzy:

  **\[deprecated\]** Use `only_fuzzy`.

## Value

tibble ordenado por score descendente (1.0 = coincidencia exacta). Si el
text corresponde a una sigla medica, se expande automaticamente antes de
buscar.

## Details

La busqueda es tolerante a tildes: "neumonia" encuentra "neumonia".
Soporta siglas medicas comunes: "IAM" busca "infarto agudo miocardio".

## See also

[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_short`](https://rodotasso.github.io/ciecl/reference/cie_short.md),
[`cie10_sql`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)

Other busqueda:
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md),
[`cie_siglas()`](https://rodotasso.github.io/ciecl/reference/cie_siglas.md)

## Examples

``` r
# Busqueda basica
cie_search("diabetes")
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 E10    Diabetes mellitus insulinodependiente                      1 E10 DIAB…
#>  2 E10.0  Diabetes mellitus tipo 1 con coma                          1 E10 DIAB…
#>  3 E10.1  Diabetes mellitus tipo 1 con cetoacidosis                  1 E10 DIAB…
#>  4 E10.2  Diabetes mellitus tipo 1 con complicaciones renales        1 E10 DIAB…
#>  5 E10.3  Diabetes mellitus tipo 1 con complicaciones oftálmicas     1 E10 DIAB…
#>  6 E10.4  Diabetes mellitus tipo 1 con complicaciones neurológi…     1 E10 DIAB…
#>  7 E10.5  Diabetes mellitus tipo 1 con complicaciones  circulat…     1 E10 DIAB…
#>  8 E10.6  Diabetes mellitus tipo 1 con otras complicaciones esp…     1 E10 DIAB…
#>  9 E10.7  Diabetes mellitus tipo 1 con complicaciones múltiples      1 E10 DIAB…
#> 10 E10.8  Diabetes mellitus tipo 1 con complicaciones no especi…     1 E10 DIAB…
#> # ℹ 40 more rows

# \donttest{
cie_search("neumonia")
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 B01.2  Neumonía debida a varicela (J17.1*)                        1 B01 VARI…
#>  2 B05.2  Sarampión complicado con neumonía (J17.1*)                 1 B05 SARA…
#>  3 B20.6  Enfermedad por VIH, resultante en neumonía por Pneumo…     1 B20 ENFE…
#>  4 J10.0  Influenza con neumonía, debida a otro virus de la inf…     1 J10 INFL…
#>  5 J11.0  Influenza con neumonía, virus no identificado              1 J11 INFL…
#>  6 J12    Neumonía viral, no clasificada en otra parte               1 J12 NEUM…
#>  7 J12.0  Neumonía debida a adenovirus                               1 J12 NEUM…
#>  8 J12.1  Neumonía debida a virus sincitial respiratorio             1 J12 NEUM…
#>  9 J12.2  Neumonía debida a virus parainfluenza                      1 J12 NEUM…
#> 10 J12.3  Neumonía por metapneumovirus humano                        1 J12 NEUM…
#> # ℹ 40 more rows

# Busqueda por siglas medicas
cie_search("IAM")
#> i Sigla detectada: IAM -> infarto agudo miocardio
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 I21    Infarto agudo del miocardio                                1 I21 INFA…
#>  2 I21.0  Infarto transmural agudo del miocardio de la pared an…     1 I21 INFA…
#>  3 I21.1  Infarto transmural agudo del miocardio de la pared in…     1 I21 INFA…
#>  4 I21.2  Infarto agudo transmural del miocardio de otros sitios     1 I21 INFA…
#>  5 I21.3  Infarto transmural agudo del miocardio, de sitio no e…     1 I21 INFA…
#>  6 I21.4  Infarto subendocárdico agudo del miocardio                 1 I21 INFA…
#>  7 I21.9  Infarto agudo del miocardio, sin otra especificación       1 I21 INFA…
#>  8 I23    Ciertas complicaciones presentes posteriores al infar…     1 I23 CIER…
#>  9 I23.0  Hemopericardio como complicación presente posterior a…     1 I23 CIER…
#> 10 I23.3  Ruptura de la pared cardíaca sin hemopericardio como …     1 I23 CIER…
#> # ℹ 40 more rows
cie_search("DM2")
#> i Sigla detectada: DM2 -> diabetes mellitus tipo 2
#> # A tibble: 11 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 E11.0  Diabetes mellitus tipo 2 con coma                          1 E11 DIAB…
#>  2 E11.1  Diabetes mellitus tipo 2 con cetoacidosis                  1 E11 DIAB…
#>  3 E11.2  Diabetes mellitus tipo 2 con complicaciones renales        1 E11 DIAB…
#>  4 E11.3  Diabetes mellitus tipo 2 con complicaciones oftálmicas     1 E11 DIAB…
#>  5 E11.4  Diabetes mellitus tipo 2 con complicaciones neurológi…     1 E11 DIAB…
#>  6 E11.5  Diabetes mellitus tipo 2 con complicaciones  circulat…     1 E11 DIAB…
#>  7 E11.6  Diabetes mellitus tipo 2 con otras complicaciones  es…     1 E11 DIAB…
#>  8 E11.7  Diabetes mellitus tipo 2 con complicaciones múltiples      1 E11 DIAB…
#>  9 E11.8  Diabetes mellitus tipo 2 con complicaciones no especi…     1 E11 DIAB…
#> 10 E11.9  Diabetes mellitus tipo 2 sin complicaciones                1 E11 DIAB…
#> 11 O24.1  Diabetes mellitus tipo 2 preexistente                      1 O24 DIAB…

# Tolerante a tildes y typos
cie_search("diabetis")
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 E10    Diabetes mellitus insulinodependiente                  0.917 E10 DIAB…
#>  2 E10.0  Diabetes mellitus tipo 1 con coma                      0.917 E10 DIAB…
#>  3 E10.1  Diabetes mellitus tipo 1 con cetoacidosis              0.917 E10 DIAB…
#>  4 E10.2  Diabetes mellitus tipo 1 con complicaciones renales    0.917 E10 DIAB…
#>  5 E10.3  Diabetes mellitus tipo 1 con complicaciones oftálmicas 0.917 E10 DIAB…
#>  6 E10.4  Diabetes mellitus tipo 1 con complicaciones neurológi… 0.917 E10 DIAB…
#>  7 E10.5  Diabetes mellitus tipo 1 con complicaciones  circulat… 0.917 E10 DIAB…
#>  8 E10.6  Diabetes mellitus tipo 1 con otras complicaciones esp… 0.917 E10 DIAB…
#>  9 E10.7  Diabetes mellitus tipo 1 con complicaciones múltiples  0.917 E10 DIAB…
#> 10 E10.8  Diabetes mellitus tipo 1 con complicaciones no especi… 0.917 E10 DIAB…
#> # ℹ 40 more rows

# Buscar en inclusiones
cie_search("bacteriana", field = "inclusion")
#> x Sin coincidencias >= threshold 0.7
#> # A tibble: 0 × 5
#> # ℹ 5 variables: codigo <chr>, descripcion <chr>, score <dbl>, categoria <chr>,
#> #   inclusion <chr>
# }
```
