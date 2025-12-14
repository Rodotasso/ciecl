test_that("cie_comorbid calcula Charlson", {
  skip_on_cran()
  
  df <- data.frame(
    id = c(1, 1, 2),
    diag = c("E11.0", "I50.9", "C50.9")
  )
  
  resultado <- cie_comorbid(df, id = "id", code = "diag", map = "charlson")
  expect_s3_class(resultado, "tbl_df")
  expect_true("score_charlson" %in% names(resultado))
})

test_that("cie_map_comorbid categoriza correctamente", {
  codigos <- c("E11.0", "I21.0", "INVALIDO")
  resultado <- cie_map_comorbid(codigos)
  
  expect_equal(nrow(resultado), 3)
  expect_equal(resultado$categoria[1], "Diabetes")
})
