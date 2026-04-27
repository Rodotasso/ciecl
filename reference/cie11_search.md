# Buscar codigos CIE-11 via API OMS

Buscar codigos CIE-11 via API OMS

## Usage

``` r
cie11_search(
  text,
  api_key = NULL,
  lang = "es",
  max_results = 10,
  release = "2024-01",
  texto = lifecycle::deprecated()
)
```

## Arguments

- text:

  String termino busqueda espanol/ingles

- api_key:

  String opcional, Client ID + Secret OMS separados ":" Obtener en:
  https://icd.who.int/icdapi

- lang:

  Character, idioma respuesta ("es" o "en")

- max_results:

  Integer, maximo resultados (default 10)

- release:

  Character, version de release CIE-11 a consultar (default "2024-01").
  Ver releases disponibles en la API OMS.

- texto:

  **\[deprecated\]** Use `text`.

## Value

tibble con codigos CIE-11 + titulos o vacio si error

## See also

[`cie_search`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)

## Examples

``` r
# Ver parametros disponibles
args(cie11_search)
#> function (text, api_key = NULL, lang = "es", max_results = 10, 
#>     release = "2024-01", texto = lifecycle::deprecated()) 
#> NULL

# \donttest{
# Requiere credenciales OMS gratuitas (https://icd.who.int/icdapi)
Sys.setenv(ICD_API_KEY = "client_id:client_secret")
cie11_search("depresion mayor")
#> Warning: Error API CIE-11: HTTP 400 Bad Request.
#> Retornando resultado vacio. Usa cie_search() para fallback local CIE-10
#> # A tibble: 0 × 3
#> # ℹ 3 variables: codigo <chr>, titulo <chr>, capitulo <chr>
# }
```
