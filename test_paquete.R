setwd("d:/MAGISTER/01_Paquete_R/ciecl")
devtools::load_all()

cat("\n========================================\n")
cat("  PRUEBAS DEL PAQUETE ciecl\n")
cat("========================================\n\n")

# Prueba 1: Dataset
cat("1. DATASET CIE10_CL\n")
data(cie10_cl)
cat("   Filas:", nrow(cie10_cl), "\n")
cat("   Columnas:", paste(names(cie10_cl), collapse = ", "), "\n\n")
print(head(cie10_cl, 3))

# Prueba 2: SQL - Contar registros
cat("\n2. SQL: Contar total registros\n")
resultado <- cie10_sql("SELECT COUNT(*) as total FROM cie10")
print(resultado)

# Prueba 3: SQL - Buscar diabetes
cat("\n3. SQL: Buscar codigos de diabetes\n")
diabetes <- cie10_sql("SELECT codigo, descripcion FROM cie10 WHERE descripcion LIKE '%DIABETES%' LIMIT 5")
print(diabetes)

# Prueba 4: Busqueda exacta
cat("\n4. LOOKUP: Buscar codigo E11.0\n")
lookup_result <- cie_lookup("E11.0")
print(lookup_result)

# Prueba 5: Expansion jerarquica
cat("\n5. EXPAND: Expandir codigo E11\n")
hijos <- cie_expand("E11")
cat("   Codigos hijos encontrados:", length(hijos), "\n")
print(head(hijos, 10))

# Prueba 6: Validacion
cat("\n6. VALIDACION: Validar formatos\n")
codigos_test <- c("E11.0", "Z00", "INVALIDO", "A00.0")
validos <- cie_validate_vector(codigos_test)
cat("   Codigos:", paste(codigos_test, collapse = ", "), "\n")
cat("   Validos:", paste(validos, collapse = ", "), "\n")

# Prueba 7: Busqueda fuzzy
cat("\n7. FUZZY SEARCH: Buscar 'diabetis' (con typo)\n")
fuzzy_result <- cie_search("diabetis", threshold = 0.75, max_results = 3)
print(fuzzy_result)

cat("\n========================================\n")
cat("  TODAS LAS PRUEBAS COMPLETADAS\n")
cat("========================================\n")
