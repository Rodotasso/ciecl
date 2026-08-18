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

## Declaración de asistencia con IA

Para el desarrollo de este paquete se utilizaron asistentes basados en
IA (Claude (Anthropic), Kimi (Moonshot AI) y Gemini (Google), accedidos
mediante sus interfaces web y herramientas de línea de comandos) como
apoyo para (i) la redacción, edición de estilo y revisión crítica de
partes de la documentación del paquete, y (ii) la redacción de los
scripts de análisis de benchmark. Todo el texto y el código generados
con IA fueron revisados, verificados y editados por el autor, quien
asume la responsabilidad completa del contenido del paquete. Ninguna
herramienta de IA se utilizó para generar, recopilar o analizar los
datos incluidos en el paquete: los pipelines de validación y benchmark
son código R determinista y versionado, cuyos resultados son exactamente
reproducibles.

## Contribuciones asistidas por IA

Las contribuciones realizadas con herramientas de IA (Claude, Copilot,
ChatGPT, etc.) son bienvenidas bajo las siguientes condiciones:

- **Eres responsable de cada línea que envías.** Debes entender el
  código y ser capaz de explicar qué hace y por qué; un PR no es el
  lugar para salidas que no has revisado.
- **Declara el uso de herramientas de IA en la descripción del PR**,
  indicando qué herramienta usaste y para qué (redactar código, tests,
  documentación, traducción).
- **Verifica empíricamente antes de enviar**: ejecuta `devtools::test()`
  y `devtools::check()` localmente y confirma que pasan. No envíes
  código que no hayas ejecutado.
- **Sigue las convenciones del proyecto** descritas arriba (estilo,
  política de idioma, encoding). El código generado por IA suele
  desviarse de ellas; adaptarlo es parte de la contribución.
- **No incluyas atribuciones a la IA** (“Generado con…”,
  “Co-Authored-By: …”) en mensajes de commit, comentarios de código ni
  documentación.

Los PR que no cumplan estas condiciones pueden recibir solicitud de
cambios o ser cerrados.

## Tests

- Todos los tests deben pasar antes de enviar un PR.
- Agregar tests para funcionalidad nueva en `tests/testthat/`.
- Framework: `testthat` (\>= 3.3.0), edición 3.
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

------------------------------------------------------------------------

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

## AI assistance declaration

AI-based assistants (Claude (Anthropic), Kimi (Moonshot AI) and Gemini
(Google), accessed through their web interfaces and command-line tools)
were used in the development of this package to assist with (i)
drafting, style editing, and critical revision of parts of the package
documentation, and (ii) drafting of the benchmark analysis scripts. All
AI-generated text and code was reviewed, verified, and edited by the
author, who takes full responsibility for the package content. No AI
tool was used to generate, collect, or analyze the data included in the
package: the validation and benchmark pipelines are deterministic,
versioned R code whose outputs are exactly reproducible.

## AI-assisted contributions

Contributions made with AI tools (Claude, Copilot, ChatGPT, etc.) are
welcome under the following conditions:

- **You are responsible for every line you submit.** You must understand
  the code and be able to explain what it does and why; a PR is not the
  place for output you have not reviewed.
- **Disclose the use of AI tools in the PR description**, including
  which tool you used and for what (drafting code, tests, documentation,
  translation).
- **Verify empirically before submitting**: run `devtools::test()` and
  `devtools::check()` locally and confirm they pass. Do not submit code
  you have not executed.
- **Follow the project conventions** described above (style, language
  policy, encoding). AI-generated code often deviates from them;
  adapting it is part of the contribution.
- **Do not include AI attributions** (“Generated with…”,
  “Co-Authored-By: …”) in commit messages, code comments, or
  documentation.

PRs that do not meet these conditions may be asked for revisions or
closed.

## Tests

- All tests must pass before submitting a PR
- Add tests for new functionality in `tests/testthat/`
- Framework: testthat (\>= 3.3.0), 3rd edition
- Use `withr` to manage side effects (files, environment variables)
- Use `expect_snapshot()` to pin error messages generated by `cli`

## Code of Conduct

By participating in this project, you agree to abide by the [Code of
Conduct](https://rodotasso.github.io/ciecl/CODE_OF_CONDUCT.md).

## Questions

For general questions, open an
[issue](https://github.com/RodoTasso/ciecl/issues) using the
**Question** template, which applies the `question` label automatically.
