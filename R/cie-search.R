#' Busqueda difusa (fuzzy) de terminos medicos CIE-10
#'
#' @param texto String termino medico en espanol (ej. "diabetes con coma")
#' @param threshold Numeric [0-1], umbral similitud Jaro-Winkler (default 0.80)
#' @param max_results Integer, maximo resultados a retornar (default 20)
#' @param campo Character, campo busqueda ("descripcion" o "inclusion")
#' @return tibble ordenado por score descendente
#' @export
#' @importFrom stringdist stringsim
#' @examples
#' # Buscar con typos
#' cie_search("diabetis mellitus")
#' 
#' # Mas estricto
#' cie_search("infarto miocardio", threshold = 0.90)
#' 
#' # Buscar en inclusiones
#' cie_search("neumonia bacteriana", campo = "inclusion")
cie_search <- function(texto, threshold = 0.80, max_results = 20, 
                       campo = c("descripcion", "inclusion")) {
  campo <- match.arg(campo)
  
  if (nchar(stringr::str_trim(texto)) < 3) {
    stop("Texto minimo 3 caracteres")
  }
  
  # Obtener todos los codigos desde SQLite
  con <- get_cie10_db()
  
  # Construir query SQL evitando duplicados
  if (campo == "descripcion") {
    query_sql <- "SELECT codigo, descripcion, categoria FROM cie10"
  } else {
    query_sql <- sprintf("SELECT codigo, descripcion, categoria, %s FROM cie10", campo)
  }
  
  base <- DBI::dbGetQuery(con, query_sql) %>% tibble::as_tibble()
  DBI::dbDisconnect(con)
  
  # Normalizar texto busqueda
  texto_norm <- tolower(stringr::str_trim(texto))
  base_texto <- tolower(stringr::str_trim(base[[campo]]))
  
  # Calcular similitud Jaro-Winkler (0-1, 1=identico)
  scores <- stringdist::stringsim(texto_norm, base_texto, method = "jw")
  
  # Filtrar + ordenar
  resultado <- base %>%
    dplyr::mutate(score = scores) %>%
    dplyr::filter(score >= threshold) %>%
    dplyr::arrange(dplyr::desc(score)) %>%
    dplyr::slice_head(n = max_results) %>%
    dplyr::select(codigo, descripcion, score, dplyr::everything())
  
  if (nrow(resultado) == 0) {
    message("x Sin coincidencias >= threshold ", threshold)
  }
  
  return(resultado)
}

#' Busqueda exacta por codigo CIE-10
#'
#' @param codigo String codigo (ej. "E11", "E11.0", rango "E10-E14")
#' @param expandir Logical, expandir jerarquia completa (default FALSE)
#' @return tibble con codigo(s) matcheado(s)
#' @export
#' @examples
#' cie_lookup("E11.0")
#' cie_lookup("E11", expandir = TRUE)  # Todos E11.x
cie_lookup <- function(codigo, expandir = FALSE) {
  codigo_norm <- stringr::str_trim(toupper(codigo))
  
  if (expandir) {
    # Buscar jerarquia completa (E11 → E11.x)
    query <- sprintf(
      "SELECT * FROM cie10 WHERE codigo LIKE '%s%%' ORDER BY codigo",
      codigo_norm
    )
  } else if (stringr::str_detect(codigo_norm, "-")) {
    # Rango (ej. "E10-E14")
    partes <- stringr::str_split(codigo_norm, "-")[[1]]
    query <- sprintf(
      "SELECT * FROM cie10 WHERE codigo BETWEEN '%s' AND '%s' ORDER BY codigo",
      partes[1], partes[2]
    )
  } else {
    # Exacto
    query <- sprintf(
      "SELECT * FROM cie10 WHERE codigo = '%s'",
      codigo_norm
    )
  }
  
  resultado <- cie10_sql(query)
  
  if (nrow(resultado) == 0) {
    message("x Codigo no encontrado: ", codigo)
  }
  
  return(resultado)
}
