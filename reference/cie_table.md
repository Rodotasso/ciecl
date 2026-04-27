# Generar tabla HTML interactiva GT de codigo CIE-10

Muestra la jerarquia de un codigo CIE-10 (categoria + subcategorias)
como una tabla `gt`. Las columnas "Incluye" y "Excluye" pueden aparecer
vacias en subcategorias: el catalogo MINSAL/DEIS no puebla esos campos
en todos los niveles (suelen estar solo en la categoria de 3 digitos).
Para evitar confusion visual, los `NA` se reemplazan por un guion largo
(em dash).

## Usage

``` r
cie_table(code, codigo = lifecycle::deprecated())
```

## Arguments

- code:

  String codigo (ej. `"E11"` muestra la jerarquia).

- codigo:

  **\[deprecated\]** Use `code`.

## Value

Objeto de clase `gt_tbl` (tabla HTML interactiva).

## See also

[`cie_search`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

## Examples

``` r
# \donttest{
if (requireNamespace("gt", quietly = TRUE)) {
  cie_table("E11")  # Diabetes mellitus tipo 2 completo
}


  


CIE-10 Chile: E11
```

Fuente: MINSAL/DEIS v2018

Codigo

Diagnostico

E11

Diabetes mellitus no insulinodependiente

E11.0

Diabetes mellitus tipo 2 con coma

E11.1

Diabetes mellitus tipo 2 con cetoacidosis

E11.2

Diabetes mellitus tipo 2 con complicaciones renales

E11.3

Diabetes mellitus tipo 2 con complicaciones oftálmicas

E11.4

Diabetes mellitus tipo 2 con complicaciones neurológicas

E11.5

Diabetes mellitus tipo 2 con complicaciones circulatorias periféricas

E11.6

Diabetes mellitus tipo 2 con otras complicaciones especificadas

E11.7

Diabetes mellitus tipo 2 con complicaciones múltiples

E11.8

Diabetes mellitus tipo 2 con complicaciones no especificadas

E11.9

Diabetes mellitus tipo 2 sin complicaciones

\# }
