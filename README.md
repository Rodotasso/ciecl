
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ciecl

<!-- badges: start -->

[![R-CMD-check](https://github.com/Rodotasso/ciecl/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Rodotasso/ciecl/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**Clasificacion Internacional de Enfermedades (CIE-10) oficial de Chile
para R**.

SQL optimizado + fuzzy search + comorbilidades Charlson/Elixhauser +
CIE-11 API OMS.

## Instalacion

``` r
# CRAN (pendiente)
install.packages("ciecl")

# GitHub (desarrollo)
devtools::install_github("RodoTasso/ciecl")
```

## Uso rapido

``` r
library(ciecl)

# SQL directo
cie10_sql("SELECT * FROM cie10 WHERE descripcion LIKE '%diabetes%' LIMIT 3")

# Fuzzy search con errores tipograficos
cie_search("neumonia bactereana")  # Encuentra "neumonia bacteriana"

# Comorbilidades
df %>% cie_comorbid(id = "paciente", code = "diagnostico", map = "charlson")
```

## Datos

Basado en **MINSAL/DEIS v2018** (repositorio publico):  
<https://repositoriodeis.minsal.cl>

## Licencia

MIT + datos MINSAL dominio publico (Decreto 356/2017)

## Autor

Rodolfo Tasso Suazo (<rtasso@uchile.cl>)
