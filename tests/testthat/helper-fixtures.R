# Helper para cargar fixtures de datos sinteticos
# Uso: df <- load_fixture("codigos_perfectos.csv")

load_fixture <- function(name) {

path <- testthat::test_path("fixtures", name)
if (file.exists(path)) {
  utils::read.csv(path, stringsAsFactors = FALSE)
} else {
  warning("Fixture no encontrado: ", name)
  NULL
}
}
