# Introduccion a ciecl: CIE-10 Chile en R

> **Version 0.9.3**: Disponible en CRAN con optimizaciones SQLite y
> soporte XLSX.

## Acerca del dataset

El paquete incluye **39,877 codigos CIE-10** del catalogo oficial
MINSAL/DEIS v2018, incluyendo categorias (3 digitos) y subcategorias (4+
digitos).

## Instalacion

``` r
# Desde GitHub (version beta)
pak::pak("RodoTasso/ciecl")

# Alternativa con devtools
devtools::install_github("RodoTasso/ciecl")
```

## Busqueda SQL rapida

``` r
# Todos los codigos diabetes tipo 2
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

## Busqueda por codigo

``` r
# Busqueda de un solo codigo
cie_lookup("E11.0")
#> # A tibble: 1 × 10
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 3 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>

# Busqueda vectorizada - multiples codigos a la vez
codigos <- c("E11.0", "I10", "Z00", "J44.0")
cie_lookup(codigos)
#> # A tibble: 4 × 10
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 2 I10    Hipertensión ese… I10 HIPE… I10-I1… Cap.09  ENFERM… NA        NA       
#> 3 J44.0  Enfermedad pulmo… J44 OTRA… J40-J4… Cap.10  ENFERM… NA        NA       
#> 4 Z00    Examen general e… Z00 EXAM… Z00-Z1… Cap.21  FACTOR… NA        NA       
#> # ℹ 3 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>

# Expansion jerarquica
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

## Busqueda fuzzy con typos

``` r
# Encuentra aunque este mal escrito
cie_search("diabetis con coma", threshold = 0.75)
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 B15.0  Hepatitis aguda tipo A, con coma hepático              0.667 B15 HEPA…
#>  2 B16.0  Hepatitis aguda tipo B, con agente delta (coinfección… 0.667 B16 HEPA…
#>  3 B16.1  Hepatitis aguda tipo B, con agente delta (coinfección… 0.667 B16 HEPA…
#>  4 B16.2  Hepatitis aguda tipo B, sin agente delta, con coma he… 0.667 B16 HEPA…
#>  5 B19.0  Hepatitis viral no especificada, con coma hepático     0.667 B19 HEPA…
#>  6 E10.0  Diabetes mellitus tipo 1 con coma                      0.667 E10 DIAB…
#>  7 E11.0  Diabetes mellitus tipo 2 con coma                      0.667 E11 DIAB…
#>  8 E12.0  Diabetes mellitus asociada con desnutrición, con coma  0.667 E12 DIAB…
#>  9 E13.0  Otras diabetes mellitus especificadas, con coma        0.667 E13 OTRA…
#> 10 E14.0  Diabetes mellitus, no especificada, con coma           0.667 E14 DIAB…
#> # ℹ 40 more rows
```

## Comorbilidades Charlson

``` r
# Requiere: install.packages("comorbidity")
df_pacientes <- data.frame(
  id_pac = c(1, 1, 2, 2, 3),
  diagnostico = c("E11.0", "I50.9", "C50.9", "N18.5", "J44.0")
)

cie_comorbid(df_pacientes, id = "id_pac", code = "diagnostico", map = "charlson")
```

## Tablas interactivas

``` r
# Requiere: install.packages("gt")
cie_table("E11")  # Visualizacion GT completa
```

## Fuente de datos

Datos oficiales CIE-10 Chile MINSAL/DEIS v2018:

- Centro FIC Chile: <https://deis.minsal.cl/centrofic/>
- Repositorio DEIS: <https://deis.minsal.cl>

## Mas informacion

- Reportar problemas: <https://github.com/RodoTasso/ciecl/issues>
- Repositorio: <https://github.com/RodoTasso/ciecl>
