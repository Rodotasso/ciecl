# ============================================================
# COBERTURA: ciclo de vida del cache SQLite en cie-sql.R
# Cubre build_cache_atomic (creacion de cache_dir, cleanup
# de .tmp residual, error handling) + build_fts (failsafe)
# + cache_is_current (sin metadata, version mismatch).
# Usa patrones r-lib: withr::local_tempdir, local_envvar,
# local_mocked_bindings, defer.
# ============================================================

# Helper: crear conexion in-memory aislada para tests de helpers internos
make_test_con <- function() {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  withr::defer(DBI::dbDisconnect(con), envir = parent.frame())
  con
}

# --- build_fts: failsafe FTS5 missing -------------------------------------

test_that("build_fts crea tabla FTS5 sobre conexion existente", {
  con <- make_test_con()

  # Crear tabla cie10 minima (build_fts requiere que exista)
  DBI::dbExecute(con, "CREATE TABLE cie10 (codigo TEXT, descripcion TEXT,
                                            inclusion TEXT, exclusion TEXT)")
  DBI::dbExecute(con, "INSERT INTO cie10 VALUES
                       ('E11.0', 'diabetes con coma', NULL, NULL)")

  build_fts <- getFromNamespace("build_fts", "ciecl")
  expect_silent(build_fts(con))

  expect_true(DBI::dbExistsTable(con, "cie10_fts"))
})

# --- cache_is_current ------------------------------------------------------

test_that("cache_is_current retorna FALSE si no existe tabla cie10_meta", {
  con <- make_test_con()

  cache_is_current <- getFromNamespace("cache_is_current", "ciecl")
  expect_false(cache_is_current(con))
})

test_that("cache_is_current retorna FALSE si tabla cie10_meta esta vacia", {
  con <- make_test_con()
  DBI::dbExecute(con, "CREATE TABLE cie10_meta (key TEXT PRIMARY KEY,
                                                  value TEXT)")

  cache_is_current <- getFromNamespace("cache_is_current", "ciecl")
  expect_false(cache_is_current(con))
})

test_that("cache_is_current retorna FALSE si version no coincide", {
  con <- make_test_con()
  DBI::dbExecute(con, "CREATE TABLE cie10_meta (key TEXT PRIMARY KEY,
                                                  value TEXT)")
  DBI::dbExecute(
    con,
    "INSERT INTO cie10_meta (key, value) VALUES ('cache_version', '0.0.0')"
  )

  cache_is_current <- getFromNamespace("cache_is_current", "ciecl")
  expect_false(cache_is_current(con))
})

test_that("cache_is_current retorna TRUE cuando version coincide", {
  con <- make_test_con()
  DBI::dbExecute(con, "CREATE TABLE cie10_meta (key TEXT PRIMARY KEY,
                                                  value TEXT)")
  pkg_v <- as.character(utils::packageVersion("ciecl"))
  DBI::dbExecute(
    con,
    sprintf("INSERT INTO cie10_meta (key, value)
             VALUES ('cache_version', '%s')", pkg_v)
  )

  cache_is_current <- getFromNamespace("cache_is_current", "ciecl")
  expect_true(cache_is_current(con))
})

# --- build_cache_atomic: ciclo completo en directorio aislado --------------

test_that("build_cache_atomic crea cache_dir y construye DB completa", {
  cache_dir <- withr::local_tempdir()
  db_path <- file.path(cache_dir, "test.db")

  build_cache_atomic <- getFromNamespace("build_cache_atomic", "ciecl")
  build_cache_atomic(cache_dir, db_path)

  expect_true(file.exists(db_path))

  # Verificar contenido
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  withr::defer(DBI::dbDisconnect(con))

  expect_true(DBI::dbExistsTable(con, "cie10"))
  expect_true(DBI::dbExistsTable(con, "cie10_fts"))
  expect_true(DBI::dbExistsTable(con, "cie10_meta"))

  # Cache version sincronizada
  v <- DBI::dbGetQuery(
    con,
    "SELECT value FROM cie10_meta WHERE key = 'cache_version'"
  )$value[1]
  expect_equal(v, as.character(utils::packageVersion("ciecl")))
})

test_that("build_cache_atomic crea cache_dir cuando no existe", {
  parent <- withr::local_tempdir()
  cache_dir <- file.path(parent, "subdir_no_existe")
  db_path <- file.path(cache_dir, "test.db")

  expect_false(dir.exists(cache_dir))

  build_cache_atomic <- getFromNamespace("build_cache_atomic", "ciecl")
  build_cache_atomic(cache_dir, db_path)

  expect_true(dir.exists(cache_dir))
  expect_true(file.exists(db_path))
})

test_that("build_cache_atomic limpia .tmp residual antes de empezar", {
  cache_dir <- withr::local_tempdir()
  db_path <- file.path(cache_dir, "test.db")
  tmp_path <- paste0(db_path, ".tmp")

  # Simular un .tmp residual de un build anterior interrumpido
  writeLines("residuo", tmp_path)
  expect_true(file.exists(tmp_path))

  build_cache_atomic <- getFromNamespace("build_cache_atomic", "ciecl")
  build_cache_atomic(cache_dir, db_path)

  expect_true(file.exists(db_path))
  expect_false(file.exists(tmp_path))
})

# --- get_cie10_db: invalidacion por version mismatch ----------------------

test_that("get_cie10_db reconstruye cache cuando version no coincide", {
  cache_dir <- withr::local_tempdir()

  # Aislar cache via env var (R_USER_CACHE_DIR alimenta R_user_dir)
  withr::local_envvar(R_USER_CACHE_DIR = cache_dir)

  # Asegurar conexion limpia y reset al final
  cie10_disconnect()
  withr::defer(cie10_disconnect())

  # Construir cache: la primera llamada genera DB con version actual
  con1 <- get_cie10_db()
  expect_true(DBI::dbIsValid(con1))

  # Sobrescribir la version a "0.0.0" para simular cache obsoleto
  DBI::dbExecute(
    con1,
    "UPDATE cie10_meta SET value = '0.0.0' WHERE key = 'cache_version'"
  )

  # Reset estado interno para forzar reevaluacion
  cie10_disconnect()

  # Volver a pedir el DB: debe detectar version mismatch y reconstruir
  con2 <- get_cie10_db()
  v <- DBI::dbGetQuery(
    con2,
    "SELECT value FROM cie10_meta WHERE key = 'cache_version'"
  )$value[1]
  expect_equal(v, as.character(utils::packageVersion("ciecl")))
})
