# Listar siglas medicas (deprecated)

**\[deprecated\]** Use
[`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md).

## Usage

``` r
cie_siglas(categoria = NULL)
```

## Arguments

- categoria:

  Character opcional, filtrar por categoria

## Value

tibble con columnas: sigla, termino_busqueda, categoria

## See also

Other busqueda:
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
[`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Deprecated: usar cie_short()
cie_siglas()
} # }
```
