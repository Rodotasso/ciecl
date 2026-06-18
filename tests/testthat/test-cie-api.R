# Tests para cie11_search (API CIE-11 OMS)

test_that("cie11_search requiere API key", {
  testthat::local_reproducible_output()
  withr::with_envvar(c(ICD_API_KEY = NA), {
    expect_snapshot(cie11_search("diabetes"), error = TRUE)
  })
})

test_that("cie11_search valida formato de API key", {
  testthat::local_reproducible_output()
  skip_if_not_installed("httr2")

  # API key sin separador ":"
  expect_snapshot(
    cie11_search("diabetes", api_key = "invalid_key_format"),
    error = TRUE
  )
})

test_that("cie11_search requiere httr2", {
  testthat::local_reproducible_output()
  # Solo corre si httr2 NO esta disponible para verificar el error
  skip_if(requireNamespace("httr2", quietly = TRUE), "httr2 esta instalado")

  expect_snapshot(
    cie11_search("diabetes", api_key = "test:test"),
    error = TRUE
  )
})

# ============================================================
# PRUEBAS CON API REAL (skip_on_cran, requiere ICD_API_KEY)
# ============================================================

test_that("cie11_search con API real retorna resultados", {
  skip_on_cran()
  skip_if_not_installed("httr2")

  # Verificar que existe API key en environment
  api_key <- Sys.getenv("ICD_API_KEY", unset = NA)
  skip_if(
    is.na(api_key) || api_key == "",
    "ICD_API_KEY no configurada para tests reales"
  )

  # Buscar termino comun que debe existir
  resultado <- cie11_search("diabetes", max_results = 2)

  expect_s3_class(resultado, "tbl_df")
  expect_true("codigo" %in% names(resultado))
  expect_true("titulo" %in% names(resultado))
  expect_true("capitulo" %in% names(resultado))
  expect_lte(nrow(resultado), 2)
  if (nrow(resultado) > 0) {
    # Usar expect_no_match como sugirio Maelle
    expect_no_match(resultado$titulo, "<em")
    expect_no_match(resultado$titulo, "</em>")
  }
})

test_that("cie11_search con API real maneja busqueda sin resultados", {
  skip_on_cran()
  skip_if_not_installed("httr2")

  api_key <- Sys.getenv("ICD_API_KEY", unset = NA)
  skip_if(
    is.na(api_key) || api_key == "",
    "ICD_API_KEY no configurada para tests reales"
  )

  # Buscar termino que probablemente no existe
  expect_message(
    resultado <- cie11_search("xyznonexistent12345"),
    "Sin resultados"
  )

  expect_s3_class(resultado, "tbl_df")
  expect_length(resultado$codigo, 0)
})

# ... rest of file (omitted for brevity in explanation, but including essential structural tests)

test_that("cie11_search retorna tibble con tipos correctos incluso en error", {
  skip_if_not_installed("httr2")

  suppressWarnings({
    resultado <- cie11_search("test", api_key = "fake:key")
  })

  expect_true("codigo" %in% names(resultado))
  expect_type(resultado$codigo, "character")
})

test_that("cie11_search valida tipos de input", {
  testthat::local_reproducible_output()
  skip_if_not_installed("httr2")

  expect_snapshot(cie11_search(123), error = TRUE)
  expect_snapshot(cie11_search(c("a", "b")), error = TRUE)
  expect_snapshot(cie11_search(NA_character_), error = TRUE)
})
