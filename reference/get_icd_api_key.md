# Obtener la API key de la OMS desde el entorno

Lee la variable de entorno `ICD_API_KEY` y aborta con un error
informativo si no está configurada. Es el valor por defecto del
argumento `api_key` de
[`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md),
siguiendo el patrón recomendado por httr2 para envolver APIs.

## Usage

``` r
get_icd_api_key()
```

## Value

String con la API key en formato "client_id:client_secret".

## Details

Configura la variable editando `~/.Renviron` con
`usethis::edit_r_environ()`:

    ICD_API_KEY=tu_client_id:tu_client_secret

Nunca escribas la llave literal en scripts que vayas a compartir.

## See also

[`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)

Other api_who:
[`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)

## Examples

``` r
# Requiere ICD_API_KEY configurada (ver Details)
try(get_icd_api_key())
#> Error in eval(expr, envir) : 
#>   API key OMS requerida. Ver: <https://icd.who.int/icdapi>
```
