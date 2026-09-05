# ============================================================
# COBERTURA: ciclo de vida del cache SQLite en cie-sql.R
# Cubre build_cache_atomic (creacion de cache_dir, cleanup
# de .tmp residual) + build_fts (failsafe) + cache_is_current
# (sin metadata, version mismatch) + reconstruccion automatica
# en get_cie10_db por version mismatch.
#
# Patrones r-lib usados:
# - withr::local_tempdir(): cache_dir aislado por test
# - withr::local_envvar(): R_USER_CACHE_DIR aislado
# - withr::local_db_connection(): cleanup automatico de DBI
#   (en lugar de defer manual de dbDisconnect)
# - llamada directa a helpers internos (build_fts, cache_is_current,
#   build_cache_atomic) — devtools::test() carga el namespace via
#   pkgload::load_all(), asi que getFromNamespace() es innecesario.
# ============================================================

# --- build_fts: failsafe FTS5 missing -------------------------------------

test_that("build_fts crea tabla FTS5 sobre conexion existente", {
  # Politica CRAN: construccion FTS5 siempre con skip
  skip_on_cran()

  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  )

  # Crear tabla cie10 minima (build_fts requiere que exista)
  DBI::dbExecute(con, "CREATE TABLE cie10 (codigo TEXT, descripcion TEXT,
                                            inclusion TEXT, exclusion TEXT)")
  DBI::dbExecute(con, "INSERT INTO cie10 VALUES
                       ('E11.0', 'diabetes con coma', NULL, NULL)")

  expect_silent(build_fts(con))
  expect_true(DBI::dbExistsTable(con, "cie10_fts"))
})

# --- cache_is_current ------------------------------------------------------
# canario CRAN: estos 4 tests corren sin skip en CRAN; usan SQLite
# :memory: y no construyen el cache del paquete.

test_that("cache_is_current retorna FALSE si no existe tabla cie10_meta", {
  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  )
  expect_false(cache_is_current(con))
})

test_that("cache_is_current retorna FALSE si tabla cie10_meta esta vacia", {
  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  )
  DBI::dbExecute(con, "CREATE TABLE cie10_meta (key TEXT PRIMARY KEY,
                                                  value TEXT)")

  expect_false(cache_is_current(con))
})

test_that("cache_is_current retorna FALSE si version no coincide", {
  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  )
  DBI::dbExecute(con, "CREATE TABLE cie10_meta (key TEXT PRIMARY KEY,
                                                  value TEXT)")
  DBI::dbExecute(
    con,
    "INSERT INTO cie10_meta (key, value) VALUES ('cache_version', '0.0.0')"
  )

  expect_false(cache_is_current(con))
})

test_that("cache_is_current retorna TRUE cuando version coincide", {
  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  )
  DBI::dbExecute(con, "CREATE TABLE cie10_meta (key TEXT PRIMARY KEY,
                                                  value TEXT)")
  pkg_v <- as.character(utils::packageVersion("ciecl"))
  DBI::dbExecute(
    con,
    sprintf("INSERT INTO cie10_meta (key, value)
             VALUES ('cache_version', '%s')", pkg_v)
  )

  expect_true(cache_is_current(con))
})

# --- build_cache_atomic: ciclo completo en directorio aislado --------------

test_that("build_cache_atomic crea cache_dir y construye DB completa", {
  skip_on_cran()

  cache_dir <- withr::local_tempdir()
  db_path <- file.path(cache_dir, "test.db")

  build_cache_atomic(cache_dir, db_path)

  expect_true(file.exists(db_path))

  # Verificar contenido
  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), db_path)
  )

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
  skip_on_cran()

  parent <- withr::local_tempdir()
  cache_dir <- file.path(parent, "subdir_no_existe")
  db_path <- file.path(cache_dir, "test.db")

  expect_false(dir.exists(cache_dir))

  build_cache_atomic(cache_dir, db_path)

  expect_true(dir.exists(cache_dir))
  expect_true(file.exists(db_path))
})

test_that("build_cache_atomic limpia .tmp residual antes de empezar", {
  skip_on_cran()

  cache_dir <- withr::local_tempdir()
  db_path <- file.path(cache_dir, "test.db")
  tmp_path <- paste0(db_path, ".tmp")

  # Simular un .tmp residual de un build anterior interrumpido
  writeLines("residuo", tmp_path)
  expect_true(file.exists(tmp_path))

  build_cache_atomic(cache_dir, db_path)

  expect_true(file.exists(db_path))
  expect_false(file.exists(tmp_path))
})

# ============================================================
# COBERTURA: cli_progress en sesion interactiva
# rlang::local_interactive(TRUE) fuerza is_interactive() = TRUE
# scoped al test (helper canonico r-lib, ver gargle/httr2).
# Cubre las ramas show_progress = TRUE en build_cache_atomic y
# build_fts sin requerir una TTY real.
# ============================================================

test_that("build_fts emite cli_progress en sesion interactiva", {
  skip_on_cran()

  rlang::local_interactive(TRUE)

  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  )
  DBI::dbExecute(
    con,
    "CREATE TABLE cie10 (codigo TEXT, descripcion TEXT,
                          inclusion TEXT, exclusion TEXT)"
  )
  DBI::dbExecute(
    con,
    "INSERT INTO cie10 VALUES ('E11.0', 'diabetes', NULL, NULL)"
  )

  # Capturar mensajes cli; el step debe nombrar FTS5.
  msgs <- capture_messages(build_fts(con, .progress = TRUE))
  expect_true(any(grepl("FTS5", msgs)))
  expect_true(DBI::dbExistsTable(con, "cie10_fts"))
})

