# setup.R - Cargar .Renviron del paquete para tests de API
renviron_paths <- c(
  file.path(getwd(), ".Renviron"),
  normalizePath(file.path("..", "..", ".Renviron"), mustWork = FALSE)
)
for (p in renviron_paths) if (file.exists(p)) { readRenviron(p); break }
