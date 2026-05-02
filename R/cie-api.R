#' Buscar codigos CIE-11 via API OMS
#'
#' @param text String termino busqueda espanol/ingles
#' @param api_key String opcional, Client ID + Secret OMS separados ":"
#'   Obtener en: https://icd.who.int/icdapi
#' @param lang Character, idioma respuesta ("es" o "en")
#' @param max_results Integer, maximo resultados (default 10)
#' @param release Character, version de release CIE-11 a consultar
#'   (default "2024-01"). Ver releases disponibles en la API OMS.
#' @param texto `r lifecycle::badge("deprecated")` Use `text`.
#' @return tibble con codigos CIE-11 + titulos o vacio si error
#' @family api
#' @seealso [cie_search()], [cie_lookup()]
#' @export
#' @importFrom tibble as_tibble
#' @importFrom dplyr slice_head select matches
#' @examples
#' # Ver parametros disponibles
#' args(cie11_search)
#'
#' @examplesIf interactive()
#' # Requiere credenciales OMS gratuitas (https://icd.who.int/icdapi)
#' Sys.setenv(ICD_API_KEY = "client_id:client_secret")
#' cie11_search("depresion mayor")
cie11_search <- function(text, api_key = NULL, lang = c("es", "en"),
                         max_results = 10, release = "2024-01",
                         texto = lifecycle::deprecated()) {
  # Deprecation: argumento en espanol -> ingles
  if (lifecycle::is_present(texto)) {
    lifecycle::deprecate_warn(
      "0.9.8",
      "cie11_search(texto = )",
      "cie11_search(text = )"
    )
    text <- texto
  }

  lang <- rlang::arg_match(lang)

  # Validacion de inputs
  if (!rlang::is_string(text)) {
    cli::cli_abort("{.arg text} debe ser un string de largo 1, no {.obj_type_friendly {text}}.")
  }
  if (nchar(trimws(text)) == 0) {
    cli::cli_abort("{.arg text} no puede estar vacio.")
  }
  if (!is.numeric(max_results) || length(max_results) != 1 ||
      max_results < 1 || max_results != as.integer(max_results)) {
    cli::cli_abort("{.arg max_results} debe ser un entero positivo.")
  }
  if (!is.character(release) || length(release) != 1 ||
      !grepl("^\\d{4}-\\d{2}$", release)) {
    cli::cli_abort("{.arg release} debe ser formato {.val YYYY-MM} (ej. {.val 2024-01}).")
  }

  # Verificar que httr2 este instalado
  rlang::check_installed("httr2", reason = "para consultar la API oficial de la OMS (CIE-11).")
  
  # Obtener API key (env var o argumento)
  if (is.null(api_key)) {
    api_key <- Sys.getenv("ICD_API_KEY", unset = NA)
    if (is.na(api_key)) {
      cli::cli_abort("API key OMS requerida. Ver: {.url https://icd.who.int/icdapi}")
    }
  }
  
  # Separar client_id y client_secret
  credentials <- strsplit(api_key, ":")[[1]]
  if (length(credentials) != 2) {
    cli::cli_abort("API key debe tener formato {.val client_id:client_secret}")
  }
  client_id <- credentials[1]
  client_secret <- credentials[2]
  
  tryCatch({
    # Paso 1: Obtener token OAuth
    token_url <- "https://icdaccessmanagement.who.int/connect/token"
    token_req <- httr2::request(token_url) %>%
      httr2::req_method("POST") %>%
      httr2::req_user_agent("ciecl (https://github.com/Rodotasso/ciecl)") %>%
      httr2::req_timeout(30) %>%
      httr2::req_retry(max_tries = 3) %>%
      httr2::req_body_form(
        client_id = client_id,
        client_secret = client_secret,
        scope = "icdapi_access",
        grant_type = "client_credentials"
      )
    
    token_resp <- httr2::req_perform(token_req)
    token_data <- httr2::resp_body_json(token_resp)
    access_token <- token_data$access_token
    
    # Paso 2: Buscar en CIE-11 con el token
    search_url <- paste0(
      "https://id.who.int/icd/release/11/", release, "/mms/search"
    )
    
    search_req <- httr2::request(search_url) %>%
      httr2::req_user_agent("ciecl (https://github.com/Rodotasso/ciecl)") %>%
      httr2::req_timeout(30) %>%
      httr2::req_retry(max_tries = 3) %>%
      httr2::req_throttle(rate = 10 / 60) %>% # 10 req/min para ser conservador
      httr2::req_url_query(
        q = text,
        flatResults = "true",
        useFlexisearch = "true"
      ) %>%
      httr2::req_headers(
        Authorization = paste("Bearer", access_token),
        `API-Version` = "v2",
        `Accept-Language` = lang
      )
    
    search_resp <- httr2::req_perform(search_req)
    json <- httr2::resp_body_json(search_resp, simplifyVector = TRUE)
    
    # Parsear resultados
    has_results <- "destinationEntities" %in% names(json) &&
      length(json$destinationEntities) > 0
    if (has_results) {
      # Limpiar HTML tags del titulo
      html_pattern <- "<em class='found'>|</em>"
      titulos_limpios <- gsub(html_pattern, "", json$destinationEntities$title)
      
      resultados <- tibble::tibble(
        codigo = json$destinationEntities$theCode,
        titulo = titulos_limpios,
        capitulo = json$destinationEntities$chapter
      ) %>%
        dplyr::slice_head(n = max_results)
      
      return(resultados)
    } else {
      cli::cli_inform(c("i" = "Sin resultados CIE-11 para: {.val {text}}"))
      return(tibble::tibble(
        codigo = character(), 
        titulo = character(),
        capitulo = character()
      ))
    }
    
  }, error = function(e) {
    cli::cli_warn(c(
      "Error API CIE-11: {e$message}",
      "i" = "Retornando resultado vacio.",
      "i" = "Usa {.fn cie_search} para fallback local CIE-10."
    ))
    return(tibble::tibble(
      codigo = character(), 
      titulo = character(),
      capitulo = character()
    ))
  })
}
