# build_sqlite_cache.R
# Script de desarrollo (excluido del build via .Rbuildignore).
# Genera inst/extdata/cie10.db con indices y FTS5 pre-construidos.
# Ejecutar UNA VEZ desde raiz del paquete:
#   source("tools/build_sqlite_cache.R")

library(DBI)
library(RSQLite)
devtools::load_all()

db_path <- "inst/extdata/cie10.db"
dir.create("inst/extdata", showWarnings = FALSE, recursive = TRUE)

# Eliminar BD anterior si existe
if (file.exists(db_path)) {
  file.remove(db_path)
  message("BD anterior eliminada")
}

con <- DBI::dbConnect(RSQLite::SQLite(), db_path)

data(cie10_cl, package = "ciecl", envir = environment())
DBI::dbWriteTable(con, "cie10", cie10_cl, overwrite = TRUE)

DBI::dbExecute(con, "CREATE INDEX idx_codigo ON cie10(codigo)")
DBI::dbExecute(con, "CREATE INDEX idx_desc ON cie10(descripcion)")

DBI::dbExecute(con, "
  CREATE VIRTUAL TABLE cie10_fts USING fts5(
    codigo, descripcion, inclusion, exclusion,
    content='cie10', content_rowid='rowid'
  )
")
DBI::dbExecute(con, "INSERT INTO cie10_fts(cie10_fts) VALUES('rebuild')")

DBI::dbDisconnect(con)

message("BD creada: ", db_path,
        " (", round(file.size(db_path) / 1e6, 1), " MB)")
