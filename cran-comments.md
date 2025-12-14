# Comentarios para submission CRAN

## Test environments
* local R installation, R 4.3.0
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notas especiales

Este paquete utiliza datos publicos del Ministerio de Salud de Chile (MINSAL/DEIS)
disponibles en https://repositoriodeis.minsal.cl bajo Decreto 356/2017 (datos abiertos).

El paquete crea una base de datos SQLite en el directorio de cache del usuario
usando tools::R_user_dir("ciecl", "data") segun las recomendaciones de CRAN.

Los tests incluyen skip_on_cran() para evitar la creacion de archivos durante
el check de CRAN.

## Downstream dependencies

No existen dependencias downstream conocidas.
