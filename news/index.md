# Changelog

## ciecl 0.9.8 (en desarrollo, 2026-04-25 → 2026-06-20)

*English summary below*

### Documentación — Correcciones revisión rOpenSci, comentarios de yabellini (2026-06-20)

Trabajo preparado originalmente el 2026-05-29, comiteado recien el
2026-06-20: quedo guardado en `git stash` desde el 2026-06-09 hasta su
recuperacion. Sin cambios en la API publica.

- **README**: fusion de las secciones “Finalidad” y “Caracteristicas”
  para eliminar redundancia entre ambas; se agrega mencion explicita de
  la correccion vectorizada de inconsistencias de formato y del publico
  objetivo (epidemiologos, bioestadisticos, cientificos de datos).
- **README.en.md**: comentarios de los ejemplos de codigo traducidos al
  ingles (estaban en espanol pese a ser la version en ingles).
- **README**: agregado enlace markdown a `CONTRIBUTING.md` (antes se
  mencionaba sin enlazar).
- **CONTRIBUTING.md**: agregada seccion “Tipos de issue” (ES/EN) que
  explica las plantillas disponibles (bug/feature/question) y corrige la
  instruccion de usar la etiqueta `question`, que el usuario no puede
  aplicar al crear un issue; ahora remite a la plantilla **Consulta**.
  Tambien se sincronizo la politica de idioma y la regla de encoding
  entre las secciones EN y ES, que estaban desactualizadas entre si.

### Sprint F4 — Documentación, limpieza interna y estilo (2026-06-09)

Sin cambios en la API pública.

- **`cie10_cl`**: documentación roxygen completada — columna `uso_cl`
  documentada, descripción de dominio para las 11 columnas, tildes
  corregidas, `@family datasets`,
  `@seealso [cie_lookup()], [cie_search()], [cie10_sql()]` y ejemplos
  adicionales.
- **Interno**: argumentos `texto` renombrados a `text` en las funciones
  internas `normalizar_tildes()` y `expandir_sigla()` (no exportadas,
  sin impacto en API).
- **Estilo**: lambdas de una línea migradas a sintaxis `\(x)` en
  `cie-siglas.R` y `cie-table.R`.

### Sprint F2 — Flags `include_uso_cl` / `only_uso_cl` (2026-05-20)

Expone la columna `uso_cl` del dataset CIE-10 MINSAL/DEIS v2018 como
filtro y como salida opcional en las dos funciones de busqueda
principales.

- **`cie_lookup(include_uso_cl = TRUE, only_uso_cl = FALSE)`**:
  - `include_uso_cl = TRUE` (default) preserva el contrato historico: la
    columna `uso_cl` sigue apareciendo en el output.
  - `only_uso_cl = TRUE` filtra a codigos vigentes en Chile excluyendo
    `uso_cl == "legado"`.
- **`cie_search(include_uso_cl = FALSE, only_uso_cl = FALSE)`**:
  - `include_uso_cl = FALSE` (default) preserva el contrato historico
    (no incluye `uso_cl` en el output). Pasarlo a `TRUE` agrega la
    columna.
  - `only_uso_cl = TRUE` filtra el resultado a codigos vigentes (excluye
    `legado`) en cualquier `field` (`descripcion` o `inclusion`).
- **Semantica de `uso_cl`** (textual, no booleano): `principal` (8.898),
  `legado` (27.335), `causa_externa` (3.295), `etiologico` (330),
  `causa_externa | principal` (19). `only_uso_cl = TRUE` conserva todo
  lo que NO es `legado` (12.542 codigos vigentes).
- **Asimetria documentada**: los defaults difieren entre `cie_lookup`
  (TRUE) y `cie_search` (FALSE) para no romper backward compat. El
  roxygen de ambas funciones lo menciona explicitamente.
- Tests: `tests/testthat/test-uso-cl-flags.R` cubre los 4 paths
  (default, include solo, only solo, ambos) en ambas funciones. +18
  tests, sin regresion sobre los 1069 existentes.

### Sprint F1 — Cobertura post-Bloque A (2026-05-20)

Recuperación de cobertura sobre los paths agregados en Bloque A y
refactor de mocks de API CIE-11 al patrón canónico de `httr2`. Sin
cambios de API pública.

