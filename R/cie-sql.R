#' Obtener conexion SQLite persistente CIE-10
#' 
#' @description
#' Crea/conecta a base SQLite en cache usuario (rapido, sin rebuild).
#' Ubicacion: tools::R_user_dir("ciecl", "data")/cie10.db
#' 
#' @return Conexion DBI SQLite activa
#' @keywords internal
#' @importFrom DBI dbConnect dbExistsTable dbWriteTable dbDisconnect
#' @importFrom RSQLite SQLite
#' @importFrom utils data
#' @importFrom dplyr %>%
#' @noRd
get_cie10_db <- function() {
  cache_dir <- tools::R_user_dir("ciecl", "data")
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }
  
  db_path <- file.path(cache_dir, "cie10.db")
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  
  # Inicializar DB si vacia
  if (!DBI::dbExistsTable(con, "cie10")) {
    data(cie10_cl, envir = environment())
    DBI::dbWriteTable(con, "cie10", cie10_cl, overwrite = TRUE)
    
    # Indices para velocidad
    DBI::dbExecute(con, "CREATE INDEX idx_codigo ON cie10(codigo)")
    DBI::dbExecute(con, "CREATE INDEX idx_desc ON cie10(descripcion)")
    
    message("Inicializada SQLite DB: ", db_path)
  }
  
  return(con)
}

#' Ejecutar consultas SQL sobre CIE-10 Chile
#'
#' @param query String SQL valido SQLite (SELECT/WHERE/JOIN)
#' @param close Logical, cerrar conexion post-query (default TRUE)
#' @return tibble resultado query
#' @export
#' @examples
#' # Buscar diabetes
#' cie10_sql("SELECT codigo, descripcion FROM cie10 WHERE codigo LIKE 'E11%'")
#' 
#' # Contar por capitulo
#' cie10_sql("SELECT capitulo, COUNT(*) n FROM cie10 GROUP BY capitulo")
#' 
#' # Join con datos pacientes (externo)
#' \dontrun{
#' cie10_sql("SELECT p.id, c.descripcion 
#'            FROM pacientes p JOIN cie10 c ON p.codigo = c.codigo")
#' }
cie10_sql <- function(query, close = TRUE) {
  # Normalizar query: eliminar espacios y saltos de linea al inicio
  query_norm <- stringr::str_trim(query)

  # Validacion de seguridad: solo SELECT permitido
  if (!stringr::str_detect(query_norm, "(?i)^SELECT")) {
    stop("Solo queries SELECT permitidas (seguridad)")
  }

 # Bloquear keywords peligrosos (case-insensitive)
  keywords_peligrosos <- c(
    "\\bDROP\\b", "\\bDELETE\\b", "\\bUPDATE\\b", "\\bINSERT\\b",
    "\\bALTER\\b", "\\bCREATE\\b", "\\bTRUNCATE\\b", "\\bEXEC\\b",
    "\\bATTACH\\b", "\\bDETACH\\b", "\\bPRAGMA\\b"
  )

  for (keyword in keywords_peligrosos) {
    if (stringr::str_detect(query_norm, stringr::regex(keyword, ignore_case = TRUE))) {
      stop("Query contiene keyword no permitido (seguridad)")
    }
  }

  # Bloquear multiples statements (;)
  # Permitir ; solo dentro de strings
  query_sin_strings <- stringr::str_remove_all(query_norm, "'[^']*'")
  if (stringr::str_detect(query_sin_strings, ";")) {
    stop("Multiples statements SQL no permitidos (seguridad)")
  }

  con <- get_cie10_db()

  # Garantizar cierre de conexion incluso si hay error
  if (close) {
    on.exit(DBI::dbDisconnect(con), add = TRUE)
  }

  resultado <- DBI::dbGetQuery(con, query) %>% tibble::as_tibble()

  return(resultado)
}

#' Limpiar cache SQLite (forzar rebuild)
#'
#' @export
#' @examples
#' \dontrun{
#' cie10_clear_cache()  # Elimina cie10.db local
#' }
cie10_clear_cache <- function() {
  cache_dir <- tools::R_user_dir("ciecl", "data")
  db_path <- file.path(cache_dir, "cie10.db")
  
  if (file.exists(db_path)) {
    file.remove(db_path)
    message("Cache SQLite eliminado: ", db_path)
  } else {
    message("i Cache no existe")
  }
  
  invisible(NULL)
}
