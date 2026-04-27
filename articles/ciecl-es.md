# Introducción a ciecl: CIE-10 Chile en R

> **Versión 0.9.8**: Disponible en CRAN con optimizaciones SQLite,
> soporte XLSX y argumentos estandarizados en inglés.

## El problema: codificar diagnósticos en Chile

Los sistemas de información sanitaria chilenos —DEIS, GRD, REM—
almacenan diagnósticos usando la clasificación CIE-10 en su versión
oficial MINSAL/DEIS v2018. Trabajar con estos datos en R sin una
referencia local obliga al analista a consultar PDFs, tablas Excel o
sitios web, interrumpiendo el flujo de análisis.

`ciecl` resuelve este problema: incorpora los **39.877 códigos CIE-10**
del catálogo oficial directamente en R, con funciones de búsqueda
rápida, expansión jerárquica y cálculo de índices de comorbilidad.

## Instalación

El paquete está disponible en CRAN. Para instalar la versión estable:

``` r
install.packages("ciecl")
```

Para la versión de desarrollo con las últimas correcciones:

``` r
# Requiere el paquete pak
pak::pak("RodoTasso/ciecl")
```

## Consultas SQL directas al catálogo

La función
[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)
expone el catálogo completo a través de SQLite, lo que permite filtrar
con toda la expresividad de SQL. Esto es útil cuando se conoce la lógica
del código pero no el texto exacto, por ejemplo para recuperar todos los
subcódigos de una categoría.

El siguiente ejemplo extrae los primeros cinco códigos de diabetes tipo
2 (categoría E11):

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

La función solo acepta consultas `SELECT` para proteger la integridad
del catálogo. Esto garantiza que la base de datos local permanezca como
una referencia de solo lectura y confiable para el análisis.

## Búsqueda por código conocido

Cuando el código ya está disponible en los datos —por ejemplo, al
preparar un informe con diagnósticos de egreso hospitalario—
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
recupera la descripción oficial a partir de uno o varios códigos. Esta
función es el puente entre la codificación críptica de las bases de
datos y la interpretación clínica humana.

``` r
# Un solo código
cie_lookup("E11.0")
#> # A tibble: 1 × 10
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 3 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>
```

La función acepta vectores, lo que facilita su uso dentro de un pipeline
`dplyr` o cualquier flujo de trabajo vectorizado, devolviendo un
`tibble` con la información estructurada:

``` r
# Múltiples códigos de distintos capítulos
cie_lookup(c("E11.0", "I10", "Z00", "J44.0"))
#> # A tibble: 4 × 10
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> 2 I10    Hipertensión ese… I10 HIPE… I10-I1… Cap.09  ENFERM… NA        NA       
#> 3 J44.0  Enfermedad pulmo… J44 OTRA… J40-J4… Cap.10  ENFERM… NA        NA       
#> 4 Z00    Examen general e… Z00 EXAM… Z00-Z1… Cap.21  FACTOR… NA        NA       
#> # ℹ 3 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>
```

En análisis donde se trabaja a nivel de categoría (tres dígitos), puede
ser necesario conocer todos los subcódigos que la componen para realizar
agregaciones o filtros. El argumento `expand = TRUE` desciende la
jerarquía y devuelve la categoría junto con todos sus hijos:

``` r
cie_lookup("E11", expand = TRUE)
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

## Obtener descripciones para usar en tablas

A veces solo se necesita el texto de la descripción, sin la estructura
completa de
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md).
Por ejemplo, al crear etiquetas para un eje de gráfico o una columna
rápida en un reporte. La función
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
devuelve un vector de caracteres con las descripciones en el mismo orden
que los códigos recibidos, lista para usar en
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html):

``` r
cie_describe(c("E11.0", "I10"))
#> [1] "Diabetes mellitus tipo 2 con coma" "Hipertensión esencial (primaria)"
```

Este enfoque es particularmente potente cuando se combina con `dplyr`
para enriquecer bases de datos masivas sin necesidad de realizar cruces
complejos (`left_join`):

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

egresos <- data.frame(
  id = 1:4,
  codigo_diag = c("E11.0", "I10", "J44.0", "E11.0")
)

egresos %>%
  mutate(descripcion = cie_describe(codigo_diag))
#>   id codigo_diag
#> 1  1       E11.0
#> 2  2         I10
#> 3  3       J44.0
#> 4  4       E11.0
#>                                                                                        descripcion
#> 1                                                                Diabetes mellitus tipo 2 con coma
#> 2                                                                 Hipertensión esencial (primaria)
#> 3 Enfermedad pulmonar obstructiva crónica con infección aguda de las vías respiratorias inferiores
#> 4                                                                Diabetes mellitus tipo 2 con coma
```

## Búsqueda por texto con tolerancia a errores

En los datos clínicos es común encontrar diagnósticos escritos en texto
libre, con errores ortográficos o abreviaciones no estandarizadas que
dificultan la codificación automática.
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
implementa búsqueda fuzzy mediante similitud Jaro-Winkler, permitiendo
rescatar información de registros imperfectos.

El parámetro `threshold` controla qué tan estricta es la coincidencia:
valores cercanos a 1.0 exigen precisión casi absoluta, mientras que
valores más bajos toleran mayores variaciones. El rango útil habitual
para diagnósticos en español está entre 0.70 y 0.85:

``` r
# "diabetis" en lugar de "diabetes" — el error no impide encontrar el código correcto
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

Observe que el resultado está ordenado por un puntaje (`score`),
permitiendo al analista seleccionar la mejor coincidencia de forma
estadística.

## Comorbilidades de Charlson y Elixhauser

La capacidad de estratificar pacientes según su carga de enfermedad es
vital en investigación epidemiológica. Los índices de comorbilidad
—Charlson y Elixhauser— se utilizan para predecir mortalidad y uso de
recursos.
[`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)
automatiza este cálculo a partir de un flujo de datos tipo “egresos”:

``` r
# Requiere: install.packages("comorbidity")
df_pacientes <- data.frame(
  id_pac     = c(1, 1, 2, 2, 3),
  diagnostico = c("E11.0", "I50.9", "C50.9", "N18.5", "J44.0")
)

cie_comorbid(df_pacientes, id = "id_pac", code = "diagnostico", map = "charlson")
```

El resultado es un data frame procesado donde cada fila representa un
paciente único con sus respectivas banderas de patología y puntuación
total ponderada, listo para modelos de regresión o tablas descriptivas.

## Tablas formateadas con gt

Para presentaciones e informes finales, la estética de los datos es
fundamental.
[`cie_table()`](https://rodotasso.github.io/ciecl/reference/cie_table.md)
genera una tabla HTML enriquecida, aplicando formato condicional y
ocultando automáticamente columnas vacías para una visualización limpia.
Requiere tener `gt` instalado:

``` r
# Requiere: install.packages("gt")
cie_table("E11")
```

Esta función detecta si campos como “Incluye” o “Excluye” vienen
poblados desde la fuente oficial y ajusta el diseño de la tabla
dinámicamente.

## Fuente de datos

Los datos incluidos en `ciecl` provienen del catálogo oficial CIE-10
publicado por el Ministerio de Salud de Chile a través del Departamento
de Estadísticas e Información de Salud (DEIS):

- Centro FIC Chile: <https://deis.minsal.cl/centrofic/>
- Repositorio DEIS: <https://deis.minsal.cl>

## Más información

- Reportar problemas o sugerencias:
  <https://github.com/RodoTasso/ciecl/issues>
- Repositorio del paquete: <https://github.com/RodoTasso/ciecl>
