# Primeros pasos con ciecl: un reporte de egresos hospitalarios

## ¿Para quién es esta guía?

Imagina que trabajas en la unidad de estadística de un hospital y cada
mes eres la persona encargada de elaborar el **reporte de egresos por
diabetes** para la dirección del servicio. Recibes la base de egresos
hospitalarios, y tu objetivo es responder preguntas concretas: ¿cuántos
egresos tuvieron como diagnóstico principal una diabetes?, ¿de qué
tipo?, ¿qué tan complejos eran esos pacientes?

El problema es que la base llega con códigos CIE-10 en formatos
inconsistentes y sin descripciones: para interpretarlos tendrías que
consultar a mano el catálogo oficial en PDF o Excel. `ciecl` elimina ese
paso: incorpora el catálogo oficial CIE-10 de Chile (MINSAL/DEIS v2018)
dentro de R y te permite normalizar, describir, buscar y analizar los
códigos directamente sobre tu base.

Esta guía recorre ese flujo completo, de lo básico a lo avanzado. Solo
necesitas conocimientos básicos de R; si además usas `dplyr`, los
ejemplos encajan directo en tus pipelines.

## Los datos: egresos hospitalarios del DEIS

Las bases de **Egresos Hospitalarios** las publica el Departamento de
Estadísticas e Información de Salud (DEIS) del Ministerio de Salud de
Chile. Cada fila es un alta hospitalaria y la columna `DIAG1` contiene
el diagnóstico principal codificado en CIE-10.

En la práctica, estos archivos llegan con dos variaciones de formato muy
comunes:

1.  **Formatos compactos**: códigos sin punto decimal (ej: `J189` en
    lugar de `J18.9`).
2.  **Sufijos de relleno**: una letra `X` para completar la longitud del
    campo en categorías de 3 dígitos (ej: `I10X` para hipertensión
    esencial).

Generemos un conjunto de datos sintético que replica la estructura y las
anomalías típicas de los archivos del DEIS:

``` r

set.seed(42)

# Simulación de 200 registros con formatos típicos del DEIS Chile
egresos <- data.frame(
  ID_EGRESO = 1:200,
  PACIENTE_ID = sample(1:50, 200, replace = TRUE),
  ANO       = sample(2018:2022, 200, replace = TRUE),
  DIAG1     = sample(
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

head(egresos)
#>   ID_EGRESO PACIENTE_ID  ANO DIAG1
#> 1         1          49 2018  J189
#> 2         2          37 2022  E119
#> 3         3           1 2021  E149
#> 4         4          25 2018  N390
#> 5         5          10 2022  I10X
#> 6         6          36 2021  C509
```

## Paso 1: Normalizar los códigos con `cie_norm()`

Antes de cualquier análisis hay que estandarizar `DIAG1`.
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
aplica las reglas de codificación oficial del MINSAL de forma
vectorizada: elimina la `X` de relleno, inserta el punto decimal en la
posición correcta y limpia espacios, guiones y símbolos especiales (como
† o \*).

``` r

# Limpieza y estandarización de diagnósticos en el flujo de trabajo
egresos <- egresos |>
  mutate(
    DIAG1_NORM = cie_norm(codes = DIAG1)
  )

# Comparación entre formato original y normalizado
egresos |>
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

Con esto, `I10X` quedó como `I10` y `J189` como `J18.9`: los códigos ya
son comparables con el catálogo oficial.

## Paso 2: Agregar las descripciones oficiales con `cie_describe()`

Para el reporte necesitas las glosas clínicas, no solo los códigos.
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
devuelve un vector de texto con una descripción por cada código, así que
puedes agregarlo como una columna más de tu tabla con
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html), sin
pasos intermedios:

``` r

# Integración directa de descripciones al dataframe principal
egresos_full <- egresos |>
  mutate(
    descripcion = cie_describe(DIAG1_NORM)
  )

