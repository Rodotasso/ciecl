# =============================================================================
# Benchmark a gran escala para ciecl
# Contexto: GITTESIS tiene 21M egresos hospitalarios (~35K codigos unicos)
# Uso: source("tools/benchmark_large_scale.R")
# =============================================================================

if (!requireNamespace("bench", quietly = TRUE)) {
  stop("Instalar bench: install.packages('bench')")
}

library(ciecl)
library(dplyr)

# --- Setup: datos sinteticos con distribucion Pareto ---

set.seed(42)

# Cargar codigos reales del dataset
data("cie10_cl", package = "ciecl", envir = environment())
todos_codigos <- cie10_cl$codigo

# Distribucion Pareto: top 500 codigos = ~80% frecuencia
top_500 <- sample(todos_codigos, min(500, length(todos_codigos)))
resto <- setdiff(todos_codigos, top_500)

generar_codigos <- function(n, prop_top = 0.8) {
  n_top <- round(n * prop_top)
  n_resto <- n - n_top
  c(
    sample(top_500, n_top, replace = TRUE),
    sample(resto, n_resto, replace = TRUE)
  )
}

cat("=== Benchmark ciecl a gran escala ===\n")
cat("Codigos disponibles:", length(todos_codigos), "\n")
cat("Top 500 codigos (80% frecuencia)\n\n")

# --- Seccion 1: Patron GITTESIS (unique + lookup + left_join) ---

cat("--- Patron GITTESIS: unique() -> cie_lookup() -> left_join() ---\n\n")

for (n in c(1e4, 1e5, 1e6)) {
  codigos_sim <- generar_codigos(n)
  df_sim <- tibble(id = seq_len(n), codigo = codigos_sim)

  t <- system.time({
    unicos <- unique(codigos_sim)
    resultado_lookup <- cie_lookup(unicos)
    df_final <- left_join(df_sim, resultado_lookup, by = "codigo")
  })

  cat(sprintf(
    "  n=%7s | unicos=%5d | lookup+join: %.2fs (user: %.2fs)\n",
    format(n, big.mark = ","), length(unique(codigos_sim)),
    t["elapsed"], t["user.self"]
  ))
}

# --- Seccion 2: Escalabilidad por funcion ---

cat("\n--- Escalabilidad por funcion ---\n\n")

escalas <- c(1e4, 1e5, 1e6)

# cie_lookup()
cat("cie_lookup():\n")
for (n in escalas) {
  codigos_sim <- generar_codigos(n)
  unicos <- unique(codigos_sim)
  t <- system.time(cie_lookup(unicos))
  cat(sprintf("  n=%7s (unicos=%5d) | %.2fs\n",
    format(n, big.mark = ","), length(unicos), t["elapsed"]))
}

# cie_validate_vector()
cat("\ncie_validate_vector():\n")
for (n in escalas) {
  codigos_sim <- generar_codigos(n)
  t <- system.time(cie_validate_vector(codigos_sim))
  cat(sprintf("  n=%7s | %.2fs\n", format(n, big.mark = ","), t["elapsed"]))
}

# cie_normalizar()
cat("\ncie_normalizar():\n")
for (n in c(1e4, 1e5, 5e5)) {
  codigos_sim <- generar_codigos(n)
  # Agregar variaciones realistas
  codigos_sim[1:100] <- gsub("\\.", "", codigos_sim[1:100])  # sin punto
  codigos_sim[101:200] <- paste0(" ", codigos_sim[101:200], " ")  # espacios
  t <- system.time(cie_normalizar(codigos_sim))
  cat(sprintf("  n=%7s | %.2fs\n", format(n, big.mark = ","), t["elapsed"]))
}

# cie_map_comorbid()
cat("\ncie_map_comorbid():\n")
for (n in c(1e4, 1e5, 1e6)) {
  codigos_sim <- generar_codigos(n)
  t <- system.time(cie_map_comorbid(codigos_sim))
  cat(sprintf("  n=%7s | %.2fs\n", format(n, big.mark = ","), t["elapsed"]))
}

# cie_comorbid() (mas lento, escala menor)
cat("\ncie_comorbid() (Charlson):\n")
for (n_pac in c(1e3, 5e3, 1e4)) {
  n_diag <- n_pac * 5  # ~5 diagnosticos por paciente
  df_sim <- tibble(
    id_pac = rep(seq_len(n_pac), each = 5),
    diag = generar_codigos(n_diag)
  )
  t <- system.time(cie_comorbid(df_sim, id = "id_pac", code = "diag", map = "charlson"))
  cat(sprintf("  pacientes=%6s (diags=%7s) | %.2fs\n",
    format(n_pac, big.mark = ","), format(n_diag, big.mark = ","), t["elapsed"]))
}

# --- Seccion 3: bench::mark comparaciones precisas ---

cat("\n--- bench::mark (100K codigos) ---\n\n")

codigos_100k <- generar_codigos(1e5)
codigos_100k_dirty <- codigos_100k
codigos_100k_dirty[1:500] <- gsub("\\.", "", codigos_100k_dirty[1:500])

bm <- bench::mark(
  validate = cie_validate_vector(codigos_100k),
  map_comorbid = cie_map_comorbid(codigos_100k),
  normalizar_sin_db = cie_normalizar(codigos_100k_dirty, buscar_db = FALSE),
  check = FALSE,
  min_iterations = 3
)

print(bm[, c("expression", "min", "median", "mem_alloc", "n_itr")])

# --- Resumen ejecutivo ---

cat("\n=== Resumen ejecutivo ===\n")
cat("Para 21M registros (~35K codigos unicos):\n")
cat("  1. Patron GITTESIS (unique+lookup+join): escalable, lookup sobre ~35K unicos\n")
cat("  2. cie_validate_vector: vectorizado, escala lineal\n")
cat("  3. cie_normalizar: vectorizado (v0.9.3), escala lineal\n")
cat("  4. cie_map_comorbid: vectorizado (v0.9.3) con case_when\n")
cat("  5. cie_comorbid: depende de comorbidity pkg, usar sample si >100K pacientes\n")
cat("\nRecomendacion: SIEMPRE usar unique() antes de lookup para reducir 21M -> 35K\n")
