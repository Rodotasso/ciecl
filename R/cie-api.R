#' Buscar codigos CIE-11 via API OMS
#'
#' @param texto String termino busqueda espanol/ingles
#' @param api_key String opcional, Client ID + Secret OMS separados ":"
#'   Obtener en: https://icd.who.int/icdapi
#' @param lang Character, idioma respuesta ("es" o "en")
#' @param max_results Integer, maximo resultados (default 10)
#' @return tibble con codigos CIE-11 + titulos
#' @export
#' @importFrom httr2 request req_url_query req_perform resp_body_json
#' @examples
#' \dontrun{
#' # Requiere credenciales OMS gratuitas
#' Sys.setenv(ICD_API_KEY = "client_id:client_secret")
#' cie11_search("depresion mayor")
#' }
cie11_search <- function(texto, api_key = NULL, lang = "es", max_results = 10) {
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
      message("x Sin resultados CIE-11 para: ", texto)
      return(tibble::tibble())
    }
    
  }, error = function(e) {
    warning("Error API CIE-11: ", e$message, "\nUsando fallback local CIE-10")
    return(cie_search(texto, threshold = 0.75))
  })
}
