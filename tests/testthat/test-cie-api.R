# Tests para cie11_search (API CIE-11 OMS)

test_that("cie11_search requiere API key", {
  # Limpiar variable de entorno temporalmente
  old_key <- Sys.getenv("ICD_API_KEY")
  Sys.unsetenv("ICD_API_KEY")
  on.exit(Sys.setenv(ICD_API_KEY = old_key))

  expect_error(cie11_search("diabetes"), "API key OMS requerida")
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
  skip_if(requireNamespace("httr2", quietly = TRUE))

  expect_error(
    cie11_search("diabetes", api_key = "test:test"),
    "httr2"
  )
})