head(egresos_full |> select(ID_EGRESO, DIAG1, descripcion))
#>   ID_EGRESO DIAG1
#> 1         1  J189
#> 2         2  E119
#> 3         3  E149
#> 4         4  N390
#> 5         5  I10X
#> 6         6  C509
#>                                                       descripcion
#> 1                                       Neumonía, no especificada
#> 2                     Diabetes mellitus tipo 2 sin complicaciones
#> 3 Diabetes mellitus, no especificada, sin mención de complicación
#> 4              Infección de vías urinarias, sitio no especificado
#> 5                                Hipertensión esencial (primaria)
#> 6                 Tumor maligno de la mama, parte no especificada
```

Si además de la glosa necesitas la metadata completa (capítulo, grupo,
notas de inclusión/exclusión), usa
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md),
que devuelve un `tibble` estructurado listo para un
[`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html):

``` r

# Obtención de metadata completa vía lookup + join
metadata <- cie_lookup(
  code = unique(egresos$DIAG1_NORM),
  full_description = TRUE
)

egresos_metadata <- egresos |>
  left_join(metadata, by = c("DIAG1_NORM" = "codigo"))
```

## Paso 3: Encontrar códigos cuando no sabes el código con `cie_search()`

Volvamos a tu reporte de diabetes: sospechas que en la base hay egresos
por diabetes, pero ¿qué códigos exactos cubre el catálogo? En vez de
hojear el PDF, buscas por texto.
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
usa similitud Jaro-Winkler, así que tolera errores tipográficos (aquí
buscamos “diabetis” a propósito):

``` r

# Búsqueda tolerante: "diabetis" en lugar de "diabetes"
# (por defecto se muestran los 50 resultados más parecidos;
#  ampliamos el límite porque el catálogo tiene muchos códigos de diabetes)
resultados_busqueda <- cie_search(text = "diabetis", threshold = 0.7, max_results = 100)

resultados_busqueda
#> # A tibble: 100 × 4
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
#> # ℹ 90 more rows
```

Cada resultado incluye un `score` de similitud para evaluar la
confiabilidad de la coincidencia. Pero la tabla anterior lista todos los
códigos de diabetes del catálogo, y no todos necesariamente están en tu
base. Para saber cuáles sí, basta con cruzar los resultados de la
búsqueda con los códigos que realmente aparecen en tus datos:

``` r

# ¿Qué códigos de diabetes están realmente en mi base?
codigos_diabetes <- intersect(
  resultados_busqueda$codigo,
  unique(egresos$DIAG1_NORM)
)

codigos_diabetes
#> [1] "E11.9" "E14.9"
```

Como se ve en el resultado, de todos los códigos de diabetes del
catálogo solo dos están presentes en la columna `DIAG1` de tu base:
`E11.9` y `E14.9`. El cruce identifica qué códigos contienen realmente
tus datos, sin tener que revisar la tabla completa a mano. Con esa lista
ya puedes filtrar los egresos y cerrar el reporte:

``` r

# Reporte final: egresos por diabetes, resumidos por tipo
egresos_full |>
  filter(DIAG1_NORM %in% codigos_diabetes) |>
  count(descripcion, sort = TRUE)
#>                                                       descripcion  n
#> 1                     Diabetes mellitus tipo 2 sin complicaciones 14
#> 2 Diabetes mellitus, no especificada, sin mención de complicación 12
```

Con esto tu reporte mensual de egresos por diabetes queda listo: sabes
cuántos hubo y de qué tipo, con las glosas oficiales del catálogo.

## Cuando la búsqueda no entrega resultados

Es normal que algunas consultas no encuentren nada, y conviene saber
cómo se comporta el paquete en esos casos: **las funciones nunca fallan
con un error por ausencia de resultados; devuelven un `tibble` vacío con
la estructura de columnas correcta** y un mensaje informativo.

Si buscas un código que no existe en el catálogo:

``` r

cie_lookup("XYZ123")
#> ✖ Código no encontrado: "XYZ123"
#> # A tibble: 0 × 11
#> # ℹ 11 variables: codigo <chr>, descripcion <chr>, categoria <chr>,
#> #   seccion <chr>, capitulo_nombre <chr>, inclusion <chr>, exclusion <chr>,
#> #   capitulo <chr>, es_daga <lgl>, es_cruz <lgl>, uso_cl <chr>
```

Si el umbral de
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
es demasiado estricto para el término ingresado:

