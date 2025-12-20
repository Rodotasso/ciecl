test_that("cie_search encuentra diabetes con fuzzy", {
  skip_on_cran()
  
  # Buscar diabetes (sin typo para mayor certeza)
  resultado <- cie_search("diabetes mellitus", threshold = 0.70)
  expect_gt(nrow(resultado), 0)
  # Codigos E10x-E14x (diabetes sin punto decimal)
  expect_true(any(stringr::str_detect(resultado$codigo, "^E1[0-4]")))
})

test_that("cie_lookup codigo exacto funciona", {
  skip_on_cran()
  
  resultado <- cie_lookup("E11.0")
  expect_equal(nrow(resultado), 1)
  expect_equal(resultado$codigo, "E11.0")
})

test_that("cie_lookup expansion jerarquica funciona", {
  skip_on_cran()
  
  hijos <- cie_lookup("E11", expandir = TRUE)
  expect_gt(nrow(hijos), 5)  # E11.0, E11.1, ...
  expect_true(all(stringr::str_starts(hijos$codigo, "E11")))
})

test_that("cie_lookup acepta vectores de multiples codigos", {
  skip_on_cran()
  
  # Vector con multiples codigos
  codigos <- c("E11.0", "Z00", "I10")
  resultado <- cie_lookup(codigos)
  
  # Debe retornar resultados para al menos algunos codigos
  expect_gt(nrow(resultado), 0)
  
  # Los codigos en el resultado deben estar en nuestra lista original
  # (puede haber mas si algun codigo tiene expansion)
  expect_true(any(resultado$codigo %in% codigos))
})

test_that("cie_lookup vectorizado maneja codigos invalidos", {
  skip_on_cran()
  
  # Mezcla de codigos validos e invalidos
  codigos <- c("E11.0", "INVALIDO", "Z00")
  
  # Capturar mensajes de advertencia
  suppressMessages({
    resultado <- cie_lookup(codigos)
  })
  
  # Debe retornar solo los codigos validos
  expect_gt(nrow(resultado), 0)
  expect_true(all(resultado$codigo %in% c("E11.0", "Z00")))
})

test_that("cie_lookup vectorizado elimina duplicados", {
  skip_on_cran()
  
  # Vector con codigos duplicados
  codigos <- c("E11.0", "E11.0", "Z00")
  resultado <- cie_lookup(codigos)
  
  # No debe haber duplicados en resultado
  expect_equal(nrow(resultado), length(unique(resultado$codigo)))
})

test_that("cie_lookup acepta multiples formatos de codigo", {
  skip_on_cran()
  
  # Probar con punto
  resultado_punto <- cie_lookup("E11.0")
  expect_equal(nrow(resultado_punto), 1)
  expect_equal(resultado_punto$codigo, "E11.0")
  
  # Probar sin punto (debe normalizar)
  resultado_sin_punto <- cie_lookup("E110")
  expect_equal(nrow(resultado_sin_punto), 1)
  expect_equal(resultado_sin_punto$codigo, "E11.0")
  
  # Ambos deben dar el mismo resultado
  expect_equal(resultado_punto$codigo, resultado_sin_punto$codigo)
})

test_that("cie_lookup puede generar descripcion_completa", {
  skip_on_cran()
  
  # Sin descripcion_completa
  resultado_normal <- cie_lookup("E11.0")
  expect_false("descripcion_completa" %in% names(resultado_normal))
  
  # Con descripcion_completa
  resultado_completo <- cie_lookup("E11.0", descripcion_completa = TRUE)
  expect_true("descripcion_completa" %in% names(resultado_completo))
  expect_true(stringr::str_detect(resultado_completo$descripcion_completa, "E11\\.0 - "))
})
test_that("cie_lookup con descripcion_completa mantiene columna en dataframe vacio", {
  skip_on_cran()
  
  # Bug fix: Cuando todos los codigos son invalidos, debe mantener la columna descripcion_completa
  suppressMessages({
    resultado_vacio <- cie_lookup(codigo = c("XXXX", "YYYY", "ZZZZ"), descripcion_completa = TRUE)
  })
  
  # El dataframe debe estar vacio
  expect_equal(nrow(resultado_vacio), 0)
  
  # Pero debe tener 11 columnas incluyendo descripcion_completa
  expect_equal(ncol(resultado_vacio), 11)
  expect_true("descripcion_completa" %in% names(resultado_vacio))
  
  # Verificar nombres de todas las columnas esperadas
  columnas_esperadas <- c("codigo", "descripcion", "categoria", "seccion", 
                          "capitulo_nombre", "inclusion", "exclusion", "capitulo", 
                          "es_daga", "es_cruz", "descripcion_completa")
  expect_equal(names(resultado_vacio), columnas_esperadas)
})