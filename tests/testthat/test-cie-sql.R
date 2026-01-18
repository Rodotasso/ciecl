test_that("SQLite DB inicializa correctamente", {
  skip_on_cran()
  
  con <- get_cie10_db()
  expect_s4_class(con, "SQLiteConnection")
  expect_true(DBI::dbExistsTable(con, "cie10"))
  DBI::dbDisconnect(con)
})

test_that("cie10_sql ejecuta queries SELECT", {
  skip_on_cran()
  
  resultado <- cie10_sql("SELECT COUNT(*) AS n FROM cie10")
  expect_s3_class(resultado, "tbl_df")
  expect_gt(resultado$n, 5000)  # Minimo 5k codigos
})

test_that("cie10_sql bloquea queries peligrosas", {
  expect_error(
    cie10_sql("DROP TABLE cie10"),
    "Solo queries SELECT"
  )
})

# ==============================================================================
# PRUEBAS ADICIONALES cie10_sql()
# ==============================================================================

test_that("cie10_sql ejecuta queries con WHERE", {
  skip_on_cran()

  resultado <- cie10_sql("SELECT * FROM cie10 WHERE codigo = 'E11.0'")
  expect_s3_class(resultado, "tbl_df")
  expect_equal(nrow(resultado), 1)
})

test_that("cie10_sql ejecuta queries con LIKE", {
  skip_on_cran()

  resultado <- cie10_sql("SELECT * FROM cie10 WHERE codigo LIKE 'E11%' LIMIT 10")
  expect_s3_class(resultado, "tbl_df")
  expect_lte(nrow(resultado), 10)
})

test_that("cie10_sql ejecuta queries con GROUP BY", {
  skip_on_cran()

  resultado <- cie10_sql("SELECT capitulo, COUNT(*) as n FROM cie10 GROUP BY capitulo")
  expect_s3_class(resultado, "tbl_df")
  expect_gt(nrow(resultado), 10)
})

test_that("cie10_sql ejecuta queries con ORDER BY", {
  skip_on_cran()

  resultado <- cie10_sql("SELECT codigo, descripcion FROM cie10 ORDER BY codigo LIMIT 5")
  expect_s3_class(resultado, "tbl_df")
  expect_equal(nrow(resultado), 5)
})

test_that("cie10_sql bloquea ALTER TABLE", {
  skip_on_cran()

  # Bloquea por keyword peligroso o por no ser SELECT
  expect_error(
    cie10_sql("ALTER TABLE cie10 ADD COLUMN test TEXT")
  )
})

test_that("cie10_sql bloquea CREATE TABLE", {
  skip_on_cran()

  expect_error(
    cie10_sql("CREATE TABLE test (id INTEGER)")
  )
})

test_that("cie10_sql bloquea TRUNCATE", {
  skip_on_cran()

  expect_error(
    cie10_sql("TRUNCATE TABLE cie10")
  )
})

test_that("cie10_sql bloquea ATTACH DATABASE", {
  skip_on_cran()

  expect_error(
    cie10_sql("ATTACH DATABASE 'test.db' AS test")
  )
})

test_that("cie10_sql bloquea PRAGMA", {
  skip_on_cran()

  expect_error(
    cie10_sql("PRAGMA table_info(cie10)")
  )
})

test_that("cie10_sql permite DISTINCT", {
  skip_on_cran()

  resultado <- cie10_sql("SELECT DISTINCT capitulo FROM cie10")
  expect_s3_class(resultado, "tbl_df")
  expect_gt(nrow(resultado), 0)
})

test_that("cie10_sql permite COUNT con condicion", {
  skip_on_cran()

  resultado <- cie10_sql("SELECT COUNT(*) as n FROM cie10 WHERE codigo LIKE 'E%'")
  expect_s3_class(resultado, "tbl_df")
  expect_gt(resultado$n, 100)
})

test_that("cie10_sql maneja query con saltos de linea", {
  skip_on_cran()

  query <- "
    SELECT
      codigo,
      descripcion
    FROM cie10
    WHERE codigo = 'E11.0'
  "
  resultado <- cie10_sql(query)
  expect_s3_class(resultado, "tbl_df")
  expect_equal(nrow(resultado), 1)
})
