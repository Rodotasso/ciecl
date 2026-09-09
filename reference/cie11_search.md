# Buscar códigos CIE-11 vía API OMS

Buscar códigos CIE-11 vía API OMS

## Usage

``` r
cie11_search(
  text,
  api_key = get_icd_api_key(),
  lang = c("es", "en"),
  max_results = 10,
  release = "2024-01",
  texto = lifecycle::deprecated()
)
```

## Arguments

- text:

  String término búsqueda español/inglés

- api_key:

  String opcional, Client ID + Secret OMS separados ":". Por defecto se
  lee desde la variable de entorno `ICD_API_KEY` vía
  [`get_icd_api_key()`](https://rodotasso.github.io/ciecl/reference/get_icd_api_key.md).
  Obtener credenciales en: https://icd.who.int/icdapi

- lang:

  Character, idioma respuesta ("es" o "en")

- max_results:

  Integer, máximo resultados (default 10)

- release:

  Character, versión de release CIE-11 a consultar (default "2024-01").
  Ver releases disponibles en la API OMS.

- texto:

  **\[deprecated\]** Use `text`.

## Value

tibble con códigos CIE-11 + títulos o vacío si error

## Details

### Seguridad de la API key

NUNCA escribas la llave literal en tus scripts (p. ej.
`api_key = "tu_id:tu_secret"`): si compartes el código (repositorios,
correos, capturas) expondrías tus credenciales de forma accidental.

La vía recomendada es guardar la llave en la variable de entorno
`ICD_API_KEY`, por ejemplo editando `~/.Renviron` con
`usethis::edit_r_environ()`;
[`get_icd_api_key()`](https://rodotasso.github.io/ciecl/reference/get_icd_api_key.md)
la lee automáticamente.

El argumento `api_key` existe solo para circunstancias excepcionales (p.
ej. manejar múltiples llaves, o entornos donde no es posible fijar una
variable de entorno).

## See also

[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md)

Other api_who:
[`get_icd_api_key()`](https://rodotasso.github.io/ciecl/reference/get_icd_api_key.md)

## Examples

``` r
# Ver parámetros disponibles
args(cie11_search)
#> function (text, api_key = get_icd_api_key(), lang = c("es", "en"), 
#>     max_results = 10, release = "2024-01", texto = lifecycle::deprecated()) 
#> NULL

# Requiere credenciales OMS gratuitas (https://icd.who.int/icdapi)
cie11_search("depresion mayor")
#> # A tibble: 10 × 3
#>    codigo titulo                                                        capitulo
#>    <chr>  <chr>                                                         <chr>   
#>  1 6A70.3 Trastorno depresivo, episodio único grave sin síntomas psicó… 06      
#>  2 6A7Z   Trastornos depresivos, sin especificación                     06      
#>  3 MB24.5 Estado de ánimo deprimido                                     21      
#>  4 6A72   Trastorno distímico                                           06      
#>  5 6A70.4 Trastorno depresivo, episodio único grave con síntomas psicó… 06      
#>  6 6A71.1 Trastorno depresivo recurrente, episodio actual moderado sin… 06      
#>  7 6A71.Z Trastorno depresivo recurrente, sin especificación            06      
#>  8 6A71.7 Trastorno depresivo recurrente, actualmente en remisión comp… 06      
#>  9 MB47.Y Otra alteración especificada del tono muscular y los reflejos 21      
#> 10 6A70.Z Trastorno depresivo de episodio único, sin especificación     06      
# Causas frecuentes de egreso en Chile
cie11_search("diabetes mellitus")
#> # A tibble: 10 × 3
#>    codigo  titulo                                                       capitulo
#>    <chr>   <chr>                                                        <chr>   
#>  1 5A14    Diabetes mellitus, tipo no especificado                      05      
#>  2 5A13    Diabetes mellitus, otro tipo especificado                    05      
#>  3 5A13.Y  Otra diabetes mellitus especificada, otro tipo especificado  05      
#>  4 JA63.Z  Diabetes mellitus en el embarazo, sin especificación         18      
#>  5 JA63.2  Diabetes mellitus que aparece por primera vez en el embarazo 18      
#>  6 KB60.2Z Diabetes mellitus neonatal, sin especificación               19      
#>  7 KB60.2Y Otra diabetes mellitus neonatal especificada                 19      
#>  8 5A10    Diabetes mellitus tipo 1                                     05      
#>  9 5A11    Diabetes mellitus tipo 2                                     05      
#> 10 5A12    Diabetes mellitus por malnutrición                           05      
cie11_search("hipertension esencial")
#> # A tibble: 10 × 3
#>    codigo  titulo                                      capitulo
#>    <chr>   <chr>                                       <chr>   
#>  1 BA00.Z  Hipertensión esencial, sin especificación   11      
#>  2 BA00.Y  Otra hipertensión esencial especificada     11      
#>  3 KB45    Hipertensión neonatal                       19      
#>  4 JA23    Hipertensión gestacional                    18      
#>  5 BA04.Z  Hipertensión secundaria, sin especificación 11      
#>  6 BA04.Y  Otra hipertension secundaria especificada   11      
#>  7 9C61.01 Hipertensión ocular                         09      
#>  8 DB98.7Z Hipertensión portal, sin especificación     13      
#>  9 DB98.7Y Otra hipertensión portal especificada       13      
#> 10 BA00.2  Hipertensión sistólica aislada              11      
```
