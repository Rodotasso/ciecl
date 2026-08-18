# Getting started with ciecl: a hospital discharge report

## Who is this guide for?

Imagine you work in the statistics unit of a hospital and every month
you are the person responsible for preparing the **diabetes discharge
report** for the service directorate. You receive the hospital discharge
database, and your goal is to answer concrete questions: how many
discharges had diabetes as the primary diagnosis?, of what type?, how
complex were those patients?

The problem is that the database arrives with ICD-10 codes in
inconsistent formats and without descriptions: to interpret them you
would have to manually consult the official catalog in PDF or Excel.
`ciecl` removes that step: it bundles the official Chilean ICD-10
catalog (MINSAL/DEIS v2018) inside R and lets you normalize, describe,
search and analyze the codes directly on your database.

This guide walks through that complete workflow, from basic to advanced.
You only need basic R knowledge; if you also use `dplyr`, the examples
fit directly into your pipelines.

## The data: DEIS hospital discharges

The **Hospital Discharge** databases are published by the Department of
Health Statistics and Information (DEIS) of the Ministry of Health of
Chile. Each row is a hospital discharge and the `DIAG1` column contains
the primary diagnosis coded in ICD-10.

In practice, these files arrive with two very common format variations:

1.  **Compact formats**: codes without a decimal point (e.g., `J189`
    instead of `J18.9`).
2.  **Filler suffixes**: an `X` letter to complete the field length in
    3-character categories (e.g., `I10X` for essential hypertension).

Let’s generate a synthetic dataset that replicates the structure and
typical anomalies of DEIS files:

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

## Step 1: Normalize codes with `cie_norm()`

Before any analysis, `DIAG1` must be standardized.
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
applies the official MINSAL coding rules in a vectorized way: it removes
the filler `X`, inserts the decimal point in the correct position and
cleans whitespace, hyphens and special symbols (such as † or \*).

``` r

# Cleaning and standardization of diagnoses in the workflow
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

With this, `I10X` became `I10` and `J189` became `J18.9`: the codes are
now comparable with the official catalog.

## Step 2: Add the official descriptions with `cie_describe()`

For the report you need the clinical descriptions, not just the codes.
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
directly returns a character vector, so it integrates into a `mutate()`
without temporary joins:

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

If, in addition to the description, you need the full metadata (chapter,
group, inclusion/exclusion notes), use
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
which returns a structured `tibble` ready for a `left_join()`:

``` r

# Extracting full metadata via lookup + join
metadata <- cie_lookup(
  code = unique(discharges$DIAG1_NORM),
  full_description = TRUE
)

discharges_metadata <- discharges |>
  left_join(metadata, by = c("DIAG1_NORM" = "codigo"))
```

## Step 3: Find codes when you don’t know the code with `cie_search()`

Back to your diabetes report: you suspect there are diabetes discharges
in the database, but which exact codes does the catalog cover? Instead
of flipping through the PDF, you search by text.
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
uses Jaro-Winkler similarity, so it tolerates typos (here we search for
“diabetis” on purpose):

``` r

# Tolerant search: "diabetis" instead of "diabetes"
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

The result includes a similarity `score` to assess the reliability of
each match. Now you know that `E11.9` and `E14.9` in your database
correspond to diabetes and you can filter your report with confidence.

## When a search returns no results

It is normal for some queries to find nothing, and it is worth knowing
how the package behaves in those cases: **the functions never fail with
an error when there are no results; they return an empty `tibble` with
the correct column structure** and an informative message.

If you search for a code that does not exist in the catalog:

``` r

cie_lookup("XYZ123")
#> ✖ Código no encontrado: "XYZ123"
#> # A tibble: 0 × 11
#> # ℹ 11 variables: codigo <chr>, descripcion <chr>, categoria <chr>,
#> #   seccion <chr>, capitulo_nombre <chr>, inclusion <chr>, exclusion <chr>,
#> #   capitulo <chr>, es_daga <lgl>, es_cruz <lgl>, uso_cl <chr>
```