``` r

cie_search("zzzqwerty", threshold = 0.95)
#> ✖ Sin coincidencias >= threshold 0.95
#> # A tibble: 0 × 4
#> # ℹ 4 variables: codigo <chr>, descripcion <chr>, score <dbl>, categoria <chr>
```

En ambos casos el flujo no se interrumpe: puedes verificar
`nrow(resultado) == 0` y reaccionar (bajar el `threshold`, revisar la
ortografía o validar el código). Para chequear rápidamente qué códigos
de un vector son válidos según el catálogo, usa
[`cie_validate_vector()`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md):

``` r

cie_validate_vector(c("E11.0", "XYZ123", "I10X"))
#> [1]  TRUE FALSE  TRUE
```

## Paso 4: Estratificar riesgo con `cie_comorbid()`

El último nivel del reporte es la complejidad de los pacientes.
[`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)
mapea los diagnósticos a los índices de Charlson o Elixhauser y devuelve
una matriz de comorbilidades por paciente, lista para modelos
estadísticos:

``` r

# Requiere el paquete 'comorbidity' instalado
# Cálculo del Índice de Charlson consolidado por paciente
comorbilidades <- cie_comorbid(
  data = egresos,
  id = "PACIENTE_ID",
  code = "DIAG1",
  map = "charlson"
)

head(comorbilidades, 10)
#> # A tibble: 10 × 19
#>    PACIENTE_ID    mi   chf   pvd  cevd dementia   cpd rheumd   pud   mld  diab
#>          <int> <int> <int> <int> <int>    <int> <int>  <int> <int> <int> <int>
#>  1           1     0     0     0     0        0     0      0     0     0     1
#>  2           2     0     0     0     0        0     0      0     0     0     0
#>  3           3     0     0     0     0        0     0      0     0     0     1
#>  4           4     0     1     0     0        0     1      0     0     0     0
#>  5           5     0     1     0     0        0     0      0     0     0     1
#>  6           6     0     0     0     0        0     1      0     0     0     1
#>  7           7     0     0     0     0        0     0      0     0     0     0
#>  8           8     0     0     0     0        0     0      0     0     0     1
#>  9           9     0     0     0     0        0     1      0     0     0     0
#> 10          10     0     0     0     0        0     0      0     0     0     1
#> # ℹ 8 more variables: diabwc <int>, hp <int>, rend <int>, canc <int>,
#> #   msld <int>, metacanc <int>, aids <int>, score_charlson <dbl>
```

## Resumen del flujo

El recorrido de esta guía cubre el ciclo completo desde la base cruda
hasta el insumo analítico:

1.  **Estandarización**: corrección de formatos con
    [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md).
2.  **Contextualización**: glosas oficiales con
    [`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
    y metadata con
    [`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md).
3.  **Exploración**: búsqueda de códigos por texto con
    [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md),
    tolerante a errores y con comportamiento predecible cuando no hay
    resultados.
4.  **Agregación**: índices de comorbilidad con
    [`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md).

¿No sabes cuál función usar en otro escenario? Ejecuta
[`cie_guide()`](https://rodotasso.github.io/ciecl/reference/cie_guide.md)
para ver una tabla comparativa con la función recomendada y un ejemplo
por caso.

## Para seguir aprendiendo

- [Guía de instalación y
  configuración](https://rodotasso.github.io/ciecl/articles/instalacion.md):
  instalación y credenciales para la API CIE-11 de la OMS.
- [Introducción a ciecl: CIE-10 Chile en
  R](https://rodotasso.github.io/ciecl/articles/ciecl-es.md): recorrido
  por función, incluyendo consultas SQL directas con
  [`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)
  y tablas formateadas con
  [`cie_table()`](https://rodotasso.github.io/ciecl/reference/cie_table.md).
- [Idiomas y
  normalización](https://rodotasso.github.io/ciecl/articles/idiomas.md):
  búsqueda en español e inglés y manejo de tildes.

------------------------------------------------------------------------

**Fuente de datos:** Esta herramienta utiliza el catálogo CIE-10 oficial
para Chile, gestionado por el DEIS del Ministerio de Salud. Más detalles
en [deis.minsal.cl](https://deis.minsal.cl).
