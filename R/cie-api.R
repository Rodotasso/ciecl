#' Buscar codigos CIE-11 via API OMS
#'
#' @param texto String termino busqueda espanol/ingles
#' @param api_key String opcional, Client ID + Secret OMS separados ":"
#'   Obtener en: https://icd.who.int/icdapi
#' @param lang Character, idioma respuesta ("es" o "en")
#' @param max_results Integer, maximo resultados (default 10)
#' @return tibble con codigos CIE-11 + titulos o vacio si error
#' @export
#' @importFrom httr2 request req_url_query req_perform resp_body_json req_headers
#' @importFrom tibble as_tibble
#' @importFrom dplyr slice_head select matches
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' # Requiere credenciales OMS gratuitas
#' Sys.setenv(ICD_API_KEY = "client_id:client_secret")
#' cie11_search("depresion mayor")
#' }
cie11_search <- function(texto, api_key = NULL, lang = "es", max_results = 10) {
  # Verificar que httr2 esté instalado
  if (!requireNamespace("httr2", quietly = TRUE)) {
    stop("El paquete 'httr2' es necesario para esta función.\n",
         "Instálalo con: install.packages('httr2')")
  }
  
  # Obtener API key (env var o argumento)
  if (is.null(api_key)) {
    api_key <- Sys.getenv("ICD_API_KEY", unset = NA)
    if (is.na(api_key)) {
      stop("API key OMS requerida. Ver: https://icd.who.int/icdapi")
    }
  }
  
  # Token OAuth (simplificado, requiere httr2)
  base_url <- "https://id.who.int/icd/release/11/2024-01/mms/search"
  
  tryCatch({
    req <- httr2::request(base_url) %>%
      httr2::req_url_query(
        q = texto,
        flatResults = "true",
        useFlexisearch = "true"
      ) %>%
      httr2::req_headers(
        `API-Version` = "v2",
        `Accept-Language` = lang
      )
    
    resp <- httr2::req_perform(req)
    json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
    
    # Parsear resultados
    if ("destinationEntities" %in% names(json)) {
      resultados <- json$destinationEntities %>%
        tibble::as_tibble() %>%
        dplyr::slice_head(n = max_results) %>%
        dplyr::select(
          codigo = dplyr::matches("theCode|id"),
          titulo = title,
          url = dplyr::matches("^http")
        )
      return(resultados)
    } else {
      message("Sin resultados CIE-11 para: ", texto)
      return(tibble::tibble(
        codigo = character(), 
        titulo = character(), 
        url = character()
      ))
    }
    
  }, error = function(e) {
    warning("Error API CIE-11: ", e$message, "\nRetornando resultado vacio. ",
            "Usa cie_search() para fallback local CIE-10")
    return(tibble::tibble(
      codigo = character(), 
      titulo = character(), 
      url = character()
    ))
  })
}
