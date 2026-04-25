# Tests para cie11_search (API CIE-11 OMS)

test_that("cie11_search requiere API key", {
  withr::with_envvar(c(ICD_API_KEY = NA), {
    expect_error(cie11_search("diabetes"), "API key OMS requerida")
  })
})

test_that("cie11_search valida formato de API key", {
  skip_if_not_installed("httr2")

  # API key sin separador ":"
  expect_error(
    cie11_search("diabetes", api_key = "invalid_key_format"),
    "client_id:client_secret"
  )
})

test_that("cie11_search requiere httr2", {
  # Solo corre si httr2 NO esta disponible para verificar el error
  skip_if(requireNamespace("httr2", quietly = TRUE), "httr2 esta instalado")

  expect_error(
    cie11_search("diabetes", api_key = "test:test"),
    "httr2"
  )
})

# ============================================================
# PRUEBAS CON API REAL (skip_on_cran, requiere ICD_API_KEY)
# ============================================================

test_that("cie11_search con API real retorna resultados", {
  skip_on_cran()
  skip_if_not_installed("httr2")
  skip_if_offline()

  # Verificar que existe API key en environment
  api_key <- Sys.getenv("ICD_API_KEY", unset = NA)
  skip_if(is.na(api_key) || api_key == "",
          "ICD_API_KEY no configurada para tests reales")

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
  skip_if_offline()

  api_key <- Sys.getenv("ICD_API_KEY", unset = NA)
  skip_if(is.na(api_key) || api_key == "",
          "ICD_API_KEY no configurada para tests reales")

  # Buscar termino que probablemente no existe
  expect_message(
    resultado <- cie11_search("xyznonexistent12345"),
    "Sin resultados"
  )

  expect_s3_class(resultado, "tbl_df")
  expect_equal(nrow(resultado), 0L)
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
  skip_if_not_installed("httr2")

  expect_error(cie11_search(123), "string")
  expect_error(cie11_search(c("a", "b")), "string")
  expect_error(cie11_search(NA_character_), "string")
})
