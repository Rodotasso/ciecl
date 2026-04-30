# Validar vector de codigos CIE-10 formato

Validar vector de codigos CIE-10 formato

## Usage

``` r
cie_validate_vector(codes, strict = FALSE, codigos = lifecycle::deprecated())
```

## Arguments

- codes:

  Character vector codigos (ej. c("E11.0", "Z00.0"))

- strict:

  Logical, validar existencia en DB (default FALSE)

- codigos:

  **\[deprecated\]** Use `codes`.

## Value

Logical vector de la misma longitud que `codes`. TRUE si el codigo tiene
formato CIE-10 valido (y existe en DB si `strict = TRUE`).

## See also

[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md),
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md)

Other validacion:
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md),
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md),
[`cie_normalizar()`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md)

## Examples

``` r
cie_validate_vector(c("E11.0", "INVALIDO", "Z00"))
#> [1]  TRUE FALSE  TRUE
```
