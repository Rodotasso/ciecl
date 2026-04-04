# Introduction to ciecl: Chilean ICD-10 in R

> **Version 0.9.3**: Available on CRAN with SQLite optimizations and
> XLSX support.

## About the dataset

The package includes **39,877 ICD-10 codes** from the official
MINSAL/DEIS v2018 catalog, including categories (3 digits) and
subcategories (4+ digits).

## Installation

``` r
# From GitHub (beta version)
pak::pak("RodoTasso/ciecl")

# Alternative with devtools
devtools::install_github("RodoTasso/ciecl")
```

## Fast SQL search

``` r
# All type 2 diabetes codes
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

## Search by code

``` r
# Single code search
cie_lookup("E11.0")
#> # A tibble: 1 × 10
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 3 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>

# Vectorized search - multiple codes at once
codes <- c("E11.0", "I10", "Z00", "J44.0")
cie_lookup(codes)
#> # A tibble: 4 × 10
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 2 I10    Hipertensión ese… I10 HIPE… I10-I1… Cap.09  ENFERM… NA        NA       
#> 3 J44.0  Enfermedad pulmo… J44 OTRA… J40-J4… Cap.10  ENFERM… NA        NA       
#> 4 Z00    Examen general e… Z00 EXAM… Z00-Z1… Cap.21  FACTOR… NA        NA       
#> # ℹ 3 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>

# Hierarchical expansion
cie_lookup("E11", expandir = TRUE)
#> # A tibble: 11 × 10
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
#> # ℹ 3 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>
```

## Fuzzy search with typos

``` r
# Finds even if misspelled
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

## Charlson Comorbidities

``` r
# Requires: install.packages("comorbidity")
patient_df <- data.frame(
  patient_id = c(1, 1, 2, 2, 3),
  diagnosis = c("E11.0", "I50.9", "C50.9", "N18.5", "J44.0")
)

cie_comorbid(patient_df, id = "patient_id", code = "diagnosis", map = "charlson")
```

## Interactive tables

``` r
# Requires: install.packages("gt")
cie_table("E11")  # Full GT visualization
```

## Data source

Official ICD-10 Chile data MINSAL/DEIS v2018:

- FIC Chile Center: <https://deis.minsal.cl/centrofic/>
- DEIS Repository: <https://deis.minsal.cl>

## More information

- Report issues: <https://github.com/RodoTasso/ciecl/issues>
- Repository: <https://github.com/RodoTasso/ciecl>
