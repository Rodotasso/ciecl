#' Validar vector de codigos CIE-10 formato
#'
#' @param codigos Character vector codigos (ej. c("E11.0", "Z00.0"))
#' @param strict Logical, validar existencia en DB (default FALSE)
#' @return Logical vector misma longitud input
#' @export
#' @examples
#' cie_validate_vector(c("E11.0", "INVALIDO", "Z00"))
cie_validate_vector <- function(codigos, strict = FALSE) {
  # Regex CIE-10 basico: [A-Z]\d{2}(\.\d{1,2})?
  patron <- "^[A-Z]\\d{2}(\\.\\d{1,2})?$"
  
  validos_formato <- stringr::str_detect(codigos, patron)
  
  if (strict) {
    # Validar existencia en DB con conexión segura
    con <- get_cie10_db()
    on.exit(DBI::dbDisconnect(con), add = TRUE)
    
    codigos_db <- DBI::dbGetQuery(con, "SELECT DISTINCT codigo FROM cie10")$codigo
    
    validos_db <- codigos %in% codigos_db
    resultado <- validos_formato & validos_db
    
    invalidos <- codigos[!resultado]
    if (length(invalidos) > 0) {
      warning("Codigos no encontrados en DB MINSAL: ", paste(invalidos, collapse = ", "))
    }
    
    return(resultado)
  } else {
    return(validos_formato)
  }
}

#' Expandir codigo jerarquico (ej. E11 → E11.0-E11.9)
#'
#' @param codigo String codigo padre (ej. "E11")
#' @return Character vector codigos hijos
#' @export
#' @examples
#' cie_expand("E11")
cie_expand <- function(codigo) {
  hijos <- cie_lookup(codigo, expandir = TRUE)$codigo
  return(hijos)
}
