library(ciecl)

cat('====================================\n')
cat('  PRUEBA COMPLETA PAQUETE ciecl\n')
cat('====================================\n\n')

# 1. Dataset
data(cie10_cl)
cat('[1] DATASET\n')
cat('    Total codigos:', nrow(cie10_cl), '\n')
cat('    Columnas:', paste(names(cie10_cl), collapse=', '), '\n\n')

# 2. Busqueda fuzzy
cat('[2] BUSQUEDA FUZZY: diabetes\n')
res <- cie_search('diabetes', max_results=3)
for(i in 1:nrow(res)) {
  cat(sprintf('    %s (%.2f): %s\n', res$codigo[i], res$score[i], substr(res$descripcion[i], 1, 40)))
}
cat('\n')

# 3. Lookup
cat('[3] LOOKUP EXACTO: E110\n')
lookup <- cie_lookup('E110')
cat('    Codigo:', lookup$codigo[1], '\n')
cat('    Desc:', substr(lookup$descripcion[1], 1, 50), '\n\n')

# 4. Expansion
cat('[4] EXPANSION JERARQUICA: E11\n')
hijos <- cie_expand('E11')
cat('    Total hijos:', length(hijos), '\n')
cat('    Primeros 5:', paste(head(hijos, 5), collapse=', '), '\n\n')

# 5. Validacion
cat('[5] VALIDACION FORMATOS\n')
prueba <- c('E110', 'Z00', 'INVALIDO', 'E11.0', 'A009')
validos <- cie_validate_vector(prueba)
for(i in 1:length(prueba)) {
  cat(sprintf('    %-10s : %s\n', prueba[i], ifelse(validos[i], 'OK', 'ERROR')))
}
cat('\n')

# 6. SQL
cat('[6] CONSULTA SQL: Top 5 capitulos\n')
sql <- cie10_sql('SELECT capitulo, COUNT(*) n FROM cie10 GROUP BY capitulo ORDER BY n DESC LIMIT 5')
print(sql)
cat('\n')

# 7. Fuzzy typo
cat('[7] FUZZY CON TYPO: diabetis\n')
typo <- cie_search('diabetis', threshold=0.70, max_results=2)
for(i in 1:nrow(typo)) {
  cat(sprintf('    %s (%.2f): %s\n', typo$codigo[i], typo$score[i], substr(typo$descripcion[i], 1, 40)))
}
cat('\n')

cat('====================================\n')
cat('  TODAS LAS FUNCIONES OPERANDO OK\n')
cat('====================================\n')
