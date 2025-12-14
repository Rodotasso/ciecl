#' @importFrom stringr str_trim str_replace_all str_detect str_extract str_split
#' @importFrom dplyr select mutate filter all_of any_of bind_rows distinct
#' @importFrom tibble as_tibble
#' @importFrom usethis use_data
NULL

# Declarar variables NSE globales
utils::globalVariables(c("codigo", "descripcion", "score", "."))

#' Busqueda difusa (fuzzy) de terminos medicos CIE-10
#'
#' @param texto String termino medico en espanol (ej. "diabetes con coma")
#' @param threshold Numeric entre 0 y 1, umbral similitud Jaro-Winkler (default 0.80)
#' @param max_results Integer, maximo resultados a retornar (default 20)
#' @param campo Character, campo busqueda ("descripcion" o "inclusion")
#' @return tibble ordenado por score descendente
#' @export
#' @importFrom stringdist stringsim
#' @importFrom dplyr mutate filter arrange desc slice_head select everything
#' @importFrom magrittr %>%
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
  
  # Conexión segura con auto-cierre
  con <- get_cie10_db()
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  
  # Construir query SQL evitando duplicados
  if (campo == "descripcion") {
    query_sql <- "SELECT codigo, descripcion, categoria FROM cie10"
  } else {
    query_sql <- sprintf("SELECT codigo, descripcion, categoria, %s FROM cie10", campo)
  }
  
  base <- DBI::dbGetQuery(con, query_sql) %>% tibble::as_tibble()
  
  # Normalizar texto busqueda
  texto_norm <- tolower(stringr::str_trim(texto))
  base_texto <- tolower(stringr::str_trim(base[[campo]]))
  
  # Manejar NAs en columna buscada
  base_texto[is.na(base_texto)] <- ""
  
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
#' @param codigo Character vector de codigos (ej. "E11", "E11.0", c("E11.0", "Z00"))
#'   o rango (ej. "E10-E14"). Acepta vectores de multiples codigos.
#' @param expandir Logical, expandir jerarquia completa (default FALSE)
#' @return tibble con codigo(s) matcheado(s)
#' @export
#' @examples
#' cie_lookup("E11.0")
#' cie_lookup("E11", expandir = TRUE)  # Todos E11.x
#' # Vectorizado - multiples codigos
#' cie_lookup(c("E11.0", "Z00", "I10"))
cie_lookup <- function(codigo, expandir = FALSE) {
  # Normalizar entrada
  codigo_norm <- stringr::str_trim(toupper(codigo))
  
  # Si es vector de multiples codigos, procesar cada uno y combinar
  if (length(codigo_norm) > 1) {
    # Procesar cada codigo individualmente y combinar resultados
    resultados_lista <- lapply(codigo_norm, function(cod) {
      cie_lookup_single(cod, expandir = expandir)
    })
    
    # Combinar todos los resultados en un solo tibble
    resultado <- dplyr::bind_rows(resultados_lista)
    
    # Eliminar duplicados que pudieran surgir
    resultado <- dplyr::distinct(resultado)
    
    return(resultado)
  } else {
    # Codigo unico - usar funcion interna
    return(cie_lookup_single(codigo_norm, expandir = expandir))
  }
}

#' Busqueda interna de un solo codigo CIE-10
#' @keywords internal
#' @noRd
cie_lookup_single <- function(codigo_norm, expandir = FALSE) {
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
    message("x Codigo no encontrado: ", codigo_norm)
  }
  
  return(resultado)
}
