# Búsqueda difusa (fuzzy) de términos médicos CIE-10

Busca en descripciones CIE-10 usando múltiples estrategias:

1.  Expansión de siglas médicas (IAM, TBC, DM, etc.)

2.  Búsqueda exacta por subcadena (más rápida)

3.  Búsqueda fuzzy con Jaro-Winkler (tolera typos)

## Usage

``` r
cie_search(
  text,
  threshold = 0.7,
  max_results = 50,
  field = c("descripcion", "inclusion"),
  only_fuzzy = FALSE,
  verbose = TRUE,
  include_uso_cl = FALSE,
  only_uso_cl = FALSE,
  texto = lifecycle::deprecated(),
  campo = lifecycle::deprecated(),
  solo_fuzzy = lifecycle::deprecated()
)
```

## Arguments

- text:

  String término médico en español o sigla (ej. "diabetes", "IAM",
  "TBC")

- threshold:

  Numeric entre 0 y 1, umbral similitud Jaro-Winkler (default 0.70)

- max_results:

  Integer, máximo resultados a retornar (default 50)

- field:

  Character, campo búsqueda ("descripcion" o "inclusion")

- only_fuzzy:

  Logical, usar solo búsqueda fuzzy sin búsqueda exacta (default FALSE)

- verbose:

  Logical, mostrar mensajes informativos (default TRUE). Usar FALSE en
  scripts.

- include_uso_cl:

  Logical, incluir columna `uso_cl` en el output (default FALSE). El
  default difiere de
  [`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
  (TRUE) para preservar el contrato histórico de cada función. Valores
  posibles: `"principal"`, `"legado"`, `"causa_externa"`,
  `"etiologico"`, `"causa_externa | principal"`.

- only_uso_cl:

  Logical, filtrar a códigos vigentes de uso clínico en Chile (default
  FALSE). Cuando es TRUE, excluye los códigos con `uso_cl == "legado"`.

- texto:

  **\[deprecated\]** Use `text`.

- campo:

  **\[deprecated\]** Use `field`.

- solo_fuzzy:

  **\[deprecated\]** Use `only_fuzzy`.

## Value

tibble ordenado por score descendente (1.0 = coincidencia exacta). Si el
text corresponde a una sigla médica, se expande automáticamente antes de
buscar.

## Details

La búsqueda es tolerante a tildes: "neumonia" (sin tilde) encuentra
"neumonía" (con tilde) en el catálogo. Soporta siglas médicas comunes:
"IAM" busca "infarto agudo miocardio".

## See also

[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md),
[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)

Other search:
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

## Examples

``` r
# Búsqueda básica
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

# Búsqueda por siglas médicas
cie_search("IAM")
cie_search("DM2")

# Tolerante a tildes y typos
cie_search("diabetis")

# Buscar en inclusiones
cie_search("bacteriana", field = "inclusion")
# Filtrar a códigos vigentes Chile (excluye 'legado')
cie_search("diabetes", only_uso_cl = TRUE)
# Mostrar la columna uso_cl en el output
cie_search("diabetes", include_uso_cl = TRUE)
}
```
