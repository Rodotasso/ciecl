# Declarar variables NSE para evitar NOTEs en R CMD check
utils::globalVariables(c(
  # Variables dplyr NSE
  "codigo", "descripcion", "score", "categoria", "inclusion", "exclusion",
  "patron", "title", "capitulo",
  # Dataset
  "cie10_cl",
  # Dot placeholder
  "."
))
