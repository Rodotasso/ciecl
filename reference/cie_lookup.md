# Búsqueda exacta por código CIE-10

Búsqueda exacta por código CIE-10

## Usage

``` r
cie_lookup(
  code,
  expand = FALSE,
  normalize = TRUE,
  full_description = FALSE,
  extract = FALSE,
  check_siglas = FALSE,
  include_uso_cl = TRUE,
  only_uso_cl = FALSE,
  codigo = lifecycle::deprecated(),
  expandir = lifecycle::deprecated(),
  normalizar = lifecycle::deprecated(),
  descripcion_completa = lifecycle::deprecated()
)
```

## Arguments

- code:

  Character vector de códigos (ej. "E11", "E11.0", c("E11.0", "Z00")) o
  rango (ej. "E10-E14"). Acepta vectores. Soporta formatos: con punto
  (E11.0), sin punto (E110), o solo categoría (E11).

- expand:

  Logical, expandir jerarquía completa (default FALSE)

- normalize:

  Logical, normalizar formato de códigos automáticamente (default TRUE)

- full_description:

  Logical, agregar columna `descripcion_completa` con formato "CODIGO -
  DESCRIPCION" (default FALSE)

- extract:

  Logical, extraer código CIE-10 de texto con prefijos/sufijos (default
  FALSE). IMPORTANTE: Solo usar con código ESCALAR (longitud 1).
  Ejemplo: "CIE:E11.0" -\> "E11.0", "E11.0-confirmado" -\> "E11.0". Para
  vectores múltiples usar extract=FALSE (default).

- check_siglas:

  Logical, buscar siglas médicas comunes (default FALSE). Ejemplo: "IAM"
  -\> I21.0 (Infarto agudo miocardio)

- include_uso_cl:

  Logical, incluir columna `uso_cl` en el output (default TRUE). El
  default difiere de
  [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
  (FALSE) para preservar el contrato histórico de cada función. Valores
  posibles: `"principal"`, `"legado"`, `"causa_externa"`,
  `"etiologico"`, `"causa_externa | principal"`.

- only_uso_cl:

  Logical, filtrar a códigos vigentes de uso clínico en Chile (default
  FALSE). Cuando es TRUE, excluye los códigos con `uso_cl == "legado"`
  (es decir, conserva `principal`, `causa_externa`, `etiologico` y sus
  combinaciones).

- codigo:

  **\[deprecated\]** Use `code`.

- expandir:

  **\[deprecated\]** Use `expand`.

- normalizar:

  **\[deprecated\]** Use `normalize`.

- descripcion_completa:

  **\[deprecated\]** Use `full_description`.

## Value

tibble con codigo(s) matcheado(s)

## See also

[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md),
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md)

Other search:
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)

## Examples

``` r
# Búsqueda directa por código
cie_lookup("E11.0")
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>

cie_lookup("E110") # Sin punto
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
cie_lookup("E11") # Solo categoría
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11    Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
cie_lookup("E11", expand = TRUE) # Todos E11.x
#> # A tibble: 11 × 11
#>    codigo descripcion      categoria seccion capitulo_nombre inclusion exclusion
#>    <chr>  <chr>            <chr>     <chr>   <chr>           <chr>     <chr>    
#>  1 E11    Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  2 E11.0  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  3 E11.1  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  4 E11.2  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  5 E11.3  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  6 E11.4  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  7 E11.5  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  8 E11.6  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  9 E11.7  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 10 E11.8  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 11 E11.9  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
# Vectorizado - múltiples códigos y formatos
cie_lookup(c("E11.0", "Z00", "I10"))
#> # A tibble: 3 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 2 I10    Hipertensión ese… I10 HIPE… I10-I1… Cap.09  ENFERM… NA        NA       
#> 3 Z00    Examen general e… Z00 EXAM… Z00-Z1… Cap.21  FACTOR… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
# Con descripción completa
cie_lookup("E110", full_description = TRUE)
#> # A tibble: 1 × 12
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 5 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>, descripcion_completa <chr>
# Extraer código de texto con ruido (solo código escalar)
cie_lookup("CIE:E11.0", extract = TRUE)
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
cie_lookup("E11.0-confirmado", extract = TRUE)
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
# Buscar por siglas médicas
cie_lookup("IAM", check_siglas = TRUE)
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 I21    Infarto agudo de… I21 INFA… I20-I2… Cap.09  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
cie_lookup("DM2", check_siglas = TRUE)
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E10.0  Diabetes mellitu… E10 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
# Filtrar a códigos vigentes de uso clínico Chile (excluye 'legado')
cie_lookup("E11", expand = TRUE, only_uso_cl = TRUE)
#> # A tibble: 10 × 11
#>    codigo descripcion      categoria seccion capitulo_nombre inclusion exclusion
#>    <chr>  <chr>            <chr>     <chr>   <chr>           <chr>     <chr>    
#>  1 E11.0  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  2 E11.1  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  3 E11.2  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  4 E11.3  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  5 E11.4  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  6 E11.5  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  7 E11.6  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  8 E11.7  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  9 E11.8  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 10 E11.9  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
# Omitir columna uso_cl en el output
cie_lookup("E11.0", include_uso_cl = FALSE)
#> # A tibble: 1 × 10
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 3 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>
```
