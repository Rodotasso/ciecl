# Expandir codigo jerarquico (ej. E11 -\> E11.0-E11.9)

Expandir codigo jerarquico (ej. E11 -\> E11.0-E11.9)

## Usage

``` r
cie_expand(codigo)
```

## Arguments

- codigo:

  String codigo padre (ej. "E11")

## Value

Character vector con todos los codigos hijos del codigo padre. Vector
vacio si el codigo no existe en la base de datos.

## See also

[`cie_normalizar`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md),
[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

Other validacion:
[`cie_normalizar()`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md),
[`cie_validate_vector()`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md)

## Examples

``` r
cie_expand("E11")
#>  [1] "E11"   "E11.0" "E11.1" "E11.2" "E11.3" "E11.4" "E11.5" "E11.6" "E11.7"
#> [10] "E11.8" "E11.9"
```
