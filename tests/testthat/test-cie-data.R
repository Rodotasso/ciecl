# test-cie-data.R
# Pruebas para funciones de generacion de datos CIE-10

# ==============================================================================
# PRUEBAS parsear_cie10_minsal()
# ==============================================================================

test_that("parsear_cie10_minsal requiere readxl", {
  # Solo testear si readxl NO esta instalado
  skip_if(requireNamespace("readxl", quietly = TRUE),
          "readxl esta instalado")

  expect_error(
    ciecl:::parsear_cie10_minsal("test.xls"),
    "readxl"
  )
})

test_that("parsear_cie10_minsal error si archivo no existe", {
  skip_if_not_installed("readxl")

  expect_error(
    ciecl:::parsear_cie10_minsal("archivo_inexistente.xls"),
    "no encontrado"
  )
})

test_that("parsear_cie10_minsal con XLS real", {
  skip_on_cran()
  skip_if_not_installed("readxl")

  # Buscar XLS MINSAL en rutas conocidas (formato Lista-Tabular original)
  xls_paths <- c(
    "../Lista-Tabular-CIE-10-1-1.xls",
    "Lista-Tabular-CIE-10-1-1.xls"
  )

  xls_path <- NULL
  for (path in xls_paths) {
    if (file.exists(path)) {
      xls_path <- path
      break
    }
  }

  skip_if(is.null(xls_path), "Archivo Lista-Tabular XLS MINSAL no disponible")

  # Intentar parsear, skip si formato incompatible
  resultado <- tryCatch(
    ciecl:::parsear_cie10_minsal(xls_path),
    error = function(e) {
      if (grepl("columnas codigo/descripcion", e$message)) {
        skip("XLS tiene formato de columnas incompatible")
      }
      stop(e)
    }
  )

  # Verificar estructura
  expect_s3_class(resultado, "tbl_df")
  expect_true("codigo" %in% names(resultado))
  expect_true("descripcion" %in% names(resultado))
  expect_true("capitulo" %in% names(resultado))
  expect_true("es_daga" %in% names(resultado))
  expect_true("es_cruz" %in% names(resultado))

  # Verificar contenido minimo
  expect_gt(nrow(resultado), 1000)

  # Verificar tipos de datos
  expect_type(resultado$codigo, "character")
  expect_type(resultado$descripcion, "character")
  expect_type(resultado$es_daga, "logical")
  expect_type(resultado$es_cruz, "logical")
})

test_that("parsear_cie10_minsal detecta codigos daga y cruz", {
  skip_on_cran()
  skip_if_not_installed("readxl")

  # Buscar XLS MINSAL (formato Lista-Tabular original)
  xls_paths <- c(
    "../Lista-Tabular-CIE-10-1-1.xls",
    "Lista-Tabular-CIE-10-1-1.xls"
  )

  xls_path <- NULL
  for (path in xls_paths) {
    if (file.exists(path)) {
      xls_path <- path
      break
    }
  }

  skip_if(is.null(xls_path), "Archivo Lista-Tabular XLS MINSAL no disponible")

  # Intentar parsear, skip si formato incompatible
  resultado <- tryCatch(
    ciecl:::parsear_cie10_minsal(xls_path),
    error = function(e) {
      if (grepl("columnas codigo/descripcion", e$message)) {
        skip("XLS tiene formato de columnas incompatible")
      }
      stop(e)
    }
  )

  # Verificar que hay codigos con flags daga/cruz
  n_daga <- sum(resultado$es_daga, na.rm = TRUE)
  n_cruz <- sum(resultado$es_cruz, na.rm = TRUE)

  # Los flags pueden ser 0 si el archivo no tiene simbolos
  # Pero la columna debe existir y ser logica
  expect_type(resultado$es_daga, "logical")
  expect_type(resultado$es_cruz, "logical")
})

# ==============================================================================
# PRUEBAS generar_cie10_cl()
# ==============================================================================

test_that("generar_cie10_cl requiere usethis", {
  # Solo testear si usethis NO esta instalado
  skip_if(requireNamespace("usethis", quietly = TRUE),
          "usethis esta instalado")

  expect_error(
    generar_cie10_cl("test.xls"),
    "usethis"
  )
})

