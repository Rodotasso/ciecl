# Script para generar data/cie10_cl.rda desde XLS MINSAL
# Ejecutar UNA VEZ desde raiz del paquete ciecl/

library(readxl)
library(dplyr)
library(stringr)
library(usethis)

# Detectar ruta CIE-10 automaticamente (portable)
detectar_cie10 <- function() {
  # Prioridad 1: XLSX nuevo (más completo)
  xlsx_parent <- normalizePath("../CIE-10 (1).xlsx", mustWork = FALSE)
  xlsx_actual <- normalizePath("CIE-10 (1).xlsx", mustWork = FALSE)
  
  # Prioridad 2: XLS antiguo (fallback)
  xls_parent <- normalizePath("../Lista-Tabular-CIE-10-1-1.xls", mustWork = FALSE)
  xls_actual <- normalizePath("Lista-Tabular-CIE-10-1-1.xls", mustWork = FALSE)
  
  if (file.exists(xlsx_parent)) {
    message("Usando CIE-10 (1).xlsx (COMPLETO - 39K+ códigos)")
    return(list(path = xlsx_parent, type = "xlsx"))
  } else if (file.exists(xlsx_actual)) {
    message("Usando CIE-10 (1).xlsx (COMPLETO - 39K+ códigos)")
    return(list(path = xlsx_actual, type = "xlsx"))
  } else if (file.exists(xls_parent)) {
    message("Usando Lista-Tabular-CIE-10-1-1.xls (ANTIGUO - 8K códigos)")
    return(list(path = xls_parent, type = "xls"))
  } else if (file.exists(xls_actual)) {
    message("Usando Lista-Tabular-CIE-10-1-1.xls (ANTIGUO - 8K códigos)")
    return(list(path = xls_actual, type = "xls"))
  } else {
    stop(
      "ERROR: Archivo CIE-10 no encontrado.\n",
      "Buscado en:\n",
      "  1. ", xlsx_parent, "\n",
      "  2. ", xlsx_actual, "\n",
      "  3. ", xls_parent, "\n",
      "  4. ", xls_actual, "\n\n",
      "Asegurate de ejecutar desde ciecl/ y tener archivo en 01_Paquete_R/"
    )
  }
}

# Parsear CIE-10 XLSX (formato mejorado)
parsear_cie10_xlsx <- function(xlsx_path) {
  message("Leyendo: ", xlsx_path)
  
  # Leer XLSX directo (ya tiene estructura correcta)
  datos <- readxl::read_excel(xlsx_path, sheet = 1)
  
  message("Dimensiones originales: ", nrow(datos), " filas x ", ncol(datos), " columnas")
  message("Columnas: ", paste(names(datos), collapse = ", "))
  
  # Normalizar a estructura estándar
  cie10_limpio <- datos %>%
    dplyr::transmute(
      codigo = stringr::str_trim(as.character(Código)),
      descripcion = stringr::str_trim(as.character(Descripción)),
      categoria = stringr::str_trim(as.character(Categoría)),
      seccion = if("Sección" %in% names(datos)) stringr::str_trim(as.character(Sección)) else NA_character_,
      capitulo_nombre = if("Capítulo" %in% names(datos)) stringr::str_trim(as.character(Capítulo)) else NA_character_,
      inclusion = NA_character_,
      exclusion = NA_character_,
      # Extraer código capítulo (letra + números)
      capitulo = stringr::str_extract(codigo, "^[A-Z]\\d{1,2}"),
      # Detectar cruz/daga (aunque el XLSX no parece tenerlos)
      es_daga = stringr::str_detect(codigo, "\u2020"),
      es_cruz = stringr::str_detect(codigo, "\\*")
    ) %>%
    dplyr::filter(!is.na(codigo), !is.na(descripcion)) %>%
    tibble::as_tibble()
  
  message("Dataset limpio: ", nrow(cie10_limpio), " códigos válidos\n")
  
  return(cie10_limpio)
}

