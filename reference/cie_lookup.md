# Busqueda exacta por codigo CIE-10

Busqueda exacta por codigo CIE-10

## Usage

``` r
cie_lookup(
  code,
  expand = FALSE,
  normalize = TRUE,
  full_description = FALSE,
  extract = FALSE,
  check_siglas = FALSE,
  codigo = lifecycle::deprecated(),
  expandir = lifecycle::deprecated(),
  normalizar = lifecycle::deprecated(),
  descripcion_completa = lifecycle::deprecated()
)
```

## Arguments

- code:

  Character vector de codigos (ej. "E11", "E11.0", c("E11.0", "Z00")) o
  rango (ej. "E10-E14"). Acepta vectores. Soporta formatos: con punto
  (E11.0), sin punto (E110), o solo categoria (E11).

- expand:

  Logical, expandir jerarquia completa (default FALSE)

- normalize:

  Logical, normalizar formato de codigos automaticamente (default TRUE)

- full_description:

  Logical, agregar columna `descripcion_completa` con formato "CODIGO -
  DESCRIPCION" (default FALSE)

- extract:

  Logical, extraer codigo CIE-10 de texto con prefijos/sufijos (default
  FALSE). IMPORTANTE: Solo usar con codigo ESCALAR (longitud 1).
  Ejemplo: "CIE:E11.0" -\> "E11.0", "E11.0-confirmado" -\> "E11.0". Para
  vectores multiples usar extract=FALSE (default).

- check_siglas:

  Logical, buscar siglas medicas comunes (default FALSE). Ejemplo: "IAM"
  -\> I21.0 (Infarto agudo miocardio)

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
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md)

Other busqueda:
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md),
[`cie_siglas()`](https://rodotasso.github.io/ciecl/reference/cie_siglas.md)

## Examples

``` r
# Busqueda directa por codigo
cie_lookup("E11.0")
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>

if (FALSE) { # interactive()
cie_lookup("E110")        # Sin punto
cie_lookup("E11")         # Solo categoria
cie_lookup("E11", expand = TRUE)  # Todos E11.x
# Vectorizado - multiples codigos y formatos
cie_lookup(c("E11.0", "Z00", "I10"))
# Con descripcion completa
cie_lookup("E110", full_description = TRUE)
# Extraer codigo de texto con ruido (solo codigo escalar)
cie_lookup("CIE:E11.0", extract = TRUE)
cie_lookup("E11.0-confirmado", extract = TRUE)
# Buscar por siglas medicas
cie_lookup("IAM", check_siglas = TRUE)
cie_lookup("DM2", check_siglas = TRUE)
}
```
