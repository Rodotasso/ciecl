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
