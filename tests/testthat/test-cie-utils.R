test_that("cie_normalizar convierte formatos correctamente", {
  skip_on_cran()
  
  # Con punto (ya normalizado)
  expect_equal(cie_normalizar("E11.0", buscar_db = FALSE), "E11.0")
  
  # Sin punto (agrega punto)
  expect_equal(cie_normalizar("E110", buscar_db = FALSE), "E11.0")
  
  # Con sufijo X en codigos cortos (elimina X)
  expect_equal(cie_normalizar("I10X", buscar_db = FALSE), "I10")
  expect_equal(cie_normalizar("J00X", buscar_db = FALSE), "J00")
  expect_equal(cie_normalizar("B54X", buscar_db = FALSE), "B54")
  expect_equal(cie_normalizar("i10x", buscar_db = FALSE), "I10")  # minusculas
  
  # Codigos largos con X placeholder (preserva X)
  # En trauma/lesiones, X es placeholder obligatorio del 7o caracter
  expect_equal(cie_normalizar("S72X01A", buscar_db = FALSE), "S72X01A")
  expect_equal(cie_normalizar("T84X0XA", buscar_db = FALSE), "T84X0XA")
  
  # Vectorizado
  codigos <- c("E11.0", "I10.0", "Z00")
  resultado <- cie_normalizar(codigos, buscar_db = FALSE)
  expect_equal(resultado, c("E11.0", "I10.0", "Z00"))
  
  # Vectorizado con X (cortos y largos)
  codigos_x <- c("I10X", "J00X", "E110", "S72X01A")
  resultado_x <- cie_normalizar(codigos_x, buscar_db = FALSE)
  expect_equal(resultado_x, c("I10", "J00", "E11.0", "S72X01A"))
})

test_that("cie_normalizar maneja caracteres especiales", {
  skip_on_cran()
  
  # Espacios internos (error comun de captura)
  expect_equal(cie_normalizar("E 11 0", buscar_db = FALSE), "E11.0")
  expect_equal(cie_normalizar("I 10", buscar_db = FALSE), "I10")
  expect_equal(cie_normalizar(" E11.0 ", buscar_db = FALSE), "E11.0")  # trim
  
  # Guiones en lugar de puntos
  expect_equal(cie_normalizar("I10-0", buscar_db = FALSE), "I10.0")
  expect_equal(cie_normalizar("E11-0", buscar_db = FALSE), "E11.0")
  
  # Puntos multiples consecutivos
  expect_equal(cie_normalizar("E..11.0", buscar_db = FALSE), "E.11.0")
  expect_equal(cie_normalizar("I10..0", buscar_db = FALSE), "I10.0")
  
  # Puntos iniciales
  expect_equal(cie_normalizar(".I10", buscar_db = FALSE), "I10")
  expect_equal(cie_normalizar("..E11.0", buscar_db = FALSE), "E11.0")
  
  # Sistema daga/asterisco (codificacion dual CIE-10)
  expect_equal(cie_normalizar("A17.0\u2020", buscar_db = FALSE), "A17.0")  # daga
  expect_equal(cie_normalizar("G01*", buscar_db = FALSE), "G01")           # asterisco
  expect_equal(cie_normalizar("A52.1\u2020", buscar_db = FALSE), "A52.1")  # parkinsonismo sifilitico
  
  # Vectorizado con caracteres especiales
  codigos_especiales <- c("E 11 0", "I10-0", "A17.0\u2020", "G01*")
  resultado <- cie_normalizar(codigos_especiales, buscar_db = FALSE)
  expect_equal(resultado, c("E11.0", "I10.0", "A17.0", "G01"))
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
