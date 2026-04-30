# Sanity-check del generador antes de regenerar data/cie10_cl.rda
# Ejecutar con: Rscript data-raw/test_generate_cie10_cl.R

library(dplyr)
library(stringr)
library(tibble)
source("data-raw/generate_cie10_cl.R")

# Test 1: error si archivo no existe
cat("Test 1: Archivo inexistente... ")
e <- tryCatch(parsear_cie10_minsal("ghost.xls"), error = identity)
stopifnot(inherits(e, "error"), grepl("no encontrado", e$message))
cat("OK\n")

# Test 2: parseo XLSX real (si existe en rutas conocidas)
xls_paths <- c(
  "../CIE-10 (1).xlsx",
  "CIE-10 (1).xlsx",
  "../analisis_bases/CIE-10 (1).xlsx"
)

xls_path <- NULL
for (path in xls_paths) {
  if (file.exists(path)) {
    xls_path <- path
    break
  }
}

if (!is.null(xls_path)) {
  cat("Test 2: Parseo XLSX real (", xls_path, ")... ", sep = "")
  df <- parsear_cie10_minsal(xls_path)
  stopifnot(
    is_tibble(df),
    nrow(df) >= 30000,
    all(c("codigo", "descripcion", "capitulo") %in% names(df))
  )
  cat("OK (", nrow(df), " filas)\n", sep = "")
} else {
  cat("Test 2: Saltado (archivo real no encontrado)\n")
}

cat("\nTodos los tests de generador completados con exito.\n")
