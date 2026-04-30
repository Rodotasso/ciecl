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
#' @param codigos `r lifecycle::badge("deprecated")` Use `codes`.
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
#' @examplesIf interactive()
#' # Uso tipico en auditoria VIU (contar fallos de origen)
#' diags <- c("E11.0", "E110", "I10X", "INVALIDO")
#' descripciones <- cie_describe(diags, normalize = FALSE)
#' sum(is.na(descripciones)) # Detecta 3 errores de registro
cie_describe <- function(codes, normalize = FALSE, default = NA_character_,
                        codigos = lifecycle::deprecated()) {
  if (lifecycle::is_present(codigos)) {
    lifecycle::deprecate_warn(
      "0.9.8",
      "cie_describe(codigos = )",
      "cie_describe(codes = )"
    )
    codes <- codigos
  }

  if (!is.logical(normalize) || length(normalize) != 1L || is.na(normalize)) {
    stop("`normalize` debe ser TRUE o FALSE.", call. = FALSE)
  }

  if (length(codes) == 0) {
    return(character(0))
  }

  # Flujo separado: normalizar solo si se pide (Rescate vs Auditoria)
  codes <- if (normalize) {
    cie_norm(codes, search_db = FALSE)
  } else {
    as.character(codes)
  }
  
  resultado <- rep(default, length(codes))

  no_na <- !is.na(codes)
  if (!any(no_na)) {
    return(resultado)
  }

  con <- get_cie10_db()
  codes_unicos <- unique(codes[no_na])
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
  idx <- codes %in% names(lookup)
  resultado[idx] <- unname(lookup[codes[idx]])
  resultado
}
