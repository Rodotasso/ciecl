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
