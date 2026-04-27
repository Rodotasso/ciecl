# Obtener descripcion de codigos CIE-10 (vector)

Devuelve un vector character con la descripcion de cada codigo, pensado
para usar dentro de
[`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
sin necesidad de un `left_join` contra `cie10_cl`.

## Usage

``` r
cie_describe(
  codes,
  normalize = FALSE,
  default = NA_character_,
  codigos = lifecycle::deprecated()
)
```

## Arguments

- codes:

  Character vector de codigos CIE-10 (ej. "E11.0", c("E11.0", "I10")).

- normalize:

  Logical, ¿intentar normalizar los codigos antes de buscar la
  descripcion? (default FALSE). Usar TRUE para limpiar formatos (ej.
  "E110" -\> "E11.0"); usar FALSE para auditar la calidad original del
  registro.

- default:

  Valor devuelto cuando un codigo no se encuentra en el catalogo.
  Default `NA_character_`.

- codigos:

  **\[deprecated\]** Use `codes`.

## Value

Character vector del mismo largo que `codes` con la descripcion oficial
MINSAL/DEIS. `NA_character_` (o `default`) para codigos sin match.

## See also

[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
para resultado como tibble con todas las columnas;
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
para normalizacion.

Other busqueda:
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md),
[`cie_siglas()`](https://rodotasso.github.io/ciecl/reference/cie_siglas.md)

## Examples

``` r
# Auditoria: buscar tal cual (E110 no existe sin punto)
cie_describe("E110", normalize = FALSE)
#> [1] NA

# Rescate: normalizar antes de buscar
cie_describe("E110", normalize = TRUE)
#> [1] "Diabetes mellitus tipo 2 con coma"

# \donttest{
# Uso tipico en auditoria VIU (contar fallos de origen)
diags <- c("E11.0", "E110", "I10X", "INVALIDO")
descripciones <- cie_describe(diags, normalize = FALSE)
sum(is.na(descripciones)) # Detecta 3 errores de registro
#> [1] 3
# }
```
