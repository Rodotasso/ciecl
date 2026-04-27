# Normalizar codigos CIE-10 (deprecated)

**\[deprecated\]**

## Usage

``` r
cie_normalizar(codigos, buscar_db = TRUE)
```

## Arguments

- codigos:

  Character vector de codigos

- buscar_db:

  Logical, buscar codigo en DB (default TRUE)

## Value

Character vector con codigos normalizados

## Details

Alias en espanol de
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md).
Se mantiene por compatibilidad con codigo existente en CRAN. Usar
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
en codigo nuevo.

## See also

Other validacion:
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md),
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md),
[`cie_validate_vector()`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Deprecated: usar cie_norm()
cie_normalizar("E110")
} # }
```
