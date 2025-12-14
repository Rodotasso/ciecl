test_that("cie_search encuentra diabetes con fuzzy", {
  skip_on_cran()
  
  resultado <- cie_search("diabetis mellitus", threshold = 0.75)
  expect_gt(nrow(resultado), 0)
  expect_true(any(stringr::str_detect(resultado$codigo, "^E1")))
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
