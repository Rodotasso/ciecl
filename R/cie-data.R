#' Parsear datos CIE-10 MINSAL/DEIS desde XLS
#' 
#' @description
#' Funcion interna para procesar Lista-Tabular-CIE-10-1-1.xls oficial DEIS.
#' Estructura columnas: codigo, descripcion, categoria, inclusion, exclusion.
#' 
#' @param xls_path Ruta al archivo XLS descargado DEIS
#' @return tibble con ~10,000 codigos CIE-10 Chile limpios
#' @keywords internal
#' @noRd
parsear_cie10_minsal <- function(xls_path) {
  if (!file.exists(xls_path)) {
    stop("Archivo XLS no encontrado: ", xls_path)
  }
  
  # Leer XLS MINSAL (ajustar columnas segun estructura real)
  raw <- readxl::read_excel(
    xls_path,
    sheet = 1,
    col_names = TRUE,
    skip = 0,
    .name_repair = "minimal"
  )
  
  # Normalizar nombres (ajustar si nombres reales difieren)
  names(raw) <- tolower(stringr::str_trim(names(raw)))
  
  # Estructura esperada MINSAL:
  # Codigo | Descripcion | Categoria | Inclusion | Exclusion | Capitulo
  cie10_limpio <- raw %>%
    dplyr::select(
      codigo = dplyr::matches("cod|clave"),
      descripcion = dplyr::matches("desc|titulo"),
      categoria = dplyr::matches("cat|tipo"),
      inclusion = dplyr::matches("incl"),
      exclusion = dplyr::matches("excl"),
      capitulo = dplyr::matches("cap")
    ) %>%
    dplyr::mutate(
      codigo = stringr::str_trim(codigo),
      descripcion = stringr::str_trim(descripcion),
      # Extraer capitulo (ej. "A00-B99")
      capitulo = stringr::str_extract(codigo, "^[A-Z]\\d{1,2}"),
      # Flag cruz/daga MINSAL
      es_daga = stringr::str_detect(codigo, "\u2020"),
      es_cruz = stringr::str_detect(codigo, "\\*")
    ) %>%
    dplyr::filter(!is.na(codigo), !is.na(descripcion)) %>%
    tibble::as_tibble()
  
  return(cie10_limpio)
}

#' Generar dataset cie10_cl.rda
#' 
#' @description
#' EJECUTAR UNA VEZ para crear data/cie10_cl.rda desde XLS padre.
#' Ruta relativa: ../Lista-Tabular-CIE-10-1-1.xls (en 01_Paquete_R/)
#' 
#' @examples
#' \dontrun{
#' # Desde ciecl/ ejecutar:
#' source("R/cie-data.R")
#' generar_cie10_cl()
#' }
#' @keywords internal
#' @export
generar_cie10_cl <- function() {
  xls_path <- normalizePath("../Lista-Tabular-CIE-10-1-1.xls", mustWork = TRUE)
  cie10_cl <- parsear_cie10_minsal(xls_path)
  
  # Guardar en data/
  usethis::use_data(cie10_cl, overwrite = TRUE, compress = "xz")
  
  message("Generado data/cie10_cl.rda con ", nrow(cie10_cl), " codigos")
  invisible(cie10_cl)
}

#' Dataset CIE-10 Chile oficial MINSAL/DEIS v2018
#'
#' @format tibble con ~10,000 filas:
#' \describe{
#'   \item{codigo}{Codigo CIE-10 (ej. "E11.0")}
#'   \item{descripcion}{Diagnostico en espanol chileno}
#'   \item{categoria}{Categoria jerarquica}
#'   \item{inclusion}{Terminos incluidos}
#'   \item{exclusion}{Terminos excluidos}
#'   \item{capitulo}{Capitulo CIE-10 (A-Z)}
#'   \item{es_daga}{Logical, codigo daga (†)}
#'   \item{es_cruz}{Logical, codigo asterisco (*)}
#' }
#' @source \url{https://repositoriodeis.minsal.cl}
#' @examples
#' data(cie10_cl)
#' head(cie10_cl)
"cie10_cl"
