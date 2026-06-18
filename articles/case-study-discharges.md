# Case Study: Hospital Discharge Analysis (DEIS Chile)

## Introduction

This case study describes the technical workflow required to transform
administrative health databases in Chile into a standardized analytical
format. We use the **Hospital Discharge** databases published by the
Department of Health Statistics and Information (DEIS) as a reference.

Health administrative records frequently present structural
inconsistencies in ICD-10 coding. The two most common variations in the
Chilean context are:

1.  **Compact formats**: Codes without a decimal point (e.g., `J189`
    instead of `J18.9`).
2.  **Filler suffixes**: Use of the letter `X` to complete the field
    length in 3-digit categories (e.g., `I10X` for Essential
    hypertension).

These variations hinder interoperability and cross-referencing with
international standards. The `ciecl` package automates the correction of
these inconsistencies in a vectorized and efficient manner.

## 1. Original Data Structure

A synthetic dataset is generated below that replicates the structure and
typical anomalies found in DEIS `.csv` files. The `DIAG1` column
represents the primary diagnosis with the aforementioned informal coding
formats.

``` r

set.seed(42)

# Simulation of 200 records with typical DEIS Chile formats
discharges <- data.frame(
  DISCHARGE_ID = 1:200,
  PATIENT_ID   = sample(1:50, 200, replace = TRUE),
  YEAR         = sample(2018:2022, 200, replace = TRUE),
  DIAG1        = sample(
    c(
      "J189", "O800", "Z380", "K359", "N390",
      "I10X", "J449", "E119", "O829", "J069",
      "K922", "N185", "I509", "C509", "A099",
      "N40X", "K800", "I259", "J180", "E149"
    ),
    size    = 200,
    replace = TRUE
  ),
  stringsAsFactors = FALSE
)

head(discharges)
#>   DISCHARGE_ID PATIENT_ID YEAR DIAG1
#> 1            1         49 2018  J189
#> 2            2         37 2022  E119
#> 3            3          1 2021  E149
#> 4            4         25 2018  N390
#> 5            5         10 2022  I10X
#> 6            6         36 2021  C509
```

## 2. Code Normalization with `cie_norm()`

Normalization is the critical first step to ensure analysis integrity.
The
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
function processes codes by applying official MINSAL coding rules:

- **Suffix removal**: Identifies and removes the trailing `X`.
- **Punctuation formatting**: Inserts the decimal point in the standard
  position according to the ICD-10 hierarchy.
- **String cleaning**: Removes whitespace and non-printable characters.

``` r

# Cleaning and standardization of diagnoses
discharges <- discharges |>
  mutate(
    DIAG1_NORM = cie_norm(codes = DIAG1)
  )

# Comparison between original and normalized formats
discharges |>
  select(DIAG1, DIAG1_NORM) |>
  distinct() |>
  head(5)
#>   DIAG1 DIAG1_NORM
#> 1  J189      J18.9
#> 2  E119      E11.9
#> 3  E149      E14.9
#> 4  N390      N39.0
#> 5  I10X        I10
```

## 3. Semantic Enrichment with `cie_describe()`

After normalization, standardized clinical descriptions are assigned to
facilitate result interpretation. The `ciecl` package provides the
vectorized
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
function, specifically designed to integrate into `dplyr` workflows
efficiently.

Unlike a traditional `left_join`,
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
directly returns a character vector, avoiding the creation of additional
join columns and keeping the code cleaner.

``` r

# Direct integration of descriptions into the main dataframe
discharges_full <- discharges |>
  mutate(
    description = cie_describe(DIAG1_NORM)
  )

head(discharges_full |> select(DISCHARGE_ID, DIAG1, description))
#>   DISCHARGE_ID DIAG1
#> 1            1  J189
#> 2            2  E119
#> 3            3  E149
#> 4            4  N390
#> 5            5  I10X
#> 6            6  C509
#>                                                       description
#> 1                                       Neumonía, no especificada
#> 2                     Diabetes mellitus tipo 2 sin complicaciones
#> 3 Diabetes mellitus, no especificada, sin mención de complicación
#> 4              Infección de vías urinarias, sitio no especificado
#> 5                                Hipertensión esencial (primaria)
#> 6                 Tumor maligno de la mama, parte no especificada
```

For cases where full metadata is required (chapter, category, group),
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
can still be used in conjunction with a table join:

``` r

# Extracting full metadata via lookup + join
metadata <- cie_lookup(
  code = unique(discharges$DIAG1_NORM),
  full_description = TRUE
)

discharges_metadata <- discharges |>
  left_join(metadata, by = c("DIAG1_NORM" = "codigo"))
```

## 4. Catalog Exploration with `cie_search()`

In exploratory phases, where the exact code is unknown or transcription
errors in the original clinical descriptions are suspected,
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
allows text searches using string similarity (fuzzy matching).

``` r

# Example of search with intentional typo ("diabetis")
# The function returns the most likely matches ordered by score
cie_search(text = "diabetis", threshold = 0.7)
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 E10    Diabetes mellitus insulinodependiente                  0.917 E10 DIAB…
#>  2 E10.0  Diabetes mellitus tipo 1 con coma                      0.917 E10 DIAB…
#>  3 E10.1  Diabetes mellitus tipo 1 con cetoacidosis              0.917 E10 DIAB…
#>  4 E10.2  Diabetes mellitus tipo 1 con complicaciones renales    0.917 E10 DIAB…
#>  5 E10.3  Diabetes mellitus tipo 1 con complicaciones oftálmicas 0.917 E10 DIAB…
#>  6 E10.4  Diabetes mellitus tipo 1 con complicaciones neurológi… 0.917 E10 DIAB…
#>  7 E10.5  Diabetes mellitus tipo 1 con complicaciones  circulat… 0.917 E10 DIAB…
#>  8 E10.6  Diabetes mellitus tipo 1 con otras complicaciones esp… 0.917 E10 DIAB…
#>  9 E10.7  Diabetes mellitus tipo 1 con complicaciones múltiples  0.917 E10 DIAB…
#> 10 E10.8  Diabetes mellitus tipo 1 con complicaciones no especi… 0.917 E10 DIAB…
#> # ℹ 40 more rows
```

## 5. Comorbidity Index Calculation with `cie_comorbid()`

An advanced application of `ciecl` is population risk stratification
through comorbidity indices. The
[`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)
function maps normalized diagnoses to Charlson or Elixhauser categories,
adapted to the reality of Chilean data.

``` r

# Requires the 'comorbidity' package to be installed
# Calculation of the Charlson Index by patient identifier
comorbidities <- cie_comorbid(
  data = discharges,
  id   = "PATIENT_ID",
  code = "DIAG1",
  map  = "charlson"
)

# The result allows immediate use in statistical models
head(comorbidities, 10)
```

## Process Summary

The `ciecl` workflow enables a reproducible transition from raw
administrative data to an analytical dataset in four stages:

1.  **Standardization**: Format correction using
    [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md).
2.  **Contextualization**: Assignment of official glosses with
    [`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md).
3.  **Validation**: Term discovery and checking with
    [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md).
4.  **Aggregation**: Generation of complex clinical indicators with
    [`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md).

------------------------------------------------------------------------

**Data source:** This tool uses the ICD-10 catalog standardized by the
Centro FIC of the DEIS, Ministry of Health of Chile. For more
information, visit [deis.minsal.cl](https://deis.minsal.cl).
