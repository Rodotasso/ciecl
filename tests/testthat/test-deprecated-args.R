# ============================================================
# COBERTURA: paths de deprecacion de argumentos espanol -> ingles
# Cierra los paths `lifecycle::deprecate_warn()` que estaban
# sin cobertura en cie-utils.R, cie-search.R, cie-lookup.R.
# ============================================================

# --- cie_norm ---------------------------------------------------------------

test_that("cie_norm acepta arg deprecado 'codigos' con warning", {
  expect_warning(
    res <- cie_norm(codigos = "E110"),
    class = "lifecycle_warning_deprecated"
  )
  expect_equal(res, cie_norm("E110"))
})

test_that("cie_norm acepta arg deprecado 'buscar_db' con warning", {
  expect_warning(
    res <- cie_norm("E11.0", buscar_db = FALSE),
    class = "lifecycle_warning_deprecated"
  )
  expect_equal(res, cie_norm("E11.0", search_db = FALSE))
})

test_that("cie_norm convierte factor a character", {
  fac <- factor("E11.0")
  res <- cie_norm(fac, search_db = FALSE)
  expect_type(res, "character")
  expect_equal(res, "E11.0")
})

# --- cie_normalizar (deprecada completa) ------------------------------------

test_that("cie_normalizar emite warning de deprecacion completa", {
  expect_warning(
    res <- cie_normalizar("E110"),
    class = "lifecycle_warning_deprecated"
  )
  expect_equal(res, cie_norm("E110"))
})

test_that("cie_normalizar pasa buscar_db al backend", {
  expect_warning(
    res <- cie_normalizar("E11.0", buscar_db = FALSE),
    class = "lifecycle_warning_deprecated"
  )
  expect_equal(res, "E11.0")
})

# --- cie_normalize (deprecada completa, alias EN) ---------------------------

test_that("cie_normalize emite warning de deprecacion completa", {
  expect_warning(
    res <- cie_normalize("E110"),
    class = "lifecycle_warning_deprecated"
  )
  expect_equal(res, cie_norm("E110"))
})

test_that("cie_normalize acepta arg deprecado 'codigos'", {
  expect_warning(
    expect_warning(
      res <- cie_normalize(codigos = "E110"),
      class = "lifecycle_warning_deprecated"
    ),
    class = "lifecycle_warning_deprecated"
  )
  expect_equal(res, cie_norm("E110"))
})

test_that("cie_normalize acepta arg deprecado 'buscar_db'", {
  expect_warning(
    expect_warning(
      res <- cie_normalize("E11.0", buscar_db = FALSE),
      class = "lifecycle_warning_deprecated"
    ),
    class = "lifecycle_warning_deprecated"
  )
  expect_equal(res, "E11.0")
})

# --- cie_validate_vector ---------------------------------------------------

test_that("cie_validate_vector acepta arg deprecado 'codigos'", {
  expect_warning(
    res <- cie_validate_vector(codigos = c("E11.0", "INVALIDO")),
    class = "lifecycle_warning_deprecated"
  )
  expect_length(res, 2)
  expect_true(res[1])
  expect_false(res[2])
})

# --- cie_expand ------------------------------------------------------------

test_that("cie_expand acepta arg deprecado 'codigo'", {
  expect_warning(
    res <- cie_expand(codigo = "E11"),
    class = "lifecycle_warning_deprecated"
  )
  expect_type(res, "character")
  expect_gt(length(res), 0)
})

# --- cie_search ------------------------------------------------------------

test_that("cie_search acepta arg deprecado 'texto'", {
  expect_warning(
    res <- cie_search(texto = "diabetes", verbose = FALSE),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 0)
})

test_that("cie_search acepta arg deprecado 'campo'", {
  expect_warning(
    res <- cie_search("diabetes", campo = "descripcion", verbose = FALSE),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "data.frame")
})

test_that("cie_search acepta arg deprecado 'solo_fuzzy'", {
  expect_warning(
    res <- cie_search("diabetes", solo_fuzzy = TRUE, verbose = FALSE),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "data.frame")
})

# --- cie11_search (API) ----------------------------------------------------

test_that("cie11_search acepta arg deprecado 'texto' (sin invocar API)", {
  # Capturamos solo el warning de deprecation; despues falla por API/key
  # pero el path deprecation queda cubierto.
  expect_warning(
    tryCatch(
      cie11_search(texto = "diabetes", api_key = "fake"),
      error = function(e) NULL
    ),
    class = "lifecycle_warning_deprecated"
  )
})

# --- cie_table -------------------------------------------------------------

test_that("cie_table acepta arg deprecado 'codigo'", {
  skip_if_not_installed("gt")

  expect_warning(
    res <- cie_table(codigo = "E11"),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "gt_tbl")
})

# --- cie_map_comorbid ------------------------------------------------------

test_that("cie_map_comorbid acepta arg deprecado 'codigos'", {
  expect_warning(
    res <- cie_map_comorbid(codigos = c("E11.0", "I50.9")),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 0)
})

# --- cie_lookup ------------------------------------------------------------

test_that("cie_lookup acepta arg deprecado 'codigo'", {
  expect_warning(
    res <- cie_lookup(codigo = "E11.0"),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1)
})

test_that("cie_lookup acepta arg deprecado 'expandir'", {
  expect_warning(
    res <- cie_lookup("E11", expandir = TRUE),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 1)
})

test_that("cie_lookup acepta arg deprecado 'normalizar'", {
  expect_warning(
    res <- cie_lookup("E110", normalizar = TRUE),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1)
})

test_that("cie_lookup acepta arg deprecado 'descripcion_completa'", {
  expect_warning(
    res <- cie_lookup("E11.0", descripcion_completa = TRUE),
    class = "lifecycle_warning_deprecated"
  )
  expect_s3_class(res, "data.frame")
  expect_true("descripcion_completa" %in% names(res))
})
