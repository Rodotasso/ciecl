test_that("cie_normalizar convierte formatos correctamente", {
  skip_on_cran()
  
  # Con punto (ya normalizado)
  expect_equal(cie_normalizar("E11.0", buscar_db = FALSE), "E11.0")
  
  # Sin punto (agrega punto)
  expect_equal(cie_normalizar("E110", buscar_db = FALSE), "E11.0")
  
  # Con sufijo X (elimina X)
  expect_equal(cie_normalizar("I10X", buscar_db = FALSE), "I10")
  expect_equal(cie_normalizar("J00X", buscar_db = FALSE), "J00")
  expect_equal(cie_normalizar("i10x", buscar_db = FALSE), "I10")  # minusculas
  
  # Vectorizado
  codigos <- c("E11.0", "I10.0", "Z00")
  resultado <- cie_normalizar(codigos, buscar_db = FALSE)
  expect_equal(resultado, c("E11.0", "I10.0", "Z00"))
  
  # Vectorizado con X
  codigos_x <- c("I10X", "J00X", "E110")
  resultado_x <- cie_normalizar(codigos_x, buscar_db = FALSE)
  expect_equal(resultado_x, c("I10", "J00", "E11.0"))
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
