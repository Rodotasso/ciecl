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

Para la versión de desarrollo, que incluye las funcionalidades más
recientes antes de su paso a CRAN:

``` r

# Requiere el paquete pak para una gestión eficiente de dependencias
pak::pak("RodoTasso/ciecl")
```

## Consultas SQL directas al catálogo

La función
[`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)
permite interactuar directamente con la base de datos SQLite interna.
Esto otorga una gran flexibilidad para realizar filtros complejos que no
están cubiertos por las funciones predefinidas, utilizando toda la
potencia del lenguaje SQL.

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

Por razones de seguridad y para preservar la integridad del estándar, la
función solo permite consultas de tipo `SELECT`. Esto asegura que el
catálogo permanezca como una fuente de verdad inmutable durante el
análisis.

## Búsqueda por código conocido

Cuando el analista ya dispone de los códigos —como ocurre habitualmente
en los registros de egreso hospitalario—,
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
permite recuperar la descripción oficial de forma instantánea. Esta
función actúa como el puente necesario entre la codificación técnica y
la interpretación clínica.

``` r

# Recuperar un código único
cie_lookup("E11.0")
#> # A tibble: 1 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 E11.0  Diabetes mellitu… E11 DIAB… E08-E1… Cap.04  ENFERM… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <int>, es_cruz <int>,
#> #   uso_cl <chr>
```

La función es totalmente vectorizada, lo que facilita su integración en
pipelines de procesamiento masivo. Devuelve un objeto `tibble` con una
estructura consistente:

``` r

# Múltiples códigos de distintos capítulos en una sola llamada
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

En investigaciones que operan a nivel de categoría (los primeros tres
dígitos), el argumento `expand = TRUE` resulta fundamental, ya que
desglosa la jerarquía completa de una familia de códigos:

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

## Obtener descripciones para reportes

Si el objetivo es simplemente enriquecer una tabla existente con glosas
descriptivas (por ejemplo, para leyendas de gráficos o reportes
rápidos),
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
es la opción más eficiente. Retorna un vector de caracteres que mantiene
el orden original de la entrada.

``` r

cie_describe(c("E11.0", "I10"))
#> [1] "Diabetes mellitus tipo 2 con coma" "Hipertensión esencial (primaria)"
```

Este enfoque optimiza el uso de memoria al evitar joins complejos,
permitiendo operaciones fluidas dentro de un flujo `dplyr`:

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

egresos |>
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

Los datos clínicos de texto libre suelen presentar variaciones
ortográficas, omisión de tildes o abreviaturas que dificultan la unión
exacta.
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
utiliza el algoritmo Jaro-Winkler para encontrar la correspondencia más
cercana en el catálogo oficial.

El parámetro `threshold` (umbral) permite ajustar la sensibilidad de la
búsqueda. Un valor de `0.75` suele ser un buen compromiso para el idioma
español, permitiendo capturar errores comunes sin introducir demasiado
ruido:

``` r

# Búsqueda tolerante: "diabetis" en lugar de "diabetes"
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

El resultado incluye un `score` de similitud, lo que permite al analista
evaluar la confiabilidad de la coincidencia de forma cuantitativa.

## Comorbilidades de Charlson y Elixhauser

Para la investigación epidemiológica, la estratificación del riesgo es
un paso crítico.
[`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)
simplifica el cálculo de los índices de Charlson y Elixhauser, mapeando
automáticamente los códigos CIE-10 a sus respectivas categorías
clínicas.

``` r

# Requiere el paquete externo 'comorbidity'
df_pacientes <- data.frame(
  id_pac     = c(1, 1, 2, 2, 3),
  diagnostico = c("E11.0", "I50.9", "C50.9", "N18.5", "J44.0")
)

cie_comorbid(df_pacientes, id = "id_pac", code = "diagnostico", map = "charlson")
#> # A tibble: 3 × 19
#>   id_pac    mi   chf   pvd  cevd dementia   cpd rheumd   pud   mld  diab diabwc
#>    <dbl> <int> <int> <int> <int>    <int> <int>  <int> <int> <int> <int>  <int>
#> 1      1     0     1     0     0        0     0      0     0     0     1      0
#> 2      2     0     0     0     0        0     0      0     0     0     0      0
#> 3      3     0     0     0     0        0     1      0     0     0     0      0
#> # ℹ 7 more variables: hp <int>, rend <int>, canc <int>, msld <int>,
#> #   metacanc <int>, aids <int>, score_charlson <dbl>
```

El objeto resultante es una matriz de indicadores lista para ser
incorporada en modelos de regresión o análisis de supervivencia.

## Tablas formateadas para publicación

Finalmente, para la comunicación de resultados,
[`cie_table()`](https://rodotasso.github.io/ciecl/reference/cie_table.md)
genera tablas en formato HTML con un diseño profesional utilizando el
motor de `gt`. La función ajusta el contenido dinámicamente según la
información disponible en el catálogo (como notas de inclusión o
exclusión).

``` r

# Requiere el paquete 'gt' instalado
cie_table("E11")
```

| CIE-10 Chile: E11 |  |
|----|----|
| Fuente: MINSAL/DEIS v2018 |  |
| Codigo | Diagnostico |
| E11 | Diabetes mellitus no insulinodependiente |
| E11.0 | Diabetes mellitus tipo 2 con coma |
| E11.1 | Diabetes mellitus tipo 2 con cetoacidosis |
| E11.2 | Diabetes mellitus tipo 2 con complicaciones renales |
| E11.3 | Diabetes mellitus tipo 2 con complicaciones oftálmicas |
| E11.4 | Diabetes mellitus tipo 2 con complicaciones neurológicas |
| E11.5 | Diabetes mellitus tipo 2 con complicaciones circulatorias periféricas |
| E11.6 | Diabetes mellitus tipo 2 con otras complicaciones especificadas |
| E11.7 | Diabetes mellitus tipo 2 con complicaciones múltiples |
| E11.8 | Diabetes mellitus tipo 2 con complicaciones no especificadas |
| E11.9 | Diabetes mellitus tipo 2 sin complicaciones |

## Fuente de datos oficial

Los datos de `ciecl` son un fiel reflejo del catálogo CIE-10 para Chile,
mantenido por el Departamento de Estadísticas e Información de Salud
(DEIS) del Ministerio de Salud:

- Centro FIC Chile: <https://deis.minsal.cl/centrofic/>
- Repositorio de Datos DEIS: <https://deis.minsal.cl>

## Colaboración y Soporte

- Reporte de errores o sugerencias:
  <https://github.com/RodoTasso/ciecl/issues>
- Código fuente y documentación: <https://github.com/RodoTasso/ciecl>
