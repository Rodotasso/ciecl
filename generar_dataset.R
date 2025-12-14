# Script para generar data/cie10_cl.rda desde XLS MINSAL
# Ejecutar UNA VEZ desde raiz del paquete ciecl/

library(readxl)
library(dplyr)
library(stringr)
library(usethis)

# Detectar ruta XLS automaticamente (portable)
detectar_xls <- function() {
  # Opcion 1: XLS en parent directory (01_Paquete_R/)
  xls_parent <- normalizePath("../Lista-Tabular-CIE-10-1-1.xls", mustWork = FALSE)
  
  # Opcion 2: XLS en directorio actual
  xls_actual <- normalizePath("Lista-Tabular-CIE-10-1-1.xls", mustWork = FALSE)
  
  if (file.exists(xls_parent)) {
    return(xls_parent)
  } else if (file.exists(xls_actual)) {
    return(xls_actual)
  } else {
    stop(
      "ERROR: Archivo XLS no encontrado.\n",
      "Buscado en:\n",
      "  1. ", xls_parent, "\n",
      "  2. ", xls_actual, "\n\n",
      "Asegurate de ejecutar desde ciecl/ y tener XLS en 01_Paquete_R/"
    )
  }
}

# Parsear XLS con manejo robusto de columnas
parsear_cie10_minsal <- function(xls_path) {
  message("Leyendo: ", xls_path)
  
  # Leer XLS (puede tener multiples sheets, probar primero)
  sheets <- readxl::excel_sheets(xls_path)
  message("Sheets disponibles: ", paste(sheets, collapse = ", "))
  
  # MINSAL XLS tiene headers en fila 3, skip = 2
  raw <- readxl::read_excel(
    xls_path,
    sheet = 1,
    col_names = TRUE,
    skip = 2,
    .name_repair = "minimal"
  )
  
  message("Dimensiones raw: ", nrow(raw), " filas x ", ncol(raw), " columnas")
  message("Nombres columnas originales: ", paste(names(raw), collapse = " | "))
  
  # Normalizar nombres columnas (conservando acentos)
  names(raw) <- tolower(stringr::str_trim(names(raw)))
  names(raw) <- stringr::str_replace_all(names(raw), "\\s+", "_")
  
  # Detectar columnas clave (flexible, incluyendo con acentos)
  col_codigo <- names(raw)[stringr::str_detect(names(raw), "c[oó]d|clave")]
  col_desc <- names(raw)[stringr::str_detect(names(raw), "desc|t[ií]tulo|diagn[oó]stico")]
  col_cat <- names(raw)[stringr::str_detect(names(raw), "cat|tipo")]
  col_inc <- names(raw)[stringr::str_detect(names(raw), "incl")]
  col_exc <- names(raw)[stringr::str_detect(names(raw), "excl")]
  
  message("Columnas detectadas:")
  message("  - Codigo: ", ifelse(length(col_codigo) > 0, col_codigo[1], "NO DETECTADA"))
  message("  - Descripcion: ", ifelse(length(col_desc) > 0, col_desc[1], "NO DETECTADA"))
  
  # Validar que al menos tenemos codigo y descripcion
  if (length(col_codigo) == 0 || length(col_desc) == 0) {
    stop("ERROR: No se pudieron detectar columnas basicas.\nColumnas en XLS: ", 
         paste(names(raw), collapse = ", "))
  }
  
  # Seleccionar columnas (usar primeras coincidencias)
  datos_base <- raw %>%
    dplyr::select(
      codigo = dplyr::all_of(col_codigo[1]),
      descripcion = dplyr::all_of(col_desc[1])
    )
  
  # Agregar columnas opcionales si existen
  if (length(col_cat) > 0) {
    datos_base$categoria <- raw[[col_cat[1]]]
  } else {
    datos_base$categoria <- NA_character_
  }
  
  if (length(col_inc) > 0) {
    datos_base$inclusion <- raw[[col_inc[1]]]
  } else {
    datos_base$inclusion <- NA_character_
  }
  
  if (length(col_exc) > 0) {
    datos_base$exclusion <- raw[[col_exc[1]]]
  } else {
    datos_base$exclusion <- NA_character_
  }
  
  # Procesar y limpiar
  cie10_limpio <- datos_base %>%
    dplyr::mutate(
      codigo = stringr::str_trim(as.character(codigo)),
      descripcion = stringr::str_trim(as.character(descripcion)),
      # Extraer capitulo desde codigo
      capitulo = stringr::str_extract(codigo, "^[A-Z]\\d{1,2}"),
      # Detectar cruz/daga
      es_daga = stringr::str_detect(codigo, "\u2020"),
      es_cruz = stringr::str_detect(codigo, "\\*")
    ) %>%
    dplyr::filter(!is.na(codigo), !is.na(descripcion), nchar(codigo) >= 3) %>%
    tibble::as_tibble()
  
  message("Dataset limpio: ", nrow(cie10_limpio), " codigos validos")
  
  return(cie10_limpio)
}

# EJECUTAR GENERACION
xls_path <- detectar_xls()
cie10_cl <- parsear_cie10_minsal(xls_path)

# Guardar como data interna del paquete
usethis::use_data(cie10_cl, overwrite = TRUE, compress = "xz")

# Verificar
message("\n EXITO: Generado data/cie10_cl.rda")
message("  Filas: ", nrow(cie10_cl))
message("  Columnas: ", paste(names(cie10_cl), collapse = ", "))
message("  Tamano: ", round(file.size("data/cie10_cl.rda") / 1024^2, 2), " MB")
message("\nProximo paso: devtools::document()")
