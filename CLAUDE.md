# Instrucciones Claude Code — paquete `ciecl`

## Contexto

Paquete R `ciecl`: CIE-10 oficial Chile (MINSAL/DEIS v2018).
39.873 códigos, búsqueda SQL/FTS5, fuzzy matching Jaro-Winkler,
comorbilidades Charlson/Elixhauser, API CIE-11 OMS.

- Repo git **solo** en este directorio (`ciecl/`)
- `dev` → desarrollo activo · `main` → releases CRAN
- v0.9.2 publicado en CRAN (enero 2026) · v0.9.6 candidato a update CRAN + rOpenSci

## Workflow obligatorio antes de commit

```bash
/r-test    # 1148 PASS esperado
/r-doc     # regenerar roxygen2
/r-check   # 0 errors, 0 warnings (2 NOTEs aceptables)
```

## Agentes especializados — uso recomendado

### Diagnóstico y release

| Agente / subagente | Cuándo invocar |
|---|---|
| `Explore` (thoroughness=medium) | Localizar bloat de tarball, verificar `\donttest{}`, inspeccionar estructura inst/ y data/ |
| `code-reviewer` | Antes de cada release CRAN, revisión de cambios acumulados en `dev` |
| `test-engineer` | Cuando cobertura baja de 95% o se agregan funciones nuevas sin tests |
| `r-check` (skill) | Obligatoria antes de cada commit en `dev` |
| `debugger` | Fallas en R CMD check multiplataforma (Windows vs Linux) |

### Documentación

| Agente | Cuándo invocar |
|---|---|
| `technical-writer` | Reescritura de vignettes, README, cran-comments.md |
| `api-documenter` | Cambios en funciones exportadas (roxygen2 bilingüe) |
| `documentation:update-docs` (skill) | Sincronizar README.md ↔ README.en.md tras cambios |

### Flujo Git / CRAN

| Skill | Cuándo |
|---|---|
| `superpowers:verification-before-completion` | Antes de declarar listo para submit |
| `superpowers:finishing-a-development-branch` | Al cerrar `dev` antes de merge a `main` |
| `git-workflow:commit` | Commits convencionales (sin menciones IA) |
| `git-workflow:create-pr` | PRs a GitHub del paquete |

## Context7 — OBLIGATORIO antes de tocar código

Paquetes clave del ecosistema: `dplyr`, `DBI`, `RSQLite`, `stringdist`,
`stringr`, `tibble`, `devtools`, `roxygen2`, `pkgdown`, `testthat`.

```
1. resolve-library-id "<paquete>"
2. query-docs <id> "<consulta>"
3. Aplicar código con API vigente
```

## Reglas específicas del paquete

- **Encoding código R**: UTF-8, sin tildes en código fuente (usar `\uXXXX`)
- **Encoding prosa/docs**: UTF-8 con tildes completos (á, é, í, ó, ú, ñ)
- Variables NSE declarar solo en `R/globals.R`
- Conexiones DB con `on.exit(DBI::dbDisconnect())` siempre
- Dependencias opcionales: `requireNamespace()` (nunca `Imports:`)
- Solo SELECT permitido en `cie10_sql()` (seguridad)
- Messages de BD envueltos en `if (interactive())`
- NUNCA commit si `/r-check` no está verde
- NUNCA push directo a `main` (solo merge desde `dev` para releases CRAN)

## Estructura

```
R/
  cie-search.R    # cie_search(), cie_lookup(), extract_cie_from_text()
  cie-sql.R       # cie10_sql(), get_cie10_db()
  cie-api.R       # cie11_search() (API OMS)
  cie-comorbid.R  # cie_comorbid(), cie_map_comorbid()
  cie-data.R      # parsear_cie10_minsal(), generar_cie10_cl() (@noRd)
  cie-utils.R     # cie_normalizar(), cie_validate_vector(), cie_expand()
  cie-table.R     # cie_table() (requiere gt)
  globals.R       # globalVariables NSE
data/
  cie10_cl.rda    # 39.873 códigos (solo dataset bundled)
tools/
  build_sqlite_cache.R  # dev only, excluido del build
```

## URLs de referencia

- Repo: https://github.com/RodoTasso/ciecl
- CRAN: https://cran.r-project.org/package=ciecl
- pkgdown: https://rodotasso.github.io/ciecl/
- DEIS: https://deis.minsal.cl/centrofic/
- API CIE-11: https://icd.who.int/icdapi

## NOTEs conocidas y aceptables en R CMD check

1. URLs MINSAL/DEIS devuelven 403 (anti-bot gubernamental chileno)
2. Examples >5s solo bajo `--run-donttest` (ya envueltos en `\donttest{}`)
3. `unable to verify current time` — sin internet durante check

## Anti-patrones

- Mencionar IA/Claude en commits, código, documentación
- Commits sin `/r-check` verde
- Commits directos en `main`
- Ejecutar acciones irreversibles en CRAN/rOpenSci/GitHub sin autorización explícita del mantenedor
- Cerrar/recrear issues o PRs externos ante errores — siempre mostrar y preguntar primero
