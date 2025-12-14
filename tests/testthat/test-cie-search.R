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
  
  resultado <- cie_lookup("E110")
  expect_equal(nrow(resultado), 1)
  expect_equal(resultado$codigo, "E110")
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
  codigos <- c("E110", "Z00", "I10")
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
  codigos <- c("E110", "INVALIDO", "Z00")
  
  # Capturar mensajes de advertencia
  suppressMessages({
    resultado <- cie_lookup(codigos)
  })
  
  # Debe retornar solo los codigos validos
  expect_gt(nrow(resultado), 0)
  expect_true(all(resultado$codigo %in% c("E110", "Z00")))
})

test_that("cie_lookup vectorizado elimina duplicados", {
  skip_on_cran()
  
  # Vector con codigos duplicados
  codigos <- c("E110", "E110", "Z00")
  resultado <- cie_lookup(codigos)
  
  # No debe haber duplicados en resultado
  expect_equal(nrow(resultado), length(unique(resultado$codigo)))
})