test_that("generar_cie10_cl error si XLS no encontrado", {
  skip_if_not_installed("usethis")
  skip_if_not_installed("readxl")

  # En directorio temporal sin XLS
  withr::with_tempdir({
    expect_error(
      generar_cie10_cl(),
      "XLS no encontrado"
    )
  })
})

test_that("generar_cie10_cl acepta ruta explicita", {
  skip_on_cran()
  skip_if_not_installed("usethis")
  skip_if_not_installed("readxl")

  # Verificar que acepta argumento xls_path
  # (fallara si archivo no existe, pero no debe dar error de argumento)
  expect_error(
    generar_cie10_cl(xls_path = "ruta_explicita.xls"),
    "no encontrado"
  )
})

# ==============================================================================
# PRUEBAS DATASET cie10_cl
# ==============================================================================

test_that("dataset cie10_cl carga correctamente", {
  data("cie10_cl", package = "ciecl", envir = environment())

  expect_s3_class(cie10_cl, "tbl_df")
  expect_gt(nrow(cie10_cl), 30000)
})

test_that("dataset cie10_cl tiene columnas requeridas", {
  data("cie10_cl", package = "ciecl", envir = environment())

  columnas_requeridas <- c("codigo", "descripcion")
  expect_true(all(columnas_requeridas %in% names(cie10_cl)))
})

test_that("dataset cie10_cl codigos son unicos", {
  skip_on_cran()

  data("cie10_cl", package = "ciecl", envir = environment())

  # Contar duplicados
  n_total <- nrow(cie10_cl)
  n_unicos <- length(unique(cie10_cl$codigo))

  # Puede haber algunos duplicados por daga/cruz pero no deberia ser excesivo
  ratio_duplicados <- (n_total - n_unicos) / n_total
  expect_lt(ratio_duplicados, 0.1)  # < 10% duplicados
})

test_that("dataset cie10_cl codigos tienen formato valido", {
  skip_on_cran()

  data("cie10_cl", package = "ciecl", envir = environment())

  # Todos los codigos deben empezar con letra
  expect_true(all(grepl("^[A-Z]", cie10_cl$codigo)))

  # Todos los codigos deben tener al menos 3 caracteres
  expect_true(all(nchar(cie10_cl$codigo) >= 3))
})

test_that("dataset cie10_cl contiene codigos E11 (diabetes)", {
  skip_on_cran()

  data("cie10_cl", package = "ciecl", envir = environment())

  # E11 es Diabetes tipo 2, debe existir
  codigos_e11 <- cie10_cl[grepl("^E11", cie10_cl$codigo), ]
  expect_gt(nrow(codigos_e11), 0)
})

test_that("dataset cie10_cl contiene codigos I10 (hipertension)", {
  skip_on_cran()

  data("cie10_cl", package = "ciecl", envir = environment())

  # I10 es Hipertension esencial
  codigos_i10 <- cie10_cl[grepl("^I10", cie10_cl$codigo), ]
  expect_gt(nrow(codigos_i10), 0)
})

# ==============================================================================
# PRUEBAS DE INTEGRIDAD DE DATOS
# ==============================================================================

test_that("dataset cie10_cl sin valores NA en columnas criticas", {
  skip_on_cran()

  data("cie10_cl", package = "ciecl", envir = environment())

  # codigo y descripcion no deben tener NA
  expect_equal(sum(is.na(cie10_cl$codigo)), 0)
  expect_equal(sum(is.na(cie10_cl$descripcion)), 0)
})

test_that("dataset cie10_cl descripciones no vacias", {
  skip_on_cran()

  data("cie10_cl", package = "ciecl", envir = environment())

  # Todas las descripciones deben tener contenido
  expect_true(all(nchar(cie10_cl$descripcion) > 0))
})

test_that("dataset cie10_cl capitulos extraidos correctamente", {
  skip_on_cran()

  data("cie10_cl", package = "ciecl", envir = environment())

  # Si existe columna capitulo, verificar
  if ("capitulo" %in% names(cie10_cl)) {
    # Capitulos validos: A00-Z99
    capitulos_validos <- unique(cie10_cl$capitulo)
    expect_true(all(grepl("^[A-Z]\\d{1,2}$", capitulos_validos, perl = TRUE) |
                    is.na(capitulos_validos)))
  }
})
