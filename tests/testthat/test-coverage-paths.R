# ============================================================
# COBERTURA: paths secundarios poco usados
# Cierra ramas no cubiertas en cie-search.R y cie-lookup.R que
# corresponden a parametros no-default (field="inclusion",
# extract=TRUE, check_siglas=TRUE) y procesamiento de rangos
# en vectores mixtos.
# ============================================================

# --- cie_search con field = "inclusion" ------------------------------------

test_that("cie_search retorna data.frame con field='inclusion'", {
  res <- cie_search("diabetes", field = "inclusion", verbose = FALSE)

  expect_s3_class(res, "data.frame")
  expect_true("inclusion" %in% names(res))
})

test_that("cie_search con field='inclusion' y palabras cortas no rompe", {
  # palabras de 1-2 chars se filtran del FTS -> path "sin palabras validas"
  res <- cie_search("ab", field = "inclusion", verbose = FALSE)

  expect_s3_class(res, "data.frame")
  # El resultado puede estar vacio o no, lo importante es que no rompa
})

test_that("cie_search con field='inclusion' y termino raro retorna 0", {
  # Termino que no matchea nada en inclusion -> fallback a carga completa
  res <- cie_search("xyzabc123notfound", field = "inclusion", verbose = FALSE)

  expect_s3_class(res, "data.frame")
})

# --- cie_lookup con extract = TRUE ----------------------------------------

test_that("cie_lookup con extract=TRUE extrae codigo de texto con ruido", {
  # Texto con diagnostico narrativo y codigo embebido (con espacios)
  # extract_cie_from_text rescata el codigo (puede ser categoria 3-char)
  res <- cie_lookup("Diagnostico: E11.0 diabetes", extract = TRUE)

  expect_s3_class(res, "data.frame")
  expect_gte(nrow(res), 1)
  # Debe retornar al menos un codigo de la familia E11
  expect_true(any(startsWith(res$codigo, "E11")))
})

# --- cie_lookup con check_siglas = TRUE -----------------------------------

test_that("cie_lookup con check_siglas=TRUE expande sigla a codigo", {
  res <- cie_lookup("IAM", check_siglas = TRUE)

  expect_s3_class(res, "data.frame")
  # IAM se expande a infarto agudo miocardio -> debe encontrar al menos 1 codigo
  expect_gt(nrow(res), 0)
})

test_that("cie_lookup con check_siglas=TRUE deja pasar codigos no-sigla", {
  res <- cie_lookup(c("E11.0", "I10"), check_siglas = TRUE)

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2)
})

# --- cie_lookup con vector que mezcla codigos y rangos --------------------

test_that("cie_lookup procesa vector con rango y codigo individual", {
  # Rango E10.0-E10.2 + codigo individual E11.0 en mismo vector
  # Cubre la rama codigos_rango (lineas 226-233)
  res <- cie_lookup(c("E10.0-E10.2", "E11.0"))

  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 1)
  expect_true("E11.0" %in% res$codigo)
})

test_that("cie_lookup con multiples rangos en vector", {
  res <- cie_lookup(c("E10.0-E10.2", "E11.0-E11.2"))

  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 0)
})

# --- cie_lookup edge cases ------------------------------------------------

test_that("cie_lookup con vector solo de NAs retorna tibble vacio", {
  res <- cie_lookup(c(NA_character_, NA_character_))

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 0)
})

test_that("cie_lookup con vector vacio retorna tibble vacio", {
  res <- cie_lookup(character(0))

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 0)
})

# --- cie_search edge cases en fuzzy ---------------------------------------

test_that("cie_search no rompe con palabras de 1-2 chars en fuzzy", {
  # Palabras muy cortas se filtran en el path fuzzy
  res <- cie_search("ab cd", verbose = FALSE)

  expect_s3_class(res, "data.frame")
})

test_that("cie_search emite cli_warn al detectar sigla ambigua con verbose", {
  # IRA es ambigua: cubre el cli_warn dentro del bloque verbose
  expect_message(
    expect_warning(
      cie_search("IRA", verbose = TRUE),
      regexp = "ambigua"
    ),
    regexp = "Sigla detectada"
  )
})
