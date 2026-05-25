
> **Language / Idioma:** **English** \|
> [Español](https://github.com/RodoTasso/ciecl/blob/main/README.md)

<!-- README generado desde README.Rmd. Editar este archivo, no los .md -->

# ciecl <img src="man/figures/logo-CDSP_color.png" align="right" height="60" alt="CDSP"> <img src="man/figures/logo.png" align="right" height="139" alt="ciecl logo">

**Data Science for Public Health Group** \| University of Chile

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

**Official Chilean ICD-10 Classification (CIE-10) for R**.

Specialized package for searching, validating, and analyzing ICD-10
codes in the Chilean context. Includes the official MINSAL/DEIS v2018
catalogue with optimized search, comorbidity computation, and WHO ICD-11
API access.

## Purpose

`ciecl` facilitates working with ICD-10 codes in Chilean health research
and data analysis, avoiding manual Excel manipulation and providing
specialized tools for:

- Fast validation of diagnostic codes
- Typo-tolerant search (Jaro-Winkler fuzzy search)
- Automatic comorbidity indices (Charlson, Elixhauser)
- Optimized SQL queries over the complete catalogue
- Hierarchical expansion of categories (e.g., `E11` → `E11.0`, `E11.1`,
  …, `E11.9`)
- Access to the WHO ICD-11 API

## Features

- **Official Chilean CIE-10 catalogue** (MINSAL/DEIS v2018) embedded as
  a dataset
- **Jaro-Winkler fuzzy search** tolerant to typos
- **Chilean medical abbreviations** (IAM, EPOC, DM2, HTA, TBC, …)
- **Direct SQL queries** via SQLite + FTS5
- **Charlson/Elixhauser comorbidities** using `comorbidity`
- **WHO ICD-11 API** via `cie11_search()`
- **Robust normalization**: accepts `E110`, `E11.0`, `e 11 0`, `I10-0`,
  etc.
- **Minimal dependencies** (8 core packages; the rest in Suggests)

The dataset is established by [Decree
356/2017](https://www.bcn.cl/leychile/navegar?i=1112064) of Chile’s
Ministry of Health as the official disease classification. It is not
modifiable by the package; it can only be updated by MINSAL
institutional decree.

## Installation

``` r
# CRAN
install.packages("ciecl")

# GitHub (desarrollo)
# install.packages("pak")
pak::pak("RodoTasso/ciecl")
```

## Quick start

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

## ICD-11 API (optional)

To use `cie11_search()` you need free WHO credentials
(<https://icd.who.int/icdapi>). We recommend storing them with the
`keyring` package:

``` r
keyring::key_set("ciecl_icd11")  # client_id:client_secret
Sys.setenv(ICD_API_KEY = keyring::key_get("ciecl_icd11"))
cie11_search("diabetes mellitus")
```

The CIE-10 functions (the core of the package) work without an API key.

## Data

Official **CIE-10 MINSAL/DEIS v2018** catalogue:

- Source: [DEIS](https://deis.minsal.cl) — [Centro FIC
  Chile](https://deis.minsal.cl/centrofic/)
- Public domain under [Decree
  356/2017](https://www.bcn.cl/leychile/navegar?i=1112064)

## Development

This package was developed with assistance from Claude (Anthropic), with
human verification and validation of all code and documentation.

## Contributing

- Report bugs: <https://github.com/RodoTasso/ciecl/issues>
- Contribute: see `CONTRIBUTING.md`

## License

MIT + MINSAL public-domain data.

## Author

**Rodolfo Tasso Suazo** — <rtasso@uchile.cl> Data Science for Public
Health Group, School of Public Health, Faculty of Medicine, University
of Chile.

## Acknowledgments

- Package logo design: [@fje1](https://github.com/fje1).

## Links

- Repository: <https://github.com/RodoTasso/ciecl>
- DEIS MINSAL: <https://deis.minsal.cl>
- ICD-11 API: <https://icd.who.int/icdapi>

------------------------------------------------------------------------

<img src="man/figures/logo-CDSP_color.png" height="120" alt="Data Science for Public Health Group">

**Data Science for Public Health Group**<br> School of Public Health,
Faculty of Medicine<br> University of Chile
