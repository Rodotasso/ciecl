test_that("cie_normalizar convierte formatos correctamente", {
  skip_on_cran()
  
  # Con punto (ya normalizado)
  expect_equal(cie_normalizar("E11.0", buscar_db = FALSE), "E11.0")
  
  # Sin punto (agrega punto)
  expect_equal(cie_normalizar("E110", buscar_db = FALSE), "E11.0")
  
  # Vectorizado
  codigos <- c("E11.0", "I10.0", "Z00")
  resultado <- cie_normalizar(codigos, buscar_db = FALSE)
  expect_equal(resultado, c("E11.0", "I10.0", "Z00"))
})

test_that("cie_validate_vector detecta formatos invalidos", {
  validos <- cie_validate_vector(c("E11.0", "Z00", "INVALIDO"))
  expect_equal(validos, c(TRUE, TRUE, FALSE))
})

test_that("cie_expand genera hijos correctos", {
  skip_on_cran()
  
  hijos <- cie_expand("E11")
  expect_true(length(hijos) > 0)
  expect_true(all(stringr::str_starts(hijos, "E11")))
})
