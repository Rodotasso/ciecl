# Contributing to ciecl

Thank you for your interest in contributing to `ciecl`. This document
describes how to participate in the development of the package.

## Reporting bugs

If you find a bug, please open an [issue on
GitHub](https://github.com/RodoTasso/ciecl/issues) with:

- A clear description of the problem
- A minimal reproducible example
  ([reprex](https://reprex.tidyverse.org/))
- Output of [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html)
- Your version of `ciecl` (`packageVersion("ciecl")`)

## Types of issues

When you open a new issue, GitHub will offer you three templates. Please
choose the one that matches your situation:

- **Bug report**: something is broken or behaves differently than
  documented. Include a reprex and your session info.
- **Feature request**: you would like a new capability or an improvement
  to an existing one. Describe the problem it solves and the behaviour
  you expect.
- **Question**: you have a doubt about how to use the package. Use the
  **Question** template, which applies the `question` label
  automatically.

## Proposing changes

1.  Fork the repository

2.  Create a branch from `dev`: `git checkout -b feat/my-feature dev`

3.  Make your changes following the project conventions

4.  Run checks:

    ``` r

    devtools::test()
    devtools::check()
    ```

5.  Commit with descriptive messages (conventional format: `feat:`,
    `fix:`, `docs:`)

6.  Open a Pull Request targeting the `dev` branch

## Code style

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use the native pipe `|>` for pipes (requires R \>= 4.1.0)
- **Language policy**:
  - Exported functions and arguments: **English**.
  - Documentation (roxygen2) and user guides: **Spanish** (primary) and
    English.
  - Error and informative messages: **Spanish**.
- Document functions with roxygen2 using markdown syntax
- Encoding: keep R source code in ASCII, using `\uXXXX` escapes for
  accented characters; write documents and prose in UTF-8 with correct
  accents
- Declare NSE variables in `R/globals.R`

## Tests

- All tests must pass before submitting a PR
- Add tests for new functionality in `tests/testthat/`
- Framework: testthat \>= 3.1.5

## Code of Conduct

By participating in this project, you agree to abide by the [Code of
Conduct](https://rodotasso.github.io/ciecl/CODE_OF_CONDUCT.md).

## Questions

For general questions, open an
[issue](https://github.com/RodoTasso/ciecl/issues) using the
**Question** template, which applies the `question` label automatically.

------------------------------------------------------------------------

# Contribuir a ciecl

Gracias por tu interés en contribuir a `ciecl`. Este documento describe
cómo participar en el desarrollo del paquete.

## Reportar bugs

Si encuentras un bug, por favor abre un [issue en
GitHub](https://github.com/RodoTasso/ciecl/issues) con:

- Descripción clara del problema
- Código reproducible mínimo ([reprex](https://reprex.tidyverse.org/))
- Salida de [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html)
- Versión de `ciecl` (`packageVersion("ciecl")`)

## Tipos de issue

Al abrir un nuevo issue, GitHub te ofrecerá tres plantillas. Elige la
que corresponda a tu caso:

- **Reporte de error (Bug report)**: algo está roto o se comporta
  distinto a lo documentado. Incluye un reprex y la información de tu
  sesión.
- **Sugerencia de mejora (Feature request)**: te gustaría una nueva
  funcionalidad o una mejora a una existente. Describe el problema que
  resuelve y el comportamiento que esperas.
- **Consulta (Question)**: tienes una duda sobre cómo usar el paquete.
  Usa la plantilla **Consulta**, que aplica la etiqueta `question`
  automáticamente.

## Proponer cambios

1.  Haz un fork del repositorio

2.  Crea una rama desde `dev`: `git checkout -b feat/mi-mejora dev`

3.  Realiza tus cambios siguiendo las convenciones del proyecto

4.  Ejecuta los checks:

    ``` r

    devtools::test()
    devtools::check()
    ```

5.  Haz commit con mensajes descriptivos (formato convencional: `feat:`,
    `fix:`, `docs:`)

6.  Abre un Pull Request hacia la rama `dev`

## Estilo de código

- Seguir la [tidyverse style guide](https://style.tidyverse.org/)
- Usar el pipe nativo `|>` para encadenar (requiere R \>= 4.1.0)
- **Política de idioma**:
  - Funciones exportadas y argumentos: **inglés**.
  - Documentación (roxygen2) y guías de usuario: **español** (primario)
    e inglés.
  - Mensajes de error e informativos: **español**.
- Documentar funciones con roxygen2 usando sintaxis markdown
- Encoding: el código fuente R se mantiene en ASCII, usando escapes
  `\uXXXX` para caracteres acentuados; los documentos y la prosa van en
  UTF-8 con acentos correctos
- Variables NSE declarar en `R/globals.R`

## Tests

- Todos los tests deben pasar antes de enviar un PR.
- Usar `testthat` edicion 3.
- Usar `withr` para gestionar efectos secundarios (archivos, variables
  de entorno).
- Usar `expect_snapshot()` para fijar los mensajes de error generados
  por `cli`.

## Código de conducta

Al participar en este proyecto, aceptas cumplir con el [Código de
Conducta](https://rodotasso.github.io/ciecl/CODE_OF_CONDUCT.md).

## Preguntas

Para preguntas generales, abre un
[issue](https://github.com/RodoTasso/ciecl/issues) usando la plantilla
**Consulta**, que aplica la etiqueta `question` automáticamente.
