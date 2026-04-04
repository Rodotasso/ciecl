# Normalizar codigos CIE-10 a formato con punto

Convierte codigos CIE-10 de diferentes formatos al formato estandar (con
punto). Maneja multiples variaciones de entrada comunes en datos
clinicos.

## Usage

``` r
cie_normalizar(codigos, buscar_db = TRUE)
```

## Arguments

- codigos:

  Character vector de codigos en cualquier formato

- buscar_db:

  Logical, buscar codigo en base de datos si no se encuentra exacto
  (default TRUE)

## Value

Character vector con codigos normalizados al formato con punto

## Details

La normalizacion incluye:

- Conversion a mayusculas

- Eliminacion de espacios (inicio, fin e internos)

- Eliminacion de simbolos daga y asterisco (codificacion dual)

- Conversion de guiones a puntos (I10-0 -\> I10.0)

- Eliminacion de puntos iniciales (.I10 -\> I10)

- Correccion de puntos multiples (E..11 -\> E.11)

- Eliminacion de sufijo X en codigos cortos (I10X -\> I10)

- Preservacion de X en codigos largos (placeholder 7o caracter)

- Agregado de punto en posicion correcta (E110 -\> E11.0)

El sistema de daga/asterisco indica codificacion dual donde la daga
marca la enfermedad subyacente y el asterisco la manifestacion. Ambos
simbolos se eliminan para normalizacion.

## See also

[`cie_validate_vector`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md),
[`cie_expand`](https://rodotasso.github.io/ciecl/reference/cie_expand.md),
[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

Other validacion:
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md),
[`cie_validate_vector()`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md)

## Examples

``` r
cie_normalizar("E110")     # Retorna "E11.0"
#> [1] "E11.0"
cie_normalizar("E11")      # Retorna "E11" (categoria)
#> [1] "E11"
cie_normalizar("I10X")     # Retorna "I10" (elimina X)
#> [1] "I10"
cie_normalizar("E 11 0")   # Retorna "E11.0" (espacios internos)
#> [1] "E11.0"
cie_normalizar("I10-0")    # Retorna "I10.0" (guion a punto)
#> [1] "I10.0"
cie_normalizar("A17.0\u2020") # Retorna "A17.0" (elimina daga)
#> [1] "A17.0"
cie_normalizar("G01*")     # Retorna "G01" (elimina asterisco)
#> [1] "G01"
cie_normalizar(c("E110", "I10X", "Z00"))  # Vectorizado
#> [1] "E11.0" "I10"   "Z00"  
```
