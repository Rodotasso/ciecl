# Normalizar codigos CIE-10 (deprecated)

**\[deprecated\]**

## Usage

``` r
cie_normalizar(
  codigos = lifecycle::deprecated(),
  buscar_db = lifecycle::deprecated()
)
```

## Arguments

- codigos:

  **\[deprecated\]** Character vector de codigos. Use
  [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
  con `codes` en codigo nuevo.

- buscar_db:

  **\[deprecated\]** Logical, buscar codigo en DB (default TRUE). Use
  [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
  con `search_db` en codigo nuevo.

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
# Deprecated: usar cie_norm()
cie_normalizar("E110")
#> Warning: `cie_normalizar()` was deprecated in ciecl 0.9.8.
#> ℹ Please use `cie_norm()` instead.
#> [1] "E11.0"
```
