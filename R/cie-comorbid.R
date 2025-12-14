#' Calcular comorbilidades Charlson/Elixhauser para Chile
#'
#' @param data data.frame con columnas id paciente + codigos CIE-10
#' @param id String nombre columna identificador paciente
#' @param code String nombre columna con codigos CIE-10 (uno por fila)
#' @param map Character, esquema comorbilidad ("charlson" o "elixhauser")
#' @param assign0 Logical, asignar 0 si sin comorbilidad (default TRUE)
#' @return data.frame ancho con scores comorbilidad por paciente
#' @export
#' @importFrom comorbidity comorbidity
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   id_pac = c(1, 1, 2, 2),
#'   diag = c("E11.0", "I21.0", "C50.9", "E10.9")
#' )
#' cie_comorbid(df, id = "id_pac", code = "diag", map = "charlson")
#' }
cie_comorbid <- function(data, id, code, map = c("charlson", "elixhauser"), 
                         assign0 = TRUE) {
  map <- match.arg(map)
  
  # Validar columnas existen
  if (!id %in% names(data) || !code %in% names(data)) {
    stop("Columnas '", id, "' o '", code, "' no existen en data")
  }
  
  # Mapear a nomenclatura comorbidity package
  map_full <- switch(map,
    "charlson" = "charlson_icd10_quan",
    "elixhauser" = "elixhauser_icd10_quan"
  )
  
  # Mapeo Charlson adaptado Chile (usa comorbidity::comorbidity)
  # Nota: version mas reciente de comorbidity no requiere argumento 'icd'
  resultado <- comorbidity::comorbidity(
    x = data,
    id = id,
    code = code,
    map = map_full,
    assign0 = assign0,
    labelled = FALSE
  )
  
  # Score total Charlson (si aplica)
  if (map == "charlson") {
    resultado$score_charlson <- comorbidity::score(
      resultado,
      weights = "charlson",
      assign0 = assign0
    )
  }
  
  return(tibble::as_tibble(resultado))
}

#' Mapeo manual grupos comorbilidad Chile-especifico
#'
#' @description
#' Agrupa codigos CIE-10 chilenos en categorias comorbilidad MINSAL.
#' Basado en Decreto 1301/2016 MINSAL + icd::icd10_map_charlson.
#' 
#' @param codigos Character vector codigos CIE-10
#' @return tibble con codigo + categoria_comorbilidad
#' @export
#' @examples
#' cie_map_comorbid(c("E11.0", "I50.9", "C50.9"))
cie_map_comorbid <- function(codigos) {
  # Mapeo manual categorias MINSAL (extender segun necesidad)
  mapeo_chile <- tibble::tribble(
    ~patron,        ~categoria,
    "^E10|^E11",    "Diabetes",
    "^I50",         "Insuficiencia cardiaca",
    "^I21|^I22",    "Infarto miocardio",
    "^C[0-9]{2}",   "Neoplasia maligna",
    "^J40|^J44",    "EPOC",
    "^N18",         "Enfermedad renal cronica",
    "^F[0-9]{2}",   "Trastornos mentales"
  )
  
  resultado <- tibble::tibble(codigo = codigos) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      categoria = {
        match <- mapeo_chile %>%
          dplyr::filter(stringr::str_detect(codigo, patron)) %>%
          dplyr::pull(categoria) %>%
          dplyr::first()
        ifelse(is.na(match), "Otra", match)
      }
    ) %>%
    dplyr::ungroup()
  
  return(resultado)
}
