# Generar tabla HTML interactiva GT de codigo CIE-10

Generar tabla HTML interactiva GT de codigo CIE-10

## Usage

``` r
cie_table(codigo)
```

## Arguments

- codigo:

  String codigo (ej. "E11" muestra jerarquia)

## Value

Objeto de clase `gt_tbl` (tabla HTML interactiva)

## See also

[`cie_search`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

## Examples

``` r
# Requiere paquete gt
requireNamespace("gt", quietly = TRUE)

# \donttest{
cie_table("E11")  # Diabetes tipo 2 completo


  


CIE-10 Chile: E11
```

Fuente: MINSAL/DEIS v2018

Codigo

Diagnostico

Incluye

Excluye

E11

Diabetes mellitus no insulinodependiente

NA

NA

E11.0

Diabetes mellitus tipo 2 con coma

NA

NA

E11.1

Diabetes mellitus tipo 2 con cetoacidosis

NA

NA

E11.2

Diabetes mellitus tipo 2 con complicaciones renales

NA

NA

E11.3

Diabetes mellitus tipo 2 con complicaciones oftálmicas

NA

NA

E11.4

Diabetes mellitus tipo 2 con complicaciones neurológicas

NA

NA

E11.5

Diabetes mellitus tipo 2 con complicaciones circulatorias periféricas

NA

NA

E11.6

Diabetes mellitus tipo 2 con otras complicaciones especificadas

NA

NA

E11.7

Diabetes mellitus tipo 2 con complicaciones múltiples

NA

NA

E11.8

Diabetes mellitus tipo 2 con complicaciones no especificadas

NA

NA

E11.9

Diabetes mellitus tipo 2 sin complicaciones

NA

NA

\# }
