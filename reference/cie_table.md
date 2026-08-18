# Generar tabla HTML interactiva GT de código CIE-10

Muestra la jerarquía de un código CIE-10 (categoría + subcategorías)
como una tabla `gt`. Las columnas "Incluye" y "Excluye" pueden aparecer
vacías en subcategorías: el catálogo MINSAL/DEIS no puebla esos campos
en todos los niveles (suelen estar solo en la categoría de 3 dígitos).
Para evitar confusión visual, los `NA` se reemplazan por un guion largo
(em dash).

## Usage

``` r
cie_table(code, codigo = lifecycle::deprecated())
```

## Arguments

- code:

  String código (ej. `"E11"` muestra la jerarquía).

- codigo:

  **\[deprecated\]** Use `code`.

## Value

Objeto de clase `gt_tbl` (tabla HTML interactiva).

## See also

[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md)

## Examples

``` r
cie_table("E11")  # Diabetes mellitus tipo 2 completo


  


CIE-10 Chile: E11
```
