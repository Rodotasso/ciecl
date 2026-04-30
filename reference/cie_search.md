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

[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md),
[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)

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

if (FALSE) { # interactive()
cie_search("neumonia")

# Busqueda por siglas medicas
cie_search("IAM")
cie_search("DM2")

# Tolerante a tildes y typos
cie_search("diabetis")

# Buscar en inclusiones
cie_search("bacteriana", field = "inclusion")
}
```
