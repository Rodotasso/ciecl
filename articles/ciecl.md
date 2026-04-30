# Introduction to ciecl: Chilean ICD-10 in R

> **Version 0.9.8**: Available on CRAN with SQLite optimizations, XLSX
> support, and standardized English arguments.

## The problem: working with Chilean diagnostic codes in R

Chilean health information systems — DEIS, GRD, REM — store diagnoses
using the ICD-10 classification in its official MINSAL/DEIS v2018
version. Analysts working with these datasets in R typically have to
cross-reference PDF catalogs, Excel tables, or ministry websites to look
up codes, which breaks the analytical workflow.

`ciecl` solves this by embedding all **39,877 ICD-10 codes** from the
official catalog directly into R, with functions for fast lookup,
hierarchical expansion, fuzzy search, and comorbidity scoring.

## Installation

The package is available on CRAN:

``` r

install.packages("ciecl")
```

To install the development version with the latest fixes:

``` r

# Requires the pak package
pak::pak("RodoTasso/ciecl")
```

## Direct SQL queries against the catalog

[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)
exposes the full catalog through a local SQLite database, allowing you
to filter with the full expressiveness of SQL. This is useful when you
know the code structure but not the exact label — for instance, to
retrieve all subcodes within a category.

The example below fetches the first five type 2 diabetes codes (category
E11):

``` r

cie10_sql("SELECT codigo, descripcion FROM cie10 WHERE codigo LIKE 'E11%' LIMIT 5")
#> # A tibble: 5 × 2
#>   codigo descripcion                                           
#>   <chr>  <chr>                                                 
#> 1 E11    Diabetes mellitus no insulinodependiente              
#> 2 E11.0  Diabetes mellitus tipo 2 con coma                     
#> 3 E11.1  Diabetes mellitus tipo 2 con cetoacidosis             
#> 4 E11.2  Diabetes mellitus tipo 2 con complicaciones renales   
#> 5 E11.3  Diabetes mellitus tipo 2 con complicaciones oftálmicas
```

Only `SELECT` queries are accepted, protecting catalog integrity.

## Looking up known codes

When codes are already present in your data — such as hospital discharge
diagnoses —
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
retrieves the official description for one or more codes at once.

``` r

# Single code
cie_lookup("E11.0")
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
```

The function accepts vectors, making it straightforward to use inside a
`dplyr` pipeline:

``` r

# Multiple codes from different chapters
cie_lookup(c("E11.0", "I10", "Z00", "J44.0"))
#> # A tibble: 4 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 2 I10    Hipertensión ese… I10 HIPE… I10-I1… Cap.09  ENFERM… NA        NA       
#> 3 J44.0  Enfermedad pulmo… J44 OTRA… J40-J4… Cap.10  ENFERM… NA        NA       
#> 4 Z00    Examen general e… Z00 EXAM… Z00-Z1… Cap.21  FACTOR… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
```

When working at the category level (three-digit codes), you may need all
subcodes within a category. The `expand = TRUE` argument traverses the
hierarchy and returns the parent category together with all its
children:

``` r

cie_lookup("E11", expand = TRUE)
#> # A tibble: 11 × 11
#>    codigo descripcion      categoria seccion capitulo_nombre inclusion exclusion
#>    <chr>  <chr>            <chr>     <chr>   <chr>           <chr>     <chr>    
#>  1 E11    Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  2 E11.0  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  3 E11.1  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  4 E11.2  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  5 E11.3  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  6 E11.4  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  7 E11.5  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  8 E11.6  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#>  9 E11.7  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 10 E11.8  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 11 E11.9  Diabetes mellit… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
```

## Extracting descriptions for use in tables and plots

When you only need the description text — without the full structure
returned by
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
—
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
returns a character vector of descriptions in the same order as the
input codes. This is designed for use inside
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) or as
axis labels in plots:

``` r

cie_describe(c("E11.0", "I10"))
#> [1] "Diabetes mellitus tipo 2 con coma" "Hipertensión esencial (primaria)"
```

