#' Obtener descripcion de codigos CIE-10 (vector)
#'
#' @description
#' Devuelve un vector character con la descripcion de cada codigo,
#' pensado para usar dentro de `dplyr::mutate()` sin necesidad de
#' un `left_join` contra `cie10_cl`.
#'
#' @param codes Character vector de codigos CIE-10 (ej. "E11.0",
#'   c("E11.0", "I10")).
#' @param normalize Logical, ¿intentar normalizar los codigos antes
#'   de buscar la descripcion? (default FALSE). Usar TRUE para
#'   limpiar formatos (ej. "E110" -> "E11.0"); usar FALSE para
#'   auditar la calidad original del registro.
#' @param default Valor devuelto cuando un codigo no se encuentra
#'   en el catalogo. Default `NA_character_`.
#' @return Character vector del mismo largo que `codes` con la
#'   descripcion oficial MINSAL/DEIS. `NA_character_` (o `default`)
#'   para codigos sin match.
#' @family busqueda
#' @seealso [cie_lookup()] para resultado como tibble con todas
#'   las columnas; [cie_norm()] para normalizacion.
#' @importFrom stats setNames
#' @export
#' @examples
#' # Auditoria: buscar tal cual (E110 no existe sin punto)
#' cie_describe("E110", normalize = FALSE)
#'
#' # Rescate: normalizar antes de buscar
#' cie_describe("E110", normalize = TRUE)
#'
#' \donttest{
#' # Uso tipico en auditoria VIU (contar fallos de origen)
#' diags <- c("E11.0", "E110", "I10X", "INVALIDO")
#' descripciones <- cie_describe(diags, normalize = FALSE)
#' sum(is.na(descripciones)) # Detecta 3 errores de registro
#' }
cie_describe <- function(codes, normalize = FALSE, default = NA_character_) {
  if (length(codes) == 0) {
    return(character(0))
  }

  # Flujo separado: normalizar solo si se pide (Rescate vs Auditoria)
  if (isTRUE(normalize)) {
    codes_to_search <- cie_norm(codes, search_db = FALSE)
  } else {
    codes_to_search <- as.character(codes)
  }
  
  resultado <- rep(default, length(codes))

  no_na <- !is.na(codes_to_search)
  if (!any(no_na)) {
    return(resultado)
  }

  con <- get_cie10_db()
  codes_unicos <- unique(codes_to_search[no_na])
  placeholders <- paste(rep("?", length(codes_unicos)), collapse = ",")
  query <- sprintf(
    "SELECT codigo, descripcion FROM cie10 WHERE codigo IN (%s)",
    placeholders
  )
  hits <- DBI::dbGetQuery(con, query, params = as.list(codes_unicos))

  if (nrow(hits) == 0) {
    return(resultado)
  }

  lookup <- setNames(hits$descripcion, hits$codigo)
  idx <- codes_to_search %in% names(lookup)
  resultado[idx] <- unname(lookup[codes_to_search[idx]])
  resultado
}
