# Normalizar códigos CIE-10 (deprecated)

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

  **\[deprecated\]** Character vector de códigos. Use
  [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
  con `codes` en código nuevo.

- buscar_db:

  **\[deprecated\]** Logical, buscar código en DB (default TRUE). Use
  [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
  con `search_db` en código nuevo.

## Value

Character vector con códigos normalizados

## Details

Alias en español de
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md).
Se mantiene por compatibilidad con código existente en CRAN. Usar
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
en código nuevo.

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
