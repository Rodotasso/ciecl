# test-cie-search.R
# Pruebas para funciones de busqueda y exploracion del catálogo CIE-10

test_that("cie_search encuentra diabetes con fuzzy", {
  skip_on_cran()
  
  # Buscar diabetes
  resultado <- cie_search("diabetes mellitus", threshold = 0.70)
  expect_gt(nrow(resultado), 0)
  expect_true(any(stringr::str_detect(resultado$codigo, "^E1[0-4]")))
})

test_that("cie_lookup codigo exacto funciona", {
  skip_on_cran()
  
  resultado <- cie_lookup("E11.0")
  expect_shape(resultado, nrow = 1)
  expect_equal(resultado$codigo, "E11.0")
})

test_that("cie_lookup vectorizado elimina duplicados", {
  skip_on_cran()
  
  # Vector con codigos duplicados
  codigos <- c("E11.0", "E11.0", "Z00")
  resultado <- cie_lookup(codigos)
  
  # No debe haber duplicados en resultado
  expect_equal(nrow(resultado), length(unique(resultado$codigo)))
})

test_that("cie_lookup puede generar descripcion_completa", {
  skip_on_cran()
  
  # Con descripcion_completa
  resultado_completo <- cie_lookup("E11.0", full_description = TRUE)
  expect_true("descripcion_completa" %in% names(resultado_completo))
  expect_match(resultado_completo$descripcion_completa, "E11\\.0 - ")
})

test_that("cie_lookup con descripcion_completa mantiene columna en dataframe vacio", {
  skip_on_cran()

  # Bug fix: Cuando todos los codigos son invalidos, debe mantener la columna descripcion_completa
  suppressMessages({
    resultado_vacio <- cie_lookup(code = c("XXXX", "YYYY", "ZZZZ"), full_description = TRUE)
  })

  # El dataframe debe estar vacio
  expect_length(resultado_vacio$codigo, 0)
  expect_true("descripcion_completa" %in% names(resultado_vacio))
})

# ============================================================
# PRUEBAS PARA cie_short() (antes cie_siglas)
# ============================================================

test_that("cie_short retorna todas las siglas", {
  resultado <- cie_short()

  expect_s3_class(resultado, "tbl_df")
  expect_true("sigla" %in% names(resultado))
  expect_gt(nrow(resultado), 50)
})

test_that("cie_short no tiene duplicados", {
  resultado <- cie_short()

  # No debe haber siglas duplicadas
  expect_equal(nrow(resultado), length(unique(resultado$sigla)))
})

test_that("cie_short filtra por categoria", {
  # Filtrar cardiovasculares
  cardio <- cie_short("cardiovascular")
  expect_gt(nrow(cardio), 5)
  expect_true(all(cardio$categoria == "cardiovascular"))

  # Categoria invalida debe dar warning y retornar vacio
  expect_snapshot(invalida <- cie_short("inexistente"))
  expect_length(invalida$sigla, 0)
})

# ============================================================
# PRUEBAS PARA cie_search() (validaciones)
# ============================================================

test_that("cie_search valida inputs", {
  expect_snapshot(cie_search(123), error = TRUE)
  expect_snapshot(cie_search("a"), error = TRUE)
  expect_snapshot(cie_search("diabetes", threshold = 1.1), error = TRUE)
  expect_snapshot(cie_search("diabetes", max_results = 0), error = TRUE)
})

# ============================================================
# PRUEBAS PARA cie_guide() (antes cie_guia_busqueda)
# ============================================================

test_that("cie_guide retorna data.frame", {
  resultado <- cie_guide()

  expect_s3_class(resultado, "data.frame")
  expect_gt(nrow(resultado), 5)
  expect_true("Tengo..." %in% names(resultado))
})

# ============================================================
# PRUEBAS COBERTURA - mensaje "Sin coincidencias"
# ============================================================

test_that("cie_search muestra mensaje Sin coincidencias con verbose=TRUE", {
  skip_on_cran()

  expect_message(
    resultado <- cie_search("xyznonexistent12345abc", threshold = 0.95, verbose = TRUE),
    "Sin coincidencias"
  )

  expect_length(resultado$codigo, 0)
})

test_that("cie_lookup con normalizar procesa codigo sin punto", {
  skip_on_cran()

  # E110 -> E11.0
  resultado <- cie_lookup("E110", normalize = TRUE)

  expect_shape(resultado, nrow = 1)
  expect_equal(resultado$codigo, "E11.0")
})

test_that("extract_cie_from_text extrae codigo de texto con ruido", {
  skip_on_cran()

  # Con prefijo
  resultado1 <- extract_cie_from_text("CIE:E11.0")
  expect_equal(resultado1, "E11.0")

  # Con sufijo
  resultado2 <- extract_cie_from_text("I10-confirmado")
  expect_equal(resultado2, "I10")

  # Sin ruido
  resultado3 <- extract_cie_from_text("E11.0")
  expect_equal(resultado3, "E11.0")
})
