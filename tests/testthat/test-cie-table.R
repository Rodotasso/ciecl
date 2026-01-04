# Tests para cie_table (tablas gt)

test_that("cie_table requiere gt instalado",
{
  skip_if_not_installed("gt")

  # Test basico con codigo valido
  tabla <- cie_table("E11")
  expect_s3_class(tabla, "gt_tbl")
})

test_that("cie_table funciona con multiples codigos", {
  skip_if_not_installed("gt")
  skip_on_cran()

  tabla <- cie_table(c("E11", "I10"))
  expect_s3_class(tabla, "gt_tbl")
})

test_that("cie_table maneja codigo invalido", {
  skip_if_not_installed("gt")
  skip_on_cran()

  # Codigo que no existe lanza error
  expect_error(cie_table("XXXXX"), "no encontrado")
})