A typical use case with hospital discharge data:

``` r

library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

discharges <- data.frame(
  id          = 1:4,
  diag_code   = c("E11.0", "I10", "J44.0", "E11.0")
)

discharges %>%
  mutate(description = cie_describe(diag_code))
#>   id diag_code
#> 1  1     E11.0
#> 2  2       I10
#> 3  3     J44.0
#> 4  4     E11.0
#>                                                                                        description
#> 1                                                                Diabetes mellitus tipo 2 con coma
#> 2                                                                 Hipertensión esencial (primaria)
#> 3 Enfermedad pulmonar obstructiva crónica con infección aguda de las vías respiratorias inferiores
#> 4                                                                Diabetes mellitus tipo 2 con coma
```

## Fuzzy search with tolerance for misspellings

Clinical text data often contains spelling errors, abbreviations, or
non-standard terms.
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
uses Jaro-Winkler string similarity to find matching codes even when the
search term contains typos.

The `threshold` parameter controls strictness: higher values require
closer matches. A range of 0.70 to 0.85 works well in practice:

``` r

# "diabetis" instead of "diabetes" — the typo does not prevent finding the code
cie_search("diabetis with coma", threshold = 0.75)
#> # A tibble: 22 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 B15.0  Hepatitis aguda tipo A, con coma hepático              0.333 B15 HEPA…
#>  2 B15.9  Hepatitis aguda tipo A, sin coma hepático              0.333 B15 HEPA…
#>  3 B16.0  Hepatitis aguda tipo B, con agente delta (coinfección… 0.333 B16 HEPA…
#>  4 B16.1  Hepatitis aguda tipo B, con agente delta (coinfección… 0.333 B16 HEPA…
#>  5 B16.2  Hepatitis aguda tipo B, sin agente delta, con coma he… 0.333 B16 HEPA…
#>  6 B16.9  Hepatitis aguda tipo B, sin agente delta y sin coma h… 0.333 B16 HEPA…
#>  7 B19.0  Hepatitis viral no especificada, con coma hepático     0.333 B19 HEPA…
#>  8 B19.9  Hepatitis viral no especificada, sin  coma hepático    0.333 B19 HEPA…
#>  9 E03.5  Coma mixedematoso                                      0.333 E03 OTRO…
#> 10 E10.0  Diabetes mellitus tipo 1 con coma                      0.333 E10 DIAB…
#> # ℹ 12 more rows
```

## Charlson and Elixhauser comorbidity indices

The Charlson and Elixhauser indices are widely used in clinical research
and risk adjustment.
[`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)
computes these indices from a data frame containing patient identifiers
and their associated diagnostic codes.

This function requires the `comorbidity` package. Install it with
`install.packages("comorbidity")` if needed:

``` r

# Requires: install.packages("comorbidity")
patient_df <- data.frame(
  patient_id  = c(1, 1, 2, 2, 3),
  diagnosis   = c("E11.0", "I50.9", "C50.9", "N18.5", "J44.0")
)

cie_comorbid(patient_df, id = "patient_id", code = "diagnosis", map = "charlson")
```

The result is a data frame with one row per patient and columns for each
condition in the selected index, plus a weighted total score.

## Formatted tables with gt

For reports and presentations,
[`cie_table()`](https://rodotasso.github.io/ciecl/reference/cie_table.md)
generates an enriched HTML table of all codes within a category using
the `gt` package. Requires `gt` to be installed:

``` r

# Requires: install.packages("gt")
cie_table("E11")
```

## Data source

The data included in `ciecl` comes from the official ICD-10 catalog
published by the Chilean Ministry of Health through the Department of
Health Statistics and Information (DEIS):

- FIC Chile Center: <https://deis.minsal.cl/centrofic/>
- DEIS Repository: <https://deis.minsal.cl>

## Further information

- Report issues or suggestions:
  <https://github.com/RodoTasso/ciecl/issues>
- Package repository: <https://github.com/RodoTasso/ciecl>
