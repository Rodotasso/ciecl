# Validar vector de codigos CIE-10 formato

Validar vector de codigos CIE-10 formato

## Usage

``` r
cie_validate_vector(codigos, strict = FALSE)
```

## Arguments

- codigos:

  Character vector codigos (ej. c("E11.0", "Z00.0"))

- strict:

  Logical, validar existencia en DB (default FALSE)

## Value

Logical vector de la misma longitud que `codigos`. TRUE si el codigo
tiene formato CIE-10 valido (y existe en DB si `strict = TRUE`).

## See also

[`cie_normalizar`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md),
[`cie_expand`](https://rodotasso.github.io/ciecl/reference/cie_expand.md)

Other validacion:
[`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md),
[`cie_normalizar()`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md)

## Examples

``` r
cie_validate_vector(c("E11.0", "INVALIDO", "Z00"))
#> [1]  TRUE FALSE  TRUE
```
