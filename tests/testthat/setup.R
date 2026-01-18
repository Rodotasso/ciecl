# setup.R - Cargar .Renviron del paquete para tests de API
# Buscar .Renviron en multiples ubicaciones posibles
renviron_paths <- c(
  file.path(getwd(), ".Renviron"),
  normalizePath(file.path("..", "..", ".Renviron"), mustWork = FALSE),
  normalizePath(file.path("..", ".Renviron"), mustWork = FALSE),
  normalizePath("D:/MAGISTER/01_Paquete_R/ciecl/.Renviron", mustWork = FALSE)
)

for (p in renviron_paths) {
  if (file.exists(p)) {
    readRenviron(p)
    break
  }
}
