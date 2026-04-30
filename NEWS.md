# ciecl 0.9.8 (2026-04-25)

*English summary below*

## Respuesta a Revisión rOpenSci (rev-ropensci)

Versión de cumplimiento editorial y técnico tras la revisión de Maëlle Salmon.
Esta versión unifica la interfaz del paquete bajo estándares internacionales de R,
manteniendo la documentación pedagógica en español para el contexto local.

### Cambios que rompen compatibilidad (Deprecaciones)

* **Internacionalización de la API**: Todos los argumentos de las funciones
  públicas han sido migrados al inglés para consistencia con el ecosistema
  tidyverse (dplyr, httr2). Los argumentos antiguos en español emiten
  `lifecycle::deprecate_warn()` y serán eliminados en la versión 1.0.0.
  
  - `cie_lookup()`: `codigo` -> `code`, `expandir` -> `expand`, `normalizar` -> `normalize`.
  - `cie_search()`: `texto` -> `text`, `campo` -> `field`, `solo_fuzzy` -> `only_fuzzy`.
  - `cie_short()`: Reemplaza a `cie_siglas()`. Argumento `category`.

### Cambios internos

* El script generador del dataset (`generar_cie10_cl()`, `parsear_cie10_minsal()`) se movió a `data-raw/` siguiendo la convención de R packages. No afecta el uso del paquete: `data(cie10_cl)` sigue funcionando igual.
* Tests del generador trasladados a sanity-check ejecutable desde `data-raw/`.
* Eliminación masiva de `ciecl:::` en tests para favorecer `devtools::load_all()`.

  - `cie11_search()`: `texto` -> `text`.

* **Motor de Normalización Único**: Se establece `cie_norm()` como la función
  canónica. `cie_normalize()` y `cie_normalizar()` están ahora deprecadas.

### Nuevas funcionalidades

* **`cie_describe()`**: Nueva función vectorizada para obtener descripciones
  CIE-10 directamente, facilitando su uso dentro de `dplyr::mutate()` sin
  necesidad de cruces manuales.

### Auditoría Técnica (Compliance)

* **API Resiliente (CIE-11)**: Refactorización de `cie11_search()` usando
  `httr2` con mejores prácticas de consumo web:
  - Identificación clara mediante `User-Agent`.
  - Política de reintentos (`req_retry`) para fallas temporales.
  - Control de tasa (`req_throttle`) para respetar servidores de la OMS.
  - `httr2` promovido de Suggests a **Imports**.

* **Robustez de Tests**: Limpieza masiva de la suite de pruebas. Se eliminaron
  warnings de deprecación internos y se migró a `withr` para la gestión de
  variables de entorno.

### Documentación y Homologación

* **Guías en Espejo**: Creación de versiones en inglés de todas las guías de
  usuario (`Case Study`, `Installation Guide`) para consistencia en el sitio
  `pkgdown`.
* **README paramétrico**: Unificación de `README.Rmd` para generar versiones
  sincronizadas en español e inglés. El README principal es ahora en español.
* **Narrativa Profesional**: Redacción mejorada en todas las vignettes,
  eliminando tonos informales por un lenguaje técnico de ingeniería de datos.

## English Summary

### rOpenSci Review Response

Comprehensive update focused on API consistency and technical compliance 
following rOpenSci peer review.

* **Breaking Changes (Deprecations)**: Full API migration to English arguments
  (e.g., `code`, `expand`, `normalize`, `text`) using the `lifecycle` package.
  Old Spanish arguments remain functional but emit warnings.
* **Streamlined Normalization**: `cie_norm()` is now the single canonical
  normalization motor.
* **New Function**: Added `cie_describe()` for direct, vectorized description
  lookup within `mutate()` calls.
* **Technical Compliance**:
  - `cie11_search()` now uses `httr2` with User-Agent, retry, and throttle 
    policies.
  - `httr2` promoted to **Imports**.
  - Test suite cleaned of deprecation noise and updated to use `withr`.
* **Documentation**: Mirror versions of user guides provided in both 
  English and Spanish. `pkgdown` site navigation localized to Spanish.

---

# ciecl 0.9.6 (2026-04-04)

*English summary below*

## Preparacion rOpenSci

Version candidata para submission a rOpenSci. Cumple con rOpenSci Dev Guide
2025 (Capitulos 1, 5, 6, 20). R CMD check: 0 errors, 0 warnings.
Tests: 1148 PASS, 95.6% cobertura.

### Nuevas funcionalidades

* **Connection pooling SQLite**: Cache atomico con versionado en
  `get_cie10_db()`. Reutiliza conexiones activas, reconstruye si la
  BD esta corrupta o desactualizada.

* **Vectorizacion mejorada**: `cie_map_comorbid()` y `cie_normalizar()`
  refactorizados para procesamiento batch eficiente.

* **pkgdown site**: Tema limpio compatible con rOpenSci, modo oscuro
  (light-switch), logo hexagonal, favicons.

* **Vignette caso de uso**: `caso-uso-egresos` con datos simulados
  de egresos hospitalarios usando columnas esenciales DEIS.

### Documentacion y comunidad

* CONTRIBUTING.md y CODE_OF_CONDUCT.md bilingues (ingles + espanol)
* SECURITY.md bilingue
* PR template para rOpenSci
* `@family` y `@seealso` en todas las funciones exportadas
* Documentacion English-first con traducciones completas

### CI/CD

* GitHub Actions R-CMD-check multiplataforma (Windows, macOS, Ubuntu)
* Workflow de test coverage
* pkgdown deployment automatico desde main
* R-hub workflow

### Seguridad

* FTS5 parametros sanitizados contra inyeccion SQL
* Stripeo de comentarios SQL
* Validacion estricta de inputs en funciones publicas

### Fixes

* Estandarizar pipes a `%>%` (magrittr) en todo el paquete
* Corregir sintaxis invalida en `.gitignore`
* Sincronizar `codemeta.json` con DESCRIPTION
* `_pkgdown.yml` lang alineado con contenido (es)
* Eliminar `inst/extdata/cie10.db` bundled (causaba NOTE de 21.3MB)
* Compatibilidad multiplataforma: rutas absolutas, encoding, line endings
* Logo hexagonal actualizado a version G16

### Heredado de v0.9.3

* **Breaking**: `generar_cie10_cl()` ya no exportada (marcada `@noRd`)
* `comorbidity` y `gt` movidos de Imports a Suggests
* Mensajes de BD solo en sesiones interactivas (`if (interactive())`)
* `generar_cie10_cl()`: prioriza XLSX completo (39K+) sobre XLS legado
* `cie_guia_busqueda()`: corregida referencia a funcion inexistente

## English Summary

### rOpenSci Preparation

Release candidate for rOpenSci submission. Complies with rOpenSci Dev Guide
2025 (Chapters 1, 5, 6, 20). R CMD check: 0 errors, 0 warnings.
Tests: 1148 PASS, 95.6% coverage.

* **SQLite connection pooling** with atomic versioned cache
* **Vectorized** `cie_map_comorbid()` and `cie_normalizar()`
* **pkgdown site** with dark mode, hex logo, favicons
* **Hospital discharge vignette** with simulated DEIS data
* Bilingual community files (CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)
* Multi-platform CI/CD (Windows, macOS, Ubuntu)
* FTS5 SQL injection protection
* Pipe standardization (`%>%`), gitignore fixes, codemeta sync
