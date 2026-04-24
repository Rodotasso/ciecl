# Renderiza README.Rmd en dos idiomas: README.md (ES) y README.en.md (EN)
# Uso: source("tools/build_readmes.R")
# Excluido del tarball via .Rbuildignore.

# Cargar version de desarrollo (incluye funciones nuevas aun no instaladas)
if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::load_all(".", quiet = TRUE)
} else {
  message("devtools no disponible; se usara la version instalada de ciecl.")
}

rmarkdown::render(
  "README.Rmd",
  params = list(lang = "es"),
  output_file = "README.md",
  quiet = TRUE
)

rmarkdown::render(
  "README.Rmd",
  params = list(lang = "en"),
  output_file = "README.en.md",
  quiet = TRUE
)

message("OK: README.md (ES) y README.en.md (EN) regenerados desde README.Rmd")
