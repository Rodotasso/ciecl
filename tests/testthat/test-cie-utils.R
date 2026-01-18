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

# ==============================================================================
# PRUEBAS ADICIONALES cie_normalizar() con buscar_db=TRUE
# ==============================================================================

test_that("cie_normalizar con buscar_db=TRUE verifica existencia", {
  skip_on_cran()

  # Codigo que existe en la base
  resultado <- cie_normalizar("E11.0", buscar_db = TRUE)
  expect_equal(resultado, "E11.0")

  # Codigo de categoria (3 digitos)
  resultado_cat <- cie_normalizar("E11", buscar_db = TRUE)
  # Puede agregar 0 si E110 existe, o mantenerse E11
  expect_true(resultado_cat %in% c("E11", "E110"))
})

test_that("cie_normalizar con buscar_db=TRUE es vectorizado", {
  skip_on_cran()

  codigos <- c("E11.0", "I10", "Z00")
  resultado <- cie_normalizar(codigos, buscar_db = TRUE)

  expect_length(resultado, 3)
  expect_true("E11.0" %in% resultado)
})

test_that("cie_normalizar con buscar_db=TRUE falla con NA", {
  skip_on_cran()

  codigos <- c(NA, "E11.0")

  expect_error(
    cie_normalizar(codigos, buscar_db = TRUE)
  )
})


test_that("cie_normalizar maneja codigo inexistente con buscar_db=TRUE", {
  skip_on_cran()

  # Codigo que no existe (retorna el codigo normalizado)
  resultado <- cie_normalizar("X99.9", buscar_db = TRUE)
  expect_equal(resultado, "X99.9")
})

# ==============================================================================
# PRUEBAS ADICIONALES cie_validate_vector() con strict=TRUE
# ==============================================================================

test_that("cie_validate_vector con strict=TRUE verifica existencia en DB", {
  skip_on_cran()

  # Codigos validos e invalidos
  codigos <- c("E11.0", "I10", "X99.9", "INVALIDO")

  expect_warning(
    resultado <- cie_validate_vector(codigos, strict = TRUE),
    "no encontrados"
  )

  # E11.0 e I10 deben estar en la DB
  expect_true(resultado[1])  # E11.0
  expect_true(resultado[2])  # I10
})

test_that("cie_validate_vector maneja NA con strict=TRUE", {
  skip_on_cran()

  codigos <- c("E11.0", NA, "I10")

  suppressWarnings({
    resultado <- cie_validate_vector(codigos, strict = TRUE)
  })

  expect_false(resultado[2])  # NA es FALSE
})

# ==============================================================================
# PRUEBAS ADICIONALES cie_expand()
# ==============================================================================

test_that("cie_expand maneja codigo vacio", {
  resultado <- cie_expand("")
  expect_length(resultado, 0)
})

test_that("cie_expand maneja NA", {
  resultado <- cie_expand(NA)
  expect_length(resultado, 0)
})

test_that("cie_expand maneja NULL", {
  resultado <- cie_expand(NULL)
  expect_length(resultado, 0)
})

test_that("cie_expand maneja codigo con subcategorias", {
  skip_on_cran()

  # E11 tiene subcategorias E11.0, E11.1, etc.
  hijos <- cie_expand("E11")
  expect_gt(length(hijos), 5)

  # Todos deben empezar con E11
  expect_true(all(grepl("^E11", hijos)))
})

# ==============================================================================
# PRUEBAS ADICIONALES COBERTURA - cie_normalizar()
# ==============================================================================

test_that("cie_normalizar maneja minusculas y mayusculas mezcladas", {
  skip_on_cran()

  expect_equal(cie_normalizar("e11.0", buscar_db = FALSE), "E11.0")
  expect_equal(cie_normalizar("E11.0", buscar_db = FALSE), "E11.0")
  expect_equal(cie_normalizar("e11", buscar_db = FALSE), "E11")
})

test_that("cie_normalizar maneja codigos con punto medio unicode", {
  skip_on_cran()

  # Punto medio (middot) a veces usado en sistemas
  # Unicode U+00B7 es eliminado por la funcion
  expect_equal(cie_normalizar("E11\u00B70", buscar_db = FALSE), "E11.0")
})

test_that("cie_normalizar maneja vector con NAs", {
  skip_on_cran()

  codigos <- c("E11.0", NA, "I10")
  resultado <- cie_normalizar(codigos, buscar_db = FALSE)

  expect_length(resultado, 3)
  expect_true(is.na(resultado[2]))
})

test_that("cie_normalizar buscar_db=TRUE con codigo de 3 digitos que tiene extension", {
  skip_on_cran()

  # I10 es codigo sin subcategorias directas
  resultado <- cie_normalizar("I10", buscar_db = TRUE)
  # Debe mantenerse como I10 o agregar 0 si existe I100
  expect_true(nchar(resultado) >= 3)
})

test_that("cie_normalizar buscar_db=TRUE preserva codigo ya normalizado", {
  skip_on_cran()

  # E11.0 existe en la base
  resultado <- cie_normalizar("E11.0", buscar_db = TRUE)
  expect_equal(resultado, "E11.0")
})