If the
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
threshold is too strict for the term entered:

``` r

cie_search("zzzqwerty", threshold = 0.95)
#> ✖ Sin coincidencias >= threshold 0.95
#> # A tibble: 0 × 4
#> # ℹ 4 variables: codigo <chr>, descripcion <chr>, score <dbl>, categoria <chr>
```

In both cases the workflow is not interrupted: you can check
`nrow(result) == 0` and react (lower the `threshold`, check the spelling
or validate the code). To quickly check which codes of a vector are
valid according to the catalog, use
[`cie_validate_vector()`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md):

``` r

cie_validate_vector(c("E11.0", "XYZ123", "I10X"))
#> [1]  TRUE FALSE  TRUE
```

## Step 4: Stratify risk with `cie_comorbid()`

The last level of the report is patient complexity.
[`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)
maps the diagnoses to the Charlson or Elixhauser indices and returns a
comorbidity matrix per patient, ready for statistical models:

``` r

# Requires the 'comorbidity' package to be installed
# Calculation of the Charlson Index consolidated by patient
comorbidities <- cie_comorbid(
  data = discharges,
  id   = "PATIENT_ID",
  code = "DIAG1",
  map  = "charlson"
)

head(comorbidities, 10)
#> # A tibble: 10 × 19
#>    PATIENT_ID    mi   chf   pvd  cevd dementia   cpd rheumd   pud   mld  diab
#>         <int> <int> <int> <int> <int>    <int> <int>  <int> <int> <int> <int>
#>  1          1     0     0     0     0        0     0      0     0     0     1
#>  2          2     0     0     0     0        0     0      0     0     0     0
#>  3          3     0     0     0     0        0     0      0     0     0     1
#>  4          4     0     1     0     0        0     1      0     0     0     0
#>  5          5     0     1     0     0        0     0      0     0     0     1
#>  6          6     0     0     0     0        0     1      0     0     0     1
#>  7          7     0     0     0     0        0     0      0     0     0     0
#>  8          8     0     0     0     0        0     0      0     0     0     1
#>  9          9     0     0     0     0        0     1      0     0     0     0
#> 10         10     0     0     0     0        0     0      0     0     0     1
#> # ℹ 8 more variables: diabwc <int>, hp <int>, rend <int>, canc <int>,
#> #   msld <int>, metacanc <int>, aids <int>, score_charlson <dbl>
```

## Workflow summary

This guide covered the complete cycle from the raw database to the
analytical input:

1.  **Standardization**: format correction with
    [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md).
2.  **Contextualization**: official descriptions with
    [`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
    and metadata with
    [`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md).
3.  **Exploration**: text-based code search with
    [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
    error-tolerant and with predictable behavior when there are no
    results.
4.  **Aggregation**: comorbidity indices with
    [`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md).

Not sure which function to use in another scenario? Run
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md)
to see a comparison table with the recommended function and an example
per case.

## Next steps

- [Installation and Configuration
  Guide](https://rodotasso.github.io/ciecl/articles/installation.md):
  installation and credentials for the WHO ICD-11 API.
- [Introduction to ciecl: Chilean ICD-10 in
  R](https://rodotasso.github.io/ciecl/articles/ciecl-en.md):
  function-by-function tour, including direct SQL queries with
  [`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)
  and formatted tables with
  [`cie_table()`](https://rodotasso.github.io/ciecl/reference/cie_table.md).
- [Language support and
  internationalization](https://rodotasso.github.io/ciecl/articles/languages.md):
  searching in Spanish and English, and accent handling.

------------------------------------------------------------------------

**Data source:** This tool uses the official ICD-10 catalog for Chile,
managed by the DEIS of the Ministry of Health. More details at
[deis.minsal.cl](https://deis.minsal.cl).