# Parsear XLS antiguo con manejo robusto de columnas
parsear_cie10_xls <- function(xls_path) {
  message("Leyendo: ", xls_path)
  
  # Leer XLS (puede tener multiples sheets, probar primero)
  sheets <- readxl::excel_sheets(xls_path)
  message("Sheets disponibles: ", paste(sheets, collapse = ", "))
  message("IMPORTANTE: Se leerán TODAS las hojas para combinar códigos\n")
  
  # LEER TODAS LAS HOJAS Y COMBINARLAS
  lista_datos <- lapply(seq_along(sheets), function(i) {
    sheet_name <- sheets[i]
    message("  [", i, "/", length(sheets), "] Procesando hoja: ", sheet_name)
    
    # MINSAL XLS tiene headers en fila 3, skip = 2
    raw_sheet <- readxl::read_excel(
      xls_path,
      sheet = i,
      col_names = TRUE,
      skip = 2,
      .name_repair = "minimal"
    )
    
    message("      -> ", nrow(raw_sheet), " filas leídas")
    return(raw_sheet)
  })
  
  # Combinar todas las hojas
  raw <- dplyr::bind_rows(lista_datos)
  
  message("\nDimensiones combinadas: ", nrow(raw), " filas x ", ncol(raw), " columnas")
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
  
  message("Dataset limpio subcategorías: ", nrow(cie10_limpio), " códigos válidos")
  
  # ====== GENERAR CATEGORÍAS PADRE (3 dígitos) ======
  # Extraer categoría de 3 dígitos desde subcategorías de 4+
  message("\nGenerando categorías padre (3 dígitos)...")
  
  categorias_padre <- cie10_limpio %>%
    dplyr::mutate(
      # Extraer primeros 3 caracteres como categoría padre
      categoria_padre = stringr::str_sub(codigo, 1, 3)
    ) %>%
    # Agrupar por categoría padre
    dplyr::group_by(categoria_padre) %>%
    dplyr::summarise(
      # Descripción: tomar la primera subcategoría (generalmente la .0 o .X)
      descripcion_cat = dplyr::first(descripcion),
      # Contar cuántas subcategorías tiene
      n_subcategorias = dplyr::n(),
      .groups = "drop"
    ) %>%
    # Crear estructura compatible
    dplyr::transmute(
      codigo = categoria_padre,
      descripcion = paste0(descripcion_cat, " [Categoría - ", n_subcategorias, " subcategorías]"),
      categoria = "Categoría 3 dígitos",
      inclusion = NA_character_,
      exclusion = NA_character_,
      capitulo = stringr::str_extract(codigo, "^[A-Z]\\d{1,2}"),
      es_daga = FALSE,
      es_cruz = FALSE
    )
  
  message("  -> Generadas ", nrow(categorias_padre), " categorías padre únicas")
  
  # Combinar subcategorías + categorías padre
  cie10_completo <- dplyr::bind_rows(
    cie10_limpio,
    categorias_padre
  ) %>%
    # Ordenar por código
    dplyr::arrange(codigo) %>%
    # Eliminar duplicados exactos si existen
    dplyr::distinct(codigo, .keep_all = TRUE)
  
  message("Dataset COMPLETO: ", nrow(cie10_completo), " códigos (subcategorías + categorías)\n")
  
  return(cie10_completo)
}

# EJECUTAR GENERACION
archivo_cie10 <- detectar_cie10()

if (archivo_cie10$type == "xlsx") {
  cie10_cl <- parsear_cie10_xlsx(archivo_cie10$path)
} else {
  cie10_cl <- parsear_cie10_xls(archivo_cie10$path)
}

# Guardar como data interna del paquete
usethis::use_data(cie10_cl, overwrite = TRUE, compress = "xz")

# Verificar
message("\n===== EXITO: Generado data/cie10_cl.rda =====")
message("  Total códigos: ", nrow(cie10_cl))
message("  Categorías 3 dígitos: ", sum(nchar(cie10_cl$codigo) == 3))
message("  Subcategorías 4+ dígitos: ", sum(nchar(cie10_cl$codigo) >= 4))
message("  Columnas: ", paste(names(cie10_cl), collapse = ", "))
message("  Tamaño: ", round(file.size("data/cie10_cl.rda") / 1024^2, 2), " MB")
message("\n Próximo paso: devtools::document()")
