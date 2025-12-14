# Script para generar dataset CIE-10 desde XLS MINSAL
# Ejecutar UNA VEZ antes de usar el paquete

# 1. Verificar que estamos en el directorio correcto
if (!file.exists("R/cie-data.R")) {
  stop("ERROR: Ejecutar este script desde el directorio ciecl/")
}

# 2. Verificar que el archivo XLS existe
xls_path <- "../Lista-Tabular-CIE-10-1-1.xls"
if (!file.exists(xls_path)) {
  stop("ERROR: Archivo XLS no encontrado en: ", normalizePath(xls_path, mustWork = FALSE))
}

# 3. Cargar funciones necesarias
cat("Cargando funciones de parseo...\n")
source("R/cie-data.R")

# 4. Generar dataset
cat("Generando dataset cie10_cl.rda desde XLS MINSAL...\n")
cat("Esto puede tomar unos minutos...\n\n")

tryCatch({
  cie10_cl <- generar_cie10_cl()
  
  cat("\n===== DATASET GENERADO EXITOSAMENTE =====\n")
  cat("Archivo: data/cie10_cl.rda\n")
  cat("Registros:", nrow(cie10_cl), "\n")
  cat("Columnas:", paste(names(cie10_cl), collapse = ", "), "\n\n")
  
  cat("Primeras filas:\n")
  print(head(cie10_cl))
  
  cat("\n===== SIGUIENTES PASOS =====\n")
  cat("1. Ejecutar: devtools::document()\n")
  cat("2. Ejecutar: devtools::install()\n")
  cat("3. Ejecutar: devtools::check()\n")
  cat("4. Probar: library(ciecl); data(cie10_cl)\n")
  
}, error = function(e) {
  cat("\n===== ERROR =====\n")
  cat("No se pudo generar el dataset.\n")
  cat("Mensaje de error:", e$message, "\n\n")
  cat("Posibles causas:\n")
  cat("- El archivo XLS no tiene la estructura esperada\n")
  cat("- Faltan paquetes: readxl, dplyr, stringr, tibble, usethis\n")
  cat("- Problemas de encoding\n\n")
  cat("Instalar dependencias con:\n")
  cat("install.packages(c('readxl', 'dplyr', 'stringr', 'tibble', 'usethis'))\n")
})
