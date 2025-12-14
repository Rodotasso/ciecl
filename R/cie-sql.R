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
  if (!stringr::str_detect(query, "(?i)^SELECT")) {
    stop("Solo queries SELECT permitidas (seguridad)")
  }
  
  con <- get_cie10_db()
  resultado <- DBI::dbGetQuery(con, query) %>% tibble::as_tibble()
  
  if (close) {
    DBI::dbDisconnect(con)
  }
  
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
