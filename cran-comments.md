# Comentarios para submission CRAN

## Test environments
* local R installation, R 4.4.3
* Windows 11 x64 (build 26100)
* GitHub Actions (windows-latest, macOS-latest, ubuntu-latest): R-release, R-devel, R-oldrel
* win-builder (release, devel, oldrelease)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

### Verificaciones realizadas:

1. **R CMD check --as-cran**: Sin errores, warnings ni notas
2. **GitHub Actions**: Todas las plataformas pasan exitosamente
3. **Ejemplos**: Todos ejecutables o correctamente documentados con \dontrun{}
4. **Tests**: 34 tests, todos pasan (skip_on_cran donde corresponde)
5. **Dependencias**: Minimas (6 imports), documentadas correctamente
6. **Viñeta**: Incluida y funcional

## Notas especiales para revisores CRAN

### Datos publicos
Este paquete utiliza datos publicos del Ministerio de Salud de Chile (MINSAL/DEIS)
disponibles en https://repositoriodeis.minsal.cl bajo Decreto 356/2017 (datos abiertos).
Los datos estan incluidos en el paquete (data/cie10_cl.rda, ~280KB).

### Cache local
El paquete crea opcionalmente una base de datos SQLite en el directorio de cache del usuario
usando `tools::R_user_dir("ciecl", "cache")` segun las recomendaciones de CRAN.
Los tests incluyen `skip_on_cran()` para evitar la creacion de archivos durante el check.

### API externa (opcional)
La funcion `cie11_search()` accede a la API de la OMS (https://icd.who.int/icdapi).
Esto es completamente opcional y requiere credenciales del usuario.
La funcion falla gracefully si no hay credenciales.
Los ejemplos estan en `\dontrun{}` para no requerir conexion a internet.

### Idioma
El paquete esta en español (`Language: es` en DESCRIPTION) porque:
- Los datos CIE-10 oficiales de Chile estan en español
- El publico objetivo son profesionales de salud en Chile y Latinoamerica
- Toda la documentacion medica esta en español

## Downstream dependencies

No existen dependencias downstream conocidas (primera submission).

## Preparacion para colaboradores

- GitHub repository: https://github.com/RodoTasso/ciecl
- CI/CD: GitHub Actions configurado
- Cobertura de tests: >80%
- Documentacion completa en README y viñeta