test_that("cie_normalizar buscar_db=TRUE con multiples codigos invalidos", {
  skip_on_cran()

  codigos <- c("XX9.9", "YY8.8", "ZZ7.7")
  resultado <- cie_normalizar(codigos, buscar_db = TRUE)

  # Debe retornar los codigos normalizados aunque no existan
  expect_length(resultado, 3)
})

# ==============================================================================
# PRUEBAS ADICIONALES COBERTURA - cie_validate_vector()
# ==============================================================================

test_that("cie_validate_vector maneja vector vacio", {
  resultado <- cie_validate_vector(character(0))
  expect_length(resultado, 0)
})

test_that("cie_validate_vector maneja solo NAs", {
  resultado <- cie_validate_vector(c(NA, NA, NA))
  expect_equal(resultado, c(FALSE, FALSE, FALSE))
})

test_that("cie_validate_vector strict=TRUE con todos codigos validos", {
  skip_on_cran()

  codigos <- c("E11.0", "I10")

  # No debe dar warning si todos existen
  resultado <- cie_validate_vector(codigos, strict = TRUE)

  expect_true(all(resultado))
})

test_that("cie_validate_vector strict=TRUE con mezcla validos e invalidos", {
  skip_on_cran()

  codigos <- c("E11.0", "XXXX", "I10", "YYYY")

  expect_warning(
    resultado <- cie_validate_vector(codigos, strict = TRUE),
    "no encontrados"
  )

  expect_equal(resultado[1], TRUE)   # E11.0 valido
  expect_equal(resultado[2], FALSE)  # XXXX invalido formato
  expect_equal(resultado[3], TRUE)   # I10 valido
  expect_equal(resultado[4], FALSE)  # YYYY invalido formato
})

test_that("cie_validate_vector acepta formato sin punto", {
  # E110 es formato valido MINSAL
  resultado <- cie_validate_vector(c("E110", "I100"))
  expect_equal(resultado, c(TRUE, TRUE))
})

test_that("cie_validate_vector rechaza formatos incorrectos", {
  # Formatos que no cumplen patron CIE-10
  codigos_invalidos <- c(
    "11E",      # letra al final
    "E1",       # muy corto
    "E111111",  # muy largo
    "123",      # solo numeros
    "ABCD"      # solo letras
  )

  resultado <- cie_validate_vector(codigos_invalidos)
  expect_true(all(resultado == FALSE))
})

# ==============================================================================
# PRUEBAS ADICIONALES COBERTURA - cie_expand()
# ==============================================================================

test_that("cie_expand con espacio en blanco", {
  resultado <- cie_expand("   ")
  expect_length(resultado, 0)
})

test_that("cie_expand con codigo especifico (E11.0)", {
  skip_on_cran()

  # E11.0 es codigo terminal, no tiene hijos
  hijos <- cie_expand("E11.0")

  # Puede retornar solo E11.0 o vacio
  expect_true(length(hijos) <= 1 || "E11.0" %in% hijos)
})

test_that("cie_expand con codigo de capitulo (A00-B99)", {
  skip_on_cran()

  # A00 es Colera, debe tener subcategorias
  hijos <- cie_expand("A00")

  # Debe tener al menos A00.0, A00.1, A00.9
  expect_gt(length(hijos), 0)
})

test_that("cie_expand retorna character vector", {
  skip_on_cran()

  hijos <- cie_expand("E11")

  expect_type(hijos, "character")
})

# ==============================================================================
# PRUEBAS DE EDGE CASES ADICIONALES
# ==============================================================================

test_that("cie_normalizar maneja codigo con espacios multiples", {
  skip_on_cran()

  expect_equal(cie_normalizar("E  11  0", buscar_db = FALSE), "E11.0")
  expect_equal(cie_normalizar("  E11.0  ", buscar_db = FALSE), "E11.0")
})

test_that("cie_normalizar maneja combinacion de caracteres especiales", {
  skip_on_cran()

  # Daga + espacio + guion
  expect_equal(cie_normalizar("A17\u2020 0", buscar_db = FALSE), "A17.0")

  # Asterisco + punto inicial
  expect_equal(cie_normalizar(".G01*", buscar_db = FALSE), "G01")
})

test_that("cie_validate_vector strict=FALSE acepta formato correcto sin DB", {
  # No debe conectar a DB con strict=FALSE
  codigos <- c("E11.0", "I10.0", "Z00")
  resultado <- cie_validate_vector(codigos, strict = FALSE)

  expect_equal(resultado, c(TRUE, TRUE, TRUE))
})

test_that("cie_normalizar con codigos de trauma largos", {
  skip_on_cran()

  # Codigos de lesiones/trauma pueden ser mas largos
  codigos_trauma <- c("S72.001A", "T84.50XA")

  # La funcion debe manejarlos sin error
  resultado <- cie_normalizar(codigos_trauma, buscar_db = FALSE)
  expect_length(resultado, 2)
})
