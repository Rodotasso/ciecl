# Normalizar códigos CIE-10 a formato con punto

Convierte códigos CIE-10 de diferentes formatos al formato estándar (con
punto). Maneja múltiples variaciones de entrada comunes en datos
clínicos.

## Usage

``` r
cie_norm(
  codes,
  search_db = TRUE,
  codigos = lifecycle::deprecated(),
  buscar_db = lifecycle::deprecated()
)

cie_normalize(
  codes,
  search_db = TRUE,
  codigos = lifecycle::deprecated(),
  buscar_db = lifecycle::deprecated()
)
```

## Arguments

- codes:

  Character vector de códigos en cualquier formato

- search_db:

  Logical, buscar código en base de datos si no se encuentra exacto
  (default TRUE)

- codigos:

  **\[deprecated\]** Use `codes`.

- buscar_db:

  **\[deprecated\]** Use `search_db`.

## Value

Character vector con códigos normalizados al formato con punto

## Details

La normalización incluye:

- Conversión a mayúsculas

- Eliminación de espacios (inicio, fin e internos)

- Eliminación de símbolos daga y asterisco (codificación dual)

- Conversión de guiones a puntos (I10-0 -\> I10.0)

- Eliminación de puntos iniciales (.I10 -\> I10)

- Corrección de puntos múltiples (E..11 -\> E.11)

- Eliminación de sufijo X en códigos cortos (I10X -\> I10)

- Preservación de X en códigos largos (placeholder 7o carácter)

- Agregado de punto en posición correcta (E110 -\> E11.0)

El sistema de daga/asterisco indica codificación dual donde la daga
marca la enfermedad subyacente y el asterisco la manifestación. Ambos
símbolos se eliminan para normalización.

## See also

[`cie_validate_vector()`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md),
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md)

Other validacion:
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md),
[`cie_normalizar()`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md),
[`cie_validate_vector()`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md)

## Examples

``` r
cie_norm("E110")     # Retorna "E11.0"
#> [1] "E11.0"
cie_norm("E11")      # Retorna "E11" (categoría)
#> [1] "E11"
cie_norm("I10X")     # Retorna "I10" (elimina X)
#> [1] "I10"
cie_norm("E 11 0")   # Retorna "E11.0" (espacios internos)
#> [1] "E11.0"
cie_norm("I10-0")    # Retorna "I10.0" (guion a punto)
#> [1] "I10.0"
cie_norm(paste0("A17.0", intToUtf8(0x2020)))  # "A17.0" (elimina daga)
#> [1] "A17.0"
cie_norm("G01*")                              # "G01"   (elimina asterisco)
#> [1] "G01"
cie_norm(c("E110", "I10X", "Z00"))  # Vectorizado
#> [1] "E11.0" "I10"   "Z00"  
```
