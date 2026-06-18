# Contributing to ciecl

Thank you for your interest in contributing to `ciecl`. This document describes how to participate in the development of the package.

## Reporting bugs

If you find a bug, please open an [issue on GitHub](https://github.com/RodoTasso/ciecl/issues) with:

- A clear description of the problem
- A minimal reproducible example ([reprex](https://reprex.tidyverse.org/))
- Output of `sessionInfo()`
- Your version of `ciecl` (`packageVersion("ciecl")`)

## Proposing changes

1. Fork the repository
2. Create a branch from `dev`: `git checkout -b feat/my-feature dev`
3. Make your changes following the project conventions
4. Run checks:
   ```r
   devtools::test()
   devtools::check()
   ```
5. Commit with descriptive messages (conventional format: `feat:`, `fix:`, `docs:`)
6. Open a Pull Request targeting the `dev` branch

## Code style

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use `%>%` from dplyr for pipes
- Document functions with roxygen2
- Encoding UTF-8, no accented characters in source code (use `\uXXXX`)
- Declare NSE variables in `R/globals.R`

## Tests

- All tests must pass before submitting a PR
- Add tests for new functionality in `tests/testthat/`
- Framework: testthat >= 3.1.5

## Code of Conduct

By participating in this project, you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Questions

For general questions, open an [issue](https://github.com/RodoTasso/ciecl/issues) with the "question" label.

---

# Contribuir a ciecl

Gracias por tu interes en contribuir a `ciecl`. Este documento describe como participar en el desarrollo del paquete.

## Reportar bugs

Si encuentras un bug, por favor abre un [issue en GitHub](https://github.com/RodoTasso/ciecl/issues) con:

- Descripcion clara del problema
- Codigo reproducible minimo ([reprex](https://reprex.tidyverse.org/))
- Output de `sessionInfo()`
- Version de `ciecl` (`packageVersion("ciecl")`)

## Proponer cambios

1. Haz un fork del repositorio
2. Crea una rama desde `dev`: `git checkout -b feat/mi-mejora dev`
3. Realiza tus cambios siguiendo las convenciones del proyecto
4. Ejecuta los checks:
   ```r
   devtools::test()
   devtools::check()
   ```
5. Haz commit con mensajes descriptivos (formato convencional: `feat:`, `fix:`, `docs:`)
6. Abre un Pull Request hacia la rama `dev`

## Estilo de codigo

- Seguir la [tidyverse style guide](https://style.tidyverse.org/)
- Usar el pipe nativo `|>` (requiere R >= 4.1.0).
- **Politica de Idioma**:
  - Funciones exportadas y argumentos: **Ingles**.
  - Documentacion (roxygen2) y Guias de usuario: **Espanol** (primario) e **Ingles**.
  - Mensajes de error e informativos: **Espanol**.
- Documentar funciones con roxygen2 usando sintaxis markdown.
- Codificacion: **UTF-8 literal**. Prohibido usar escapes unicode (ej. \uXXXX) en strings del codigo fuente.
- Variables NSE declarar en `R/globals.R`.

## Tests

- Todos los tests deben pasar antes de enviar un PR.
- Usar `testthat` edicion 3.
- Usar `withr` para gestionar efectos secundarios (archivos, variables de entorno).
- Usar `expect_snapshot()` para fijar los mensajes de error generados por `cli`.

## Codigo de conducta

Al participar en este proyecto, aceptas cumplir con el [Codigo de Conducta](CODE_OF_CONDUCT.md).

## Preguntas

Para preguntas generales, abre un [issue](https://github.com/RodoTasso/ciecl/issues) con la etiqueta "question".
