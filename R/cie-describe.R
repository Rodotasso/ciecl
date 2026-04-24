#' Obtener descripcion de codigos CIE-10 (vector)
#'
#' @description
#' Devuelve un vector character con la descripcion de cada codigo,
#' pensado para usar dentro de `dplyr::mutate()` sin necesidad de
#' un `left_join` contra `cie10_cl`.
#'
#' @param codes Character vector de codigos CIE-10 (ej. "E11.0",
#'   c("E11.0", "I10")). Se normalizan internamente con
#'   [cie_normalize()], por lo que acepta "E110", "e11.0", etc.
#' @param default Valor devuelto cuando un codigo no se encuentra
#'   en el catalogo. Default `NA_character_`.
#' @return Character vector del mismo largo que `codes` con la
#'   descripcion oficial MINSAL/DEIS. `NA_character_` (o `default`)
#'   para codigos sin match.
#' @family busqueda
#' @seealso [cie_lookup()] para resultado como tibble con todas
#'   las columnas; [cie_normalize()] para normalizacion.
#' @importFrom stats setNames
#' @export
#' @examples
#' # Uso escalar
#' cie_describe("E11.0")
#'
#' \donttest{
#' # Uso vectorizado
#' cie_describe(c("E11.0", "I10", "Z00"))
#'
#' # Uso tipico dentro de mutate
#' df <- data.frame(DIAG1 = c("E110", "I10", "XXX"))
#' df$descripcion <- cie_describe(df$DIAG1)
#' }
cie_describe <- function(codes, default = NA_character_) {
  if (length(codes) == 0) {
    return(character(0))
  }

  codes_norm <- cie_normalize(codes, search_db = FALSE)
  resultado <- rep(default, length(codes))

  no_na <- !is.na(codes_norm)
  if (!any(no_na)) {
    return(resultado)
  }

  con <- get_cie10_db()
  codes_unicos <- unique(codes_norm[no_na])
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
  idx <- codes_norm %in% names(lookup)
  resultado[idx] <- unname(lookup[codes_norm[idx]])
  resultado
}
