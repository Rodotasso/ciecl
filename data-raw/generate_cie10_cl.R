#' Parsear datos CIE-10 MINSAL/DEIS desde XLS
#'
#' @description
#' Funcion interna para procesar Lista-Tabular-CIE-10-1-1.xls oficial DEIS.
#' Estructura columnas: codigo, descripcion, categoria, inclusion, exclusion.
#' Detecta columnas automaticamente para mayor robustez.
#'
#' @param xls_path Ruta al archivo XLS descargado DEIS
#' @return tibble con 39,877 codigos CIE-10 Chile limpios
parsear_cie10_minsal <- function(xls_path) {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop("Se requiere el paquete 'readxl' para leer el XLS/XLSX DEIS")
  }

  if (!file.exists(xls_path)) {
    stop("Archivo XLS no encontrado: ", xls_path)
  }

  # Leer XLS con deteccion automatica columnas
  raw <- readxl::read_excel(
    xls_path,
    sheet = 1,
    col_names = TRUE,
    skip = 0,
    .name_repair = "minimal"
  )

  # Normalizar nombres
  names(raw) <- tolower(stringr::str_trim(names(raw)))
  names(raw) <- stringr::str_replace_all(names(raw), "\\s+", "_")

  # Detectar columnas dinamicamente (soporta tildes: codigo/descripcion)
  col_codigo <- stringr::str_subset(names(raw), "c[o\u00f3]d|clave")
  col_desc <- stringr::str_subset(names(raw), "desc|t[i\u00ed]tulo")

  if (length(col_codigo) == 0 || length(col_desc) == 0) {
    stop("No se detectaron columnas codigo/descripcion. Columnas: ",
         paste(names(raw), collapse = ", "))
  }

  col_categoria <- stringr::str_subset(names(raw), "cat|tipo|categor[i\u00ed]a")
  col_inclusion <- stringr::str_subset(names(raw), "incl")
  col_exclusion <- stringr::str_subset(names(raw), "excl")

  # Construir dataset
  cie10_limpio <- raw %>%
    dplyr::select(
      codigo = dplyr::all_of(col_codigo[1]),
      descripcion = dplyr::all_of(col_desc[1]),
      categoria = dplyr::any_of(col_categoria),
      inclusion = dplyr::any_of(col_inclusion),
      exclusion = dplyr::any_of(col_exclusion)
    ) %>%
    dplyr::mutate(
      codigo = stringr::str_trim(as.character(codigo)),
      descripcion = stringr::str_trim(as.character(descripcion)),
      capitulo = stringr::str_extract(codigo, "^[A-Z]\\d{1,2}"),
      es_daga = stringr::str_detect(codigo, "\u2020"),
      es_cruz = stringr::str_detect(codigo, "\\*")
    ) %>%
    dplyr::filter(!is.na(codigo), !is.na(descripcion), nchar(codigo) >= 3) %>%
    tibble::as_tibble()

  return(cie10_limpio)
}

#' Generar dataset cie10_cl.rda
#'
#' @description
#' EJECUTAR UNA VEZ para crear data/cie10_cl.rda desde archivo DEIS.
#' Deteccion automatica por prioridad: XLSX completo (39K+ codigos)
#' vs XLS legado (~8K).
#'
#' @param archivo_path Ruta al archivo XLSX/XLS DEIS
#'   (opcional, deteccion automatica).
#'   Debe ser una ruta de confianza; no usar con input de usuarios finales.
#' @return Invisible tibble with generated 'ICD-10' data.
generar_cie10_cl <- function(archivo_path = NULL) {
  # Deteccion automatica si no se proporciona ruta
  if (is.null(archivo_path)) {
    candidatos <- c(
      normalizePath("../CIE-10-DEIS.xlsx", mustWork = FALSE),
      normalizePath("CIE-10-DEIS.xlsx", mustWork = FALSE),
      normalizePath("../CIE-10.xlsx", mustWork = FALSE),
      normalizePath("CIE-10.xlsx", mustWork = FALSE),
      normalizePath("../CIE-10 (1).xlsx", mustWork = FALSE),
      normalizePath("CIE-10 (1).xlsx", mustWork = FALSE),
      normalizePath("../Lista-Tabular-CIE-10-1-1.xls", mustWork = FALSE),
      normalizePath("Lista-Tabular-CIE-10-1-1.xls", mustWork = FALSE)
    )
    existentes <- candidatos[file.exists(candidatos)]
    if (length(existentes) == 0) {
      stop("Archivo no encontrado. Proporcionar ruta con archivo_path = '...'")
    }
    archivo_path <- existentes[1]
  }
  xls_path <- archivo_path

  message("Parseando: ", xls_path)
  cie10_cl <- parsear_cie10_minsal(xls_path)

  # Guardar en data/ con save() base
  if (!dir.exists("data")) dir.create("data")
  save(cie10_cl, file = "data/cie10_cl.rda", compress = "xz")

  message("Generado data/cie10_cl.rda con ", nrow(cie10_cl), " codigos")
  invisible(cie10_cl)
}

# Carga de paquetes necesarios para ejecucion manual del script
if (interactive()) {
  library(dplyr)
  library(stringr)
}
