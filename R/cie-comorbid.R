#' @importFrom dplyr filter pull rowwise
#' @importFrom stringr str_detect
#' @importFrom tibble tibble as_tibble tribble
NULL

#' Calcular comorbilidades Charlson/Elixhauser para Chile
#'
#' @param data data.frame con columnas id paciente + codigos CIE-10
#' @param id String nombre columna identificador paciente
#' @param code String nombre columna con codigos CIE-10 (uno por fila)
#' @param map Character, esquema comorbilidad ("charlson" o "elixhauser")
#' @param assign0 Logical, asignar 0 si sin comorbilidad (default TRUE)
#' @returns data.frame ancho con scores comorbilidad por paciente
#' @family comorbidities
#' @seealso [cie_map_comorbid()], [cie_norm()]
#' @export
#' @examples
#' # Ver documentacion de parametros
#' args(cie_comorbid)
#'
#' @examplesIf interactive()
#' df <- data.frame(
#'   id_pac = c(1, 1, 2, 2),
#'   diag = c("E11.0", "I21.0", "C50.9", "E10.9")
#' )
#' cie_comorbid(df, id = "id_pac", code = "diag", map = "charlson")
cie_comorbid <- function(data, id, code, map = c("charlson", "elixhauser"),
                         assign0 = TRUE) {
  # Verificar que comorbidity este instalado
  rlang::check_installed("comorbidity", reason = "para calcular scores de comorbilidad (Charlson/Elixhauser).")

  map <- rlang::arg_match(map)

  # Validar columnas existen
  if (!id %in% names(data) || !code %in% names(data)) {
    cli::cli_abort(
      "Columnas {.field {id}} y/o {.field {code}} no existen en {.arg data}.",
      class = "ciecl_invalid_input"
    )
  }

  # Advertir sobre NAs en columna de codigos
  n_na <- sum(is.na(data[[code]]))
  if (n_na > 0) {
    cli::cli_warn("Columna {.field {code}} contiene {.val {n_na}} valores NA que seran ignorados.")
    data <- data[!is.na(data[[code]]), ]
  }

  # Advertir sobre codigos vacios
  n_empty <- sum(nchar(trimws(as.character(data[[code]]))) == 0, na.rm = TRUE)
  if (n_empty > 0) {
    cli::cli_warn("Columna {.field {code}} contiene {.val {n_empty}} codigos vacios que seran ignorados.")
    data <- data[nchar(trimws(as.character(data[[code]]))) > 0, ]
  }

  # Normalizar codigos (elimina sufijo X DEIS, agrega punto, etc.)
  data[[code]] <- cie_norm(data[[code]], search_db = FALSE)

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
#' @param codes Character vector de codigos
#' @param codigos `r lifecycle::badge("deprecated")` Use `codes`.
#' @returns tibble con columnas: codigo, categoria
#' @family comorbidities
#' @seealso [cie_comorbid()], [cie_norm()]
#' @export
#' @examples
#' cie_map_comorbid(c("E11.0", "I50.9", "C50.9"))
cie_map_comorbid <- function(codes, codigos = lifecycle::deprecated()) {
  if (lifecycle::is_present(codigos)) {
    lifecycle::deprecate_warn(
      "0.9.8",
      "cie_map_comorbid(codigos = )",
      "cie_map_comorbid(codes = )"
    )
    codes <- codigos
  }

  # Manejar vector vacio
  if (length(codes) == 0) {
    return(tibble::tibble(
      codigo = character(0),
      categoria = character(0)
    ))
  }

  # Categorizacion vectorizada con case_when
  resultado <- tibble::tibble(
    codigo = codes,
    categoria = dplyr::case_when(
      is.na(codes) ~ "Otra",
      stringr::str_detect(codes, "^E10|^E11") ~ "Diabetes",
      stringr::str_detect(codes, "^I50") ~ "Insuficiencia cardiaca",
      stringr::str_detect(codes, "^I21|^I22") ~ "Infarto miocardio",
      stringr::str_detect(codes, "^C[0-9]{2}") ~ "Neoplasia maligna",
      stringr::str_detect(codes, "^J4[0-4]") ~ "EPOC",
      stringr::str_detect(codes, "^N18") ~ "Enfermedad renal cronica",
      stringr::str_detect(codes, "^F[0-9]{2}") ~ "Trastornos mentales",
      .default = "Otra"
    )
  )

  return(resultado)
}
