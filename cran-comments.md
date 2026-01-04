# Comentarios para desarrollo y futura submission CRAN

> **NOTA**: Este paquete esta actualmente en version BETA (v0.1.0).
> No esta listo para submission a CRAN todavia.

## Test environments
* local R installation, R 4.4.3
* Windows 11 x64 (build 26100)
* GitHub Actions (windows-latest, macOS-latest, ubuntu-latest): R-release, R-devel, R-oldrel

## R CMD check results

0 errors | 0 warnings | 0 notes (objetivo)

### Verificaciones realizadas:

1. **R CMD check --as-cran**: Sin errores ni warnings
2. **GitHub Actions**: Todas las plataformas configuradas
3. **Ejemplos**: Todos ejecutables o correctamente documentados con \dontrun{}
4. **Tests**: Tests unitarios con testthat (skip_on_cran donde corresponde)
5. **Dependencias**: Minimas (8 imports), documentadas correctamente
6. **Vignette**: Incluida y funcional

## Notas especiales para futura revision CRAN

### Datos publicos
Este paquete utiliza datos publicos del Ministerio de Salud de Chile (MINSAL/DEIS)
disponibles en:
- Centro FIC: https://deis.minsal.cl/centrofic/
- Repositorio: https://repositoriodeis.minsal.cl

Los datos CIE-10 son de uso publico segun el Decreto 356 Exento (2017) del
Ministerio de Salud que establece el uso oficial de la CIE-10 en Chile.
Referencia legal: https://www.bcn.cl/leychile/navegar?i=1112064

El dataset incluye **39,873 codigos** CIE-10 (categorias y subcategorias).
Los datos estan incluidos en el paquete (data/cie10_cl.rda).

### Cache local
El paquete crea opcionalmente una base de datos SQLite en el directorio de cache del usuario
usando `tools::R_user_dir("ciecl", "data")` segun las recomendaciones de CRAN.
Los tests incluyen `skip_on_cran()` para evitar la creacion de archivos durante el check.

### API externa (opcional)
La funcion `cie11_search()` accede a la API de la OMS (https://icd.who.int/icdapi).
Esto es completamente opcional y requiere credenciales del usuario.
La funcion falla gracefully si no hay credenciales.
Los ejemplos estan en `\dontrun{}` para no requerir conexion a internet.

### Idioma
El paquete esta en espanol (`Language: es` en DESCRIPTION) porque:
- Los datos CIE-10 oficiales de Chile estan en espanol
- El publico objetivo son profesionales de salud en Chile y Latinoamerica
- Toda la documentacion medica esta en espanol

## Estado beta

Este paquete esta en fase beta de desarrollo. Se recomienda:
- Probar exhaustivamente antes de usar en produccion
- Reportar errores en: https://github.com/RodoTasso/ciecl/issues
- La API puede cambiar antes de la version 1.0.0

## Downstream dependencies

No existen dependencias downstream conocidas (paquete nuevo).

## Repositorio y colaboracion

- GitHub repository: https://github.com/RodoTasso/ciecl
- CI/CD: GitHub Actions configurado
- Documentacion completa en README y vignette