- **Cobertura total: 94,20 % → 97,31 %** (`R/cie-sql.R`: 81,07 → 96,60;
  `R/cie-api.R`: 90,76 → 100,00). Suite: 1069 tests (+20), 0 fails.
- **`R/cie-sql.R`**:
  [`interactive()`](https://rdrr.io/r/base/interactive.html) →
  [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html)
  (2 sitios) para que `rlang::local_interactive(TRUE)` pueda activar el
  path `cli_progress` en tests sin TTY real.
- **`R/cie-api.R`**:
  - `who_error_body()` extraído del cuerpo de
    [`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)
    como helper interno `@noRd` testeable directamente. Misma lógica de
    extracción (`error_description` → `error` → `message`).
  - El warning del `tryCatch` externo pasa de `{e$message}` a
    `{conditionMessage(e)}`, propagando al usuario el detalle del body
    OMS cuando la API responde 4xx (antes se mostraba solo
    `"HTTP 401 ..."`).
- **`tests/testthat/test-api-mock.R`** migrado al patrón canónico:
  - `local_mocked_bindings(req_perform, .package = "httr2")` →
    `httr2::local_mocked_responses(mock_who_api(...))`. El flow real de
    `httr2` corre hasta `handle_resp()` → `resp_failure_cnd()`, lo que
    permite verificar end-to-end el callback
    `req_error(body = who_error_body)`.
  - Respuestas fake construidas con
    [`httr2::response_json()`](https://httr2.r-lib.org/reference/response.html)
    /
    [`httr2::response()`](https://httr2.r-lib.org/reference/response.html)
    en lugar de `structure(list(), class = "httr2_response")`
    (resistente a cambios internos de `httr2`).
  - Nuevo helper `mock_who_api()` que distingue por URL el endpoint
    OAuth de token del endpoint de búsqueda OMS.

### Modernización r-lib — Bloque A (2026-05-17)

Iteración técnica sobre patrones r-lib identificados en auditoría
post-revisión. Sin cambios de API pública.

- **OAuth en
  [`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)
  simplificado** (`R/cie-api.R`):
  - Migración del flujo OAuth manual (POST al token endpoint, parseo
    JSON, header `Authorization` armado a mano) a
    [`httr2::oauth_client()`](https://httr2.r-lib.org/reference/oauth_client.html) +
    [`httr2::req_oauth_client_credentials()`](https://httr2.r-lib.org/reference/req_oauth_client_credentials.html).
    `httr2` ahora gestiona la obtención, cacheo y refresh del token de
    acceso de forma transparente.
  - Errores HTTP de la OMS se tipifican vía
    [`httr2::resp_check_status()`](https://httr2.r-lib.org/reference/resp_status.html)
    y `httr2::req_error(body = ...)`, exponiendo `error_description` /
    `error` / `message` del cuerpo de respuesta cuando viene en JSON.
- **Indicadores de progreso en construcción de cache** (`R/cie-sql.R`):
  - `build_cache_atomic()` muestra ahora cuatro pasos vía
    [`cli::cli_progress_step()`](https://cli.r-lib.org/reference/cli_progress_step.html)
    (cargar dataset, escribir tabla, construir índices, crear FTS5)
    durante la primera invocación (~16 s). En sesiones no interactivas
    se mantiene completamente silencioso.
- **Argumentos requeridos uniformados** (`cie-api.R`, `cie-search.R`,
  `cie-comorbid.R`):
  [`rlang::check_required()`](https://rlang.r-lib.org/reference/check_required.html)
  estandariza el mensaje cuando faltan args obligatorios (`text`,
  `data`, `id`, `code`, `codes`).
- **Tests reproducibles**:
  [`testthat::local_reproducible_output()`](https://testthat.r-lib.org/reference/local_test_context.html)
  en cada `test_that()` que usa `expect_snapshot`, aislando ancho de
  terminal, color y locale para evitar falsos positivos cross-platform.

### Sprint cobertura y tooling rOpenSci (2026-05-08 / 2026-05-09)

- **Cobertura de tests subida de 86,45 % a 96,61 %** mediante:
  - Tests nuevos para
    [`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
    [`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md)
    y
    [`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md)
    (+42 tests).
  - Tests para rutas de deprecación, cache SQLite y manejo de errores
    (+107 tests). Total acumulado: **1049 tests**, 0 fails, 0 warnings.
  - Refactor a helpers canónicos r-lib:
    [`lifecycle::expect_deprecated()`](https://lifecycle.r-lib.org/reference/expect_deprecated.html)
    en lugar de `expect_warning(class = ...)`,
    [`withr::local_db_connection()`](https://withr.r-lib.org/reference/with_db_connection.html)
    en lugar de helpers custom, llamadas directas a internos en lugar de
    [`getFromNamespace()`](https://rdrr.io/r/utils/getFromNamespace.html).
- **Workflows rOpenSci/CRAN agregados**:
  - `.github/workflows/pkgcheck.yaml`
    (`ropensci-review-tools/pkgcheck-action`) con `post-to-issue: false`
    para evitar 403 en creación de issue.
  - `.github/workflows/urlchecker.yaml` con scheduled run mensual.
  - `.github/workflows/codemeta.yaml` regenera `codemeta.json` cuando
    cambia `DESCRIPTION`.
- **Badge de cobertura dinámico**: README y README.en consultan endpoint
  JSON del workflow `test-coverage.yaml` en lugar de un porcentaje
  hardcoded.
- **Bug fix
  [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)**:
  sigla `IRA` desambiguada (ver detalle más abajo). Aliases `IRA_RESP` e
  `IRA_RENAL` agregados.
- **Limpieza técnica menor**:
  - `@importFrom` duplicado eliminado en `cie-search.R`.
  - [`sapply()`](https://rdrr.io/r/base/lapply.html) reemplazado por
    `vapply(..., logical(1))` en
    [`cie_table()`](https://rodotasso.github.io/ciecl/reference/cie_table.md).
  - Fix de asociación roxygen rota en
    [`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md)
    (línea en blanco entre bloque roxygen y firma).
  - Badge rOpenSci Software Peer Review
    ([\#765](https://github.com/Rodotasso/ciecl/issues/765)) agregado a
    los README.

------------------------------------------------------------------------

### Respuesta a Revisión rOpenSci (rev-ropensci)

Versión de cumplimiento editorial y técnico tras la revisión de Maëlle
Salmon. Esta versión unifica la interfaz del paquete bajo estándares
internacionales de R, manteniendo la documentación pedagógica en español
para el contexto local.

#### Correcciones funcionales

- **Sigla `IRA` desambiguada**
  ([`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)):
  la sigla `IRA` es ambigua en contexto clínico chileno (puede ser
  **infección respiratoria aguda** o **insuficiencia renal aguda**).
  Ahora `cie_search("IRA")` mantiene el default respiratorio (uso más
  frecuente en pediatría y atención primaria) pero emite una advertencia
  explícita orientando al usuario hacia los nuevos alias inequívocos
  `IRA_RESP` (respiratoria) e `IRA_RENAL` (renal). Cierra bug detectado
  durante auditoría de seguridad post-split.

#### Infraestructura de calidad de código

- **Workflow de `lintr`** agregado en `.github/workflows/lint.yaml`
  (template oficial r-lib). Reporta lints sin bloquear el CI.
- **`.lintr` modernizado** a sintaxis lintr 3.x
  (`linters_with_defaults`), removiendo el deprecado `with_defaults` y
  el linter inexistente `cyclocomp_linter`.
- **Cleanup de espacios en blanco al final de línea** en 18 archivos
  (R/, tests/, vignettes/, NEWS, README, data-raw, tools).

#### Remediación r-lib y Calidad Técnica

- **Migración total a `cli`**: Todos los errores, advertencias y
  mensajes informativos usan ahora
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
  `cli_warn()` y `cli_inform()` con clases de error personalizadas
  (`ciecl_invalid_input`, `ciecl_api_error`, etc.) para captura
  programática.
- **Modernización de Roxygen**:
  - Migración masiva de `@return` a `@returns`.
  - Uso de sintaxis markdown para enlaces internos y externos
    (`[fun()]`).
  - Normalización de etiquetas `@family` a snake_case sin tildes.
- **Refactor de Estructura**: El archivo `cie-search.R` se ha dividido
  en 4 módulos (`cie-search.R`, `cie-siglas.R`, `cie-lookup.R`,
  `cie-guide.R`) para mejorar la mantenibilidad.
- **Pipe Nativo**: Migración de `%>%` al pipe nativo de R `|>` en todo
  el paquete (código, vignettes y tests).
- **Aislamiento de Tests**: Implementación de `withr` para garantizar
  que las pruebas no contaminen el cache del usuario, utilizando
  directorios temporales aislados.
- **Snapshots de Mensajes**: Uso de
  [`testthat::expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html)
  para asegurar la consistencia de los mensajes en español generados por
  el paquete.
- **Limpieza de Suggests**: Removidos `usethis` y `litedown` de
  `Suggests:` por no ser referenciados en código, tests ni vignettes del
  paquete.

#### Cambios que rompen compatibilidad (Deprecaciones)

- **Internacionalización de la API**: Todos los argumentos de las
  funciones públicas han sido migrados al inglés para consistencia con
  el ecosistema tidyverse (dplyr, httr2). Los argumentos antiguos en
  español emiten
  [`lifecycle::deprecate_warn()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
  y serán eliminados en la versión 1.0.0.

  - [`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md):
    `codigo` -\> `code`, `expandir` -\> `expand`, `normalizar` -\>
    `normalize`.
  - [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md):
    `texto` -\> `text`, `campo` -\> `field`, `solo_fuzzy` -\>
    `only_fuzzy`.
  - [`cie_short()`](https://rodotasso.github.io/ciecl/reference/cie_short.md):
    Reemplaza a
    [`cie_siglas()`](https://rodotasso.github.io/ciecl/reference/cie_siglas.md).
    Argumento `category`.

#### Cambios internos

- El script generador del dataset (`generar_cie10_cl()`,
  `parsear_cie10_minsal()`) se movió a `data-raw/` siguiendo la
  convención de R packages. No afecta el uso del paquete:
  `data(cie10_cl)` sigue funcionando igual.

- Tests del generador trasladados a sanity-check ejecutable desde
  `data-raw/`.

- Eliminación masiva de `ciecl:::` en tests para favorecer
  `devtools::load_all()`.

  - [`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md):
    `texto` -\> `text`.

- **Motor de Normalización Único**: Se establece
  [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
  como la función canónica.
  [`cie_normalize()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
  y
  [`cie_normalizar()`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md)
  están ahora deprecadas.

#### Nuevas funcionalidades

- **[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)**:
  Nueva función vectorizada para obtener descripciones CIE-10
  directamente, facilitando su uso dentro de
  [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
  sin necesidad de cruces manuales.

#### Auditoría Técnica (Compliance)

- **API Resiliente (CIE-11)**: Refactorización de
  [`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)
  usando `httr2` con mejores prácticas de consumo web:
  - Identificación clara mediante `User-Agent`.
  - Política de reintentos (`req_retry`) para fallas temporales.
  - Control de tasa (`req_throttle`) para respetar servidores de la OMS.
  - `httr2` promovido de Suggests a **Imports**.
- **Robustez de Tests**: Limpieza masiva de la suite de pruebas. Se
  eliminaron warnings de deprecación internos y se migró a `withr` para
  la gestión de variables de entorno.

#### Documentación y Homologación

- **Guías en Espejo**: Creación de versiones en inglés de todas las
  guías de usuario (`Case Study`, `Installation Guide`) para
  consistencia en el sitio `pkgdown`.
- **README paramétrico**: Unificación de `README.Rmd` para generar
  versiones sincronizadas en español e inglés. El README principal es
  ahora en español.
- **Narrativa Profesional**: Redacción mejorada en todas las vignettes,
  eliminando tonos informales por un lenguaje técnico de ingeniería de
  datos.

### English Summary

#### rOpenSci Review Response

Comprehensive update focused on API consistency and technical compliance
following rOpenSci peer review.

- **Breaking Changes (Deprecations)**: Full API migration to English
  arguments (e.g., `code`, `expand`, `normalize`, `text`) using the
  `lifecycle` package. Old Spanish arguments remain functional but emit
  warnings.
- **Streamlined Normalization**:
  [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
  is now the single canonical normalization motor.
- **New Function**: Added
  [`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
  for direct, vectorized description lookup within
  [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) calls.
- **Technical Compliance**:
  - [`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)
    now uses `httr2` with User-Agent, retry, and throttle policies.
  - `httr2` promoted to **Imports**.
  - Test suite cleaned of deprecation noise and updated to use `withr`.
- **Documentation**: Mirror versions of user guides provided in both
  English and Spanish. `pkgdown` site navigation localized to Spanish.

------------------------------------------------------------------------

## ciecl 0.9.6 (2026-04-04)

CRAN release: 2026-04-19

*English summary below*

### Preparacion rOpenSci

Version candidata para submission a rOpenSci. Cumple con rOpenSci Dev
Guide 2025 (Capitulos 1, 5, 6, 20). R CMD check: 0 errors, 0 warnings.
Tests: 1148 PASS, 95.6% cobertura.

#### Nuevas funcionalidades

- **Connection pooling SQLite**: Cache atomico con versionado en
  `get_cie10_db()`. Reutiliza conexiones activas, reconstruye si la BD
  esta corrupta o desactualizada.

- **Vectorizacion mejorada**:
  [`cie_map_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_map_comorbid.md)
  y
  [`cie_normalizar()`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md)
  refactorizados para procesamiento batch eficiente.

- **pkgdown site**: Tema limpio compatible con rOpenSci, modo oscuro
  (light-switch), logo hexagonal, favicons.

- **Vignette caso de uso**: `caso-uso-egresos` con datos simulados de
  egresos hospitalarios usando columnas esenciales DEIS.

#### Documentacion y comunidad

- CONTRIBUTING.md y CODE_OF_CONDUCT.md bilingues (ingles + espanol)
- SECURITY.md bilingue
- PR template para rOpenSci
- `@family` y `@seealso` en todas las funciones exportadas
- Documentacion English-first con traducciones completas

#### CI/CD

- GitHub Actions R-CMD-check multiplataforma (Windows, macOS, Ubuntu)
- Workflow de test coverage
- pkgdown deployment automatico desde main
- R-hub workflow

#### Seguridad

- FTS5 parametros sanitizados contra inyeccion SQL
- Stripeo de comentarios SQL
- Validacion estricta de inputs en funciones publicas

#### Fixes

- Estandarizar pipes a `%>%` (magrittr) en todo el paquete
- Corregir sintaxis invalida en `.gitignore`
- Sincronizar `codemeta.json` con DESCRIPTION
- `_pkgdown.yml` lang alineado con contenido (es)
- Eliminar `inst/extdata/cie10.db` bundled (causaba NOTE de 21.3MB)
- Compatibilidad multiplataforma: rutas absolutas, encoding, line
  endings
- Logo hexagonal actualizado a version G16

#### Heredado de v0.9.3

- **Breaking**: `generar_cie10_cl()` ya no exportada (marcada `@noRd`)
- `comorbidity` y `gt` movidos de Imports a Suggests
- Mensajes de BD solo en sesiones interactivas (`if (interactive())`)
- `generar_cie10_cl()`: prioriza XLSX completo (39K+) sobre XLS legado
- [`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md):
  corregida referencia a funcion inexistente

### English Summary

#### rOpenSci Preparation

Release candidate for rOpenSci submission. Complies with rOpenSci Dev
Guide 2025 (Chapters 1, 5, 6, 20). R CMD check: 0 errors, 0 warnings.
Tests: 1148 PASS, 95.6% coverage.

- **SQLite connection pooling** with atomic versioned cache
- **Vectorized**
  [`cie_map_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_map_comorbid.md)
  and
  [`cie_normalizar()`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md)
- **pkgdown site** with dark mode, hex logo, favicons
- **Hospital discharge vignette** with simulated DEIS data
- Bilingual community files (CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)
- Multi-platform CI/CD (Windows, macOS, Ubuntu)
- FTS5 SQL injection protection
- Pipe standardization (`%>%`), gitignore fixes, codemeta sync
