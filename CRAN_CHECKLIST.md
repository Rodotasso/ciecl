# Checklist para Submission a CRAN

## Documentacion ✅

- [x] README.md con instalacion, ejemplos basicos
- [x] NEWS.md con cambios de version
- [x] Viñeta (vignettes/ciecl.Rmd) funcional
- [x] Todos los exports documentados con roxygen2
- [x] Ejemplos ejecutables o en \dontrun{}
- [x] CITATION file presente
- [x] LICENSE (MIT + file LICENSE)

## Codigo ✅

- [x] R CMD check --as-cran: 0 errors, 0 warnings, 0 notes
- [x] Tests: 34/34 pasan
- [x] Cobertura >80% (ejecutar devtools::test_coverage())
- [x] No codigo comentado innecesario
- [x] Funciones internas usan @keywords internal
- [x] Imports especificados (no :: en codigo exportado sin importar)

## DESCRIPTION ✅

- [x] Title en Title Case, <65 caracteres
- [x] Description >1 parrafo, sin redundancia con Title
- [x] Authors@R correcto (sin ORCID placeholder)
- [x] Version semantica (0.1.0 para primera submission)
- [x] License especificada correctamente
- [x] URL y BugReports apuntando a GitHub
- [x] Imports minimos (solo necesarios)
- [x] Suggests documentados
- [x] Language: es (paquete en español)

## Archivos especiales ✅

- [x] .Rbuildignore: excluye archivos de desarrollo
- [x] .gitignore: protege archivos sensibles (.Renviron)
- [x] cran-comments.md: actualizado para submission
- [x] No archivos binarios innecesarios en repo

## Tests y CI/CD ✅

- [x] testthat configurado (edition: 3)
- [x] GitHub Actions ejecutando R-CMD-check
- [x] Tests pasan en: Windows, macOS, Ubuntu
- [x] Tests pasan en: R-release, R-devel, R-oldrel
- [x] skip_on_cran() donde corresponde

## Datos ✅

- [x] data/cie10_cl.rda: LazyData activado
- [x] Documentacion en man/cie10_cl.Rd
- [x] Tamaño razonable (<5MB total)
- [x] Licencia de datos clarificada (dominio publico MINSAL)

## APIs y recursos externos ⚠️

- [x] cie11_search(): falla gracefully sin API key
- [x] Ejemplos de API en \dontrun{}
- [x] No requiere internet para funcionalidad core
- [x] Cache usa tools::R_user_dir() (CRAN-compliant)

## Antes de submit

### 1. Verificar en win-builder

```r
devtools::check_win_devel()
devtools::check_win_release()
devtools::check_win_oldrelease()
```

### 2. Verificar en rhub

```r
rhub::check_for_cran()
```

### 3. Spell check

```r
spelling::spell_check_package()
```

### 4. URL check

```r
urlchecker::url_check()
```

### 5. Verificar tamaño

```r
tools::checkRdaFiles("data")  # Debe ser <5MB
```

### 6. Bump version si es necesario

Actualizar version en DESCRIPTION y NEWS.md si hubo cambios desde ultima verificacion.

### 7. Submit a CRAN

```r
devtools::release()
```

O manualmente en: https://cran.r-project.org/submit.html

## Checklist post-submission

- [ ] Responder emails de CRAN en <48 horas
- [ ] Si hay NOTES: explicar en cran-comments.md
- [ ] Si rechazan: corregir y resubmit
- [ ] Una vez aceptado: agregar badge de CRAN a README
- [ ] Anunciar en redes si corresponde

## Notas para colaboradores

### Agregar colaboradores en DESCRIPTION

```r
Authors@R: c(
    person("Rodolfo", "Tasso Suazo", 
           email = "rtasso@uchile.cl",
           role = c("aut", "cre", "cph")),
    person("Nombre", "Apellido",
           email = "email@ejemplo.cl",
           role = "ctb")  # ctb = contributor
)
```

### Roles comunes:
- aut: Author (autor principal)
- cre: Creator/Maintainer (mantenedor, solo uno)
- cph: Copyright holder
- ctb: Contributor (colaborador)
- rev: Reviewer
- ths: Thesis advisor

### Workflow para colaboradores

1. Fork del repo
2. Crear branch: `git checkout -b feature/nombre-feature`
3. Hacer cambios
4. Ejecutar `devtools::check()` localmente
5. Push y crear Pull Request
6. CI debe pasar antes de merge
7. Maintainer (cre) hace merge a main
8. Solo maintainer puede submit a CRAN

### Versionado semantico

- **0.1.0 → 0.1.1**: Bug fixes (patch)
- **0.1.0 → 0.2.0**: Nuevas funciones (minor)
- **0.1.0 → 1.0.0**: Breaking changes (major)

Actualizar NEWS.md con cada version:

```markdown
# ciecl 0.2.0

## Nuevas funciones

* `nueva_funcion()`: Descripcion breve

## Bug fixes

* Corrige error en `funcion_existente()` cuando...

## Cambios internos

* Mejora performance de...
```

## Recursos utiles

- CRAN policies: https://cran.r-project.org/web/packages/policies.html
- R Packages book: https://r-pkgs.org/
- Writing R Extensions: https://cran.r-project.org/doc/manuals/R-exts.html
- rOpenSci packaging guide: https://devguide.ropensci.org/
