# Declarar variables NSE para evitar NOTEs en R CMD check
#' @importFrom rlang is_string arg_match check_installed is_installed
#' @importFrom lifecycle is_present deprecated
#' @importFrom cli cli_abort cli_warn cli_inform
utils::globalVariables(c(
  # Variables dplyr NSE
  "codigo", "descripcion", "score", "categoria", "inclusion", "exclusion",
  "patron", "title", "capitulo", "sigla", "termino_busqueda",
  # Dataset
  "cie10_cl",
  # Dot placeholder
  "."
))

#' Tibble vacio con estructura CIE-10
#' @keywords internal
#' @noRd
cie10_empty_tibble <- function(add_descripcion_completa = FALSE) {

  resultado <- tibble::tibble(
    codigo = character(0),
    descripcion = character(0),
    categoria = character(0),
    seccion = character(0),
    capitulo_nombre = character(0),
    inclusion = character(0),
    exclusion = character(0),
    capitulo = character(0),
    es_daga = logical(0),
    es_cruz = logical(0)
  )

  if (add_descripcion_completa) {
    resultado$descripcion_completa <- character(0)
  }

  return(resultado)
}
