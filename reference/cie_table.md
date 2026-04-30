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

[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

## Examples

``` r
cie_table("E11")  # Diabetes mellitus tipo 2 completo


  


CIE-10 Chile: E11
```
