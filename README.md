
> **Idioma / Language:** **Español** \|
> [English](https://github.com/RodoTasso/ciecl/blob/main/README.en.md)

<!-- README generado desde README.Rmd. Editar este archivo, no los .md -->

# ciecl <img src="man/figures/logo-CDSP_color.png" align="right" height="60" alt="CDSP"> <img src="man/figures/logo.png" align="right" height="139" alt="ciecl logo">

**Grupo de Ciencia de Datos para Salud Pública** \| Universidad de Chile

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN
status](https://www.r-pkg.org/badges/version/ciecl)](https://CRAN.R-project.org/package=ciecl)
[![GitHub
release](https://img.shields.io/github/v/release/RodoTasso/ciecl)](https://github.com/RodoTasso/ciecl/releases)
[![R-CMD-check](https://github.com/RodoTasso/ciecl/actions/workflows/r.yml/badge.svg)](https://github.com/RodoTasso/ciecl/actions/workflows/r.yml)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/ciecl)](https://cran.r-project.org/package=ciecl)
[![Coverage](https://img.shields.io/badge/coverage-96%25-brightgreen)](https://github.com/RodoTasso/ciecl/actions/workflows/test-coverage.yaml)
[![pkgdown](https://img.shields.io/badge/docs-pkgdown-blue)](https://rodotasso.github.io/ciecl/)
[![Status at rOpenSci Software Peer
Review](https://badges.ropensci.org/765_status.svg)](https://github.com/ropensci/software-review/issues/765)
<!-- badges: end -->

**Clasificación Internacional de Enfermedades (CIE-10) oficial de Chile
para R**.

Paquete especializado para búsqueda, validación y análisis de códigos
CIE-10 en el contexto chileno. Incluye el catálogo oficial MINSAL/DEIS
v2018 con búsqueda optimizada, cálculo de comorbilidades y acceso a la
API CIE-11 de la OMS.

## Finalidad

`ciecl` facilita el trabajo con códigos CIE-10 en investigación y
análisis de datos de salud en Chile, eliminando la necesidad de
manipular archivos Excel manualmente y proporcionando herramientas
especializadas para:

- Validación rápida de códigos diagnósticos
- Búsqueda tolerante a errores tipográficos (fuzzy search Jaro-Winkler)
- Cálculo automático de índices de comorbilidad (Charlson, Elixhauser)
- Consultas SQL optimizadas sobre el catálogo completo
- Expansión jerárquica de categorías (ej: `E11` → `E11.0`, `E11.1`, …,
  `E11.9`)
- Acceso a la API CIE-11 de la OMS

## Características

- **Catálogo oficial CIE-10 Chile** (MINSAL/DEIS v2018) embebido como
  dataset
- **Búsqueda fuzzy Jaro-Winkler** tolera errores tipográficos
- **Siglas médicas chilenas** (IAM, EPOC, DM2, HTA, TBC, …)
- **Consultas SQL directas** con SQLite + FTS5
- **Comorbilidades Charlson/Elixhauser** con `comorbidity`
- **API CIE-11 OMS** vía `cie11_search()`
- **Normalización robusta**: acepta `E110`, `E11.0`, `e 11 0`, `I10-0`,
  etc.
- **Dependencias mínimas** (8 paquetes core; el resto en Suggests)

El dataset está establecido por el [Decreto
356/2017](https://www.bcn.cl/leychile/navegar?i=1112064) del MINSAL como
clasificación oficial de enfermedades. No es modificable por el paquete;
solo se actualiza por decreto institucional.

## Instalación

``` r
# CRAN
install.packages("ciecl")

# GitHub (desarrollo)
# install.packages("pak")
pak::pak("RodoTasso/ciecl")
```

## Uso rápido

``` r
library(ciecl)

# Busqueda exacta por codigo
cie_lookup("E11.0")
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… <NA>      <NA>     
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>

# Multiples codigos
cie_lookup(c("E11.0", "I10", "Z00"))
#> # A tibble: 3 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… <NA>      <NA>     
#> 2 I10    Hipertensión ese… I10 HIPE… I10-I1… Cap.09  ENFERM… <NA>      <NA>     
#> 3 Z00    Examen general e… Z00 EXAM… Z00-Z1… Cap.21  FACTOR… <NA>      <NA>     
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>

# Descripcion directa (vectorizada) para usar en mutate()
cie_describe(c("E11.0", "I10"))
#> [1] "Diabetes mellitus tipo 2 con coma" "Hipertensión esencial (primaria)"

# Ejemplo en flujo dplyr
# egresos %>% mutate(desc = cie_describe(codigo))
```

# Busqueda fuzzy tolerante a errores

cie_search(“diabetis mellitus”)

# Siglas medicas chilenas

cie_search(“IAM”)



    ``` r
    # Comorbilidades (requiere: install.packages("comorbidity"))
    df |> cie_comorbid(id = "paciente", code = "diagnostico", map = "charlson")

## API CIE-11 (opcional)

Para usar `cie11_search()` necesitas credenciales gratuitas de la OMS
(<https://icd.who.int/icdapi>). Recomendamos guardarlas con el paquete
`keyring`:

``` r
keyring::key_set("ciecl_icd11")  # client_id:client_secret
Sys.setenv(ICD_API_KEY = keyring::key_get("ciecl_icd11"))
cie11_search("diabetes mellitus")
```

Las funciones de CIE-10 (núcleo del paquete) funcionan sin API key.

## Datos

Catálogo oficial **CIE-10 MINSAL/DEIS v2018**:

- Fuente: [DEIS](https://deis.minsal.cl) — [Centro FIC
  Chile](https://deis.minsal.cl/centrofic/)
- Dominio público según [Decreto
  356/2017](https://www.bcn.cl/leychile/navegar?i=1112064)

## Contribuir

- Reportar bugs: <https://github.com/RodoTasso/ciecl/issues>
- Contribuir: ver `CONTRIBUTING.md`

## Licencia

MIT + datos MINSAL de dominio público.

## Autor

**Rodolfo Tasso Suazo** — <rtasso@uchile.cl> Grupo de Ciencia de Datos
para Salud Pública, Escuela de Salud Pública, Facultad de Medicina,
Universidad de Chile.

## Enlaces

- Repositorio: <https://github.com/RodoTasso/ciecl>
- DEIS MINSAL: <https://deis.minsal.cl>
- API CIE-11: <https://icd.who.int/icdapi>
