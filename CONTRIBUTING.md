# Contribuir a ciecl

Gracias por tu interes en contribuir a `ciecl`. Este documento describe como participar en el desarrollo del paquete.

## Reportar bugs

Si encuentras un bug, por favor abre un [issue en GitHub](https://github.com/Rodotasso/ciecl/issues) con:

- Descripcion clara del problema
- Codigo reproducible minimo (reprex)
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
- Usar `%>%` de dplyr para pipes
- Documentar funciones con roxygen2
- Encoding UTF-8, sin tildes en codigo fuente (usar `\uXXXX`)
- Variables NSE declarar en `R/globals.R`

## Tests

- Todos los tests deben pasar antes de enviar un PR
- Agregar tests para funcionalidad nueva en `tests/testthat/`
- Framework: testthat >= 3.1.5

## Codigo de conducta

Al participar en este proyecto, aceptas cumplir con el [Codigo de Conducta](CODE_OF_CONDUCT.md).

## Preguntas

Para preguntas generales, abre un [issue](https://github.com/Rodotasso/ciecl/issues) con la etiqueta "question".