test_that("build_fts permanece silencioso con .progress = FALSE aunque interactivo", {
  skip_on_cran()

  rlang::local_interactive(TRUE)

  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  )
  DBI::dbExecute(
    con,
    "CREATE TABLE cie10 (codigo TEXT, descripcion TEXT,
                          inclusion TEXT, exclusion TEXT)"
  )

  expect_silent(build_fts(con, .progress = FALSE))
})

test_that("build_cache_atomic emite los 4 cli_progress_step en sesion interactiva", {
  skip_on_cran()

  rlang::local_interactive(TRUE)

  cache_dir <- withr::local_tempdir()
  db_path <- file.path(cache_dir, "test.db")

  msgs <- capture_messages(build_cache_atomic(cache_dir, db_path))

  # Los 4 pasos del pipeline (dataset, tabla, indices, FTS5)
  texto <- paste(msgs, collapse = "\n")
  expect_match(texto, "cie10_cl")
  expect_match(texto, "cie10")
  expect_match(texto, "[Ii]ndices")
  expect_match(texto, "FTS5")
  expect_true(file.exists(db_path))
})

test_that("build_cache_atomic recupera limpiamente si build_fts falla en sesion interactiva", {
  skip_on_cran()

  rlang::local_interactive(TRUE)

  cache_dir <- withr::local_tempdir()
  db_path <- file.path(cache_dir, "test.db")
  tmp_path <- paste0(db_path, ".tmp")

  # Forzar fallo dentro del pipeline para ejercitar el handler
  # de error que cierra el progress con result = "failed".
  local_mocked_bindings(
    dbWriteTable = function(...) stop("fallo simulado en escritura"),
    .package = "DBI"
  )

  expect_error(
    suppressMessages(build_cache_atomic(cache_dir, db_path)),
    "Error construyendo cache SQLite"
  )

  # El .tmp debe haberse limpiado y el .db nunca debe existir
  expect_false(file.exists(tmp_path))
  expect_false(file.exists(db_path))
})

# --- get_cie10_db: rebuild condicional según versión (tabla sentinela) -----
# Una tabla extra ("sentinela") insertada a mano en el .db permite
# distinguir rebuild de reuso: el rebuild parte de un archivo nuevo, así
# que la sentinela desaparece; si el cache se reusa, la sentinela sobrevive.

test_that("get_cie10_db no reconstruye cuando la version coincide", {
  skip_on_cran()

  cache_dir <- withr::local_tempdir()
  # CIECL_CACHE_DIR tiene precedencia en get_cache_dir() y ya viene fijada
  # por setup.R; la sobreescribimos scoped para aislar este test.
  withr::local_envvar(CIECL_CACHE_DIR = cache_dir)
  cie10_disconnect()
  withr::defer(cie10_disconnect())

  con1 <- get_cie10_db()
  expect_true(DBI::dbIsValid(con1))

  # Sentinela: tabla ajena al paquete; sobrevive solo si NO hay rebuild
  DBI::dbExecute(con1, "CREATE TABLE sentinel_table (x INTEGER)")
  DBI::dbExecute(con1, "INSERT INTO sentinel_table VALUES (42)")
  cie10_disconnect()

  con2 <- get_cie10_db()
  expect_true(DBI::dbExistsTable(con2, "sentinel_table"))
  expect_equal(DBI::dbGetQuery(con2, "SELECT x FROM sentinel_table")$x, 42L)
})

test_that("get_cie10_db reconstruye cuando la version guardada difiere", {
  skip_on_cran()

  cache_dir <- withr::local_tempdir()
  withr::local_envvar(CIECL_CACHE_DIR = cache_dir)
  cie10_disconnect()
  withr::defer(cie10_disconnect())

  con1 <- get_cie10_db()
  DBI::dbExecute(con1, "CREATE TABLE sentinel_table (x INTEGER)")
  # Simular un cache construido por una versión anterior del paquete
  DBI::dbExecute(
    con1,
    "UPDATE cie10_meta SET value = '0.0.0' WHERE key = 'cache_version'"
  )
  cie10_disconnect()

  con2 <- get_cie10_db()
  # El rebuild parte de un .db nuevo: la sentinela desaparece
  expect_false(DBI::dbExistsTable(con2, "sentinel_table"))
  # Y la metadata vuelve a registrar la versión actual del paquete
  v <- DBI::dbGetQuery(
    con2,
    "SELECT value FROM cie10_meta WHERE key = 'cache_version'"
  )$value[1]
  expect_equal(v, as.character(utils::packageVersion("ciecl")))
})

test_that("get_cie10_db reconstruye cuando falta la tabla cie10_meta", {
  skip_on_cran()

  cache_dir <- withr::local_tempdir()
  withr::local_envvar(CIECL_CACHE_DIR = cache_dir)
  cie10_disconnect()
  withr::defer(cie10_disconnect())

  con1 <- get_cie10_db()
  DBI::dbExecute(con1, "CREATE TABLE sentinel_table (x INTEGER)")
  # Simular un cache antiguo (previo al versionado) o corrupto
  DBI::dbExecute(con1, "DROP TABLE cie10_meta")
  cie10_disconnect()

  con2 <- get_cie10_db()
  expect_false(DBI::dbExistsTable(con2, "sentinel_table"))
  expect_true(DBI::dbExistsTable(con2, "cie10_meta"))
  v <- DBI::dbGetQuery(
    con2,
    "SELECT value FROM cie10_meta WHERE key = 'cache_version'"
  )$value[1]
  expect_equal(v, as.character(utils::packageVersion("ciecl")))
})
