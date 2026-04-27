# Caso de Uso: Análisis de Egresos Hospitalarios (DEIS Chile)

## Introducción

Este caso de uso describe el flujo de procesamiento técnico necesario
para transformar bases de datos administrativas de salud en Chile hacia
un formato analítico estandarizado. Se utilizan como referencia las
bases de **Egresos Hospitalarios** publicadas por el Departamento de
Estadísticas e Información de Salud (DEIS).

Los registros administrativos de salud presentan frecuentemente
inconsistencias estructurales en la codificación CIE-10. Las dos
variaciones más comunes en el contexto chileno son:

1.  **Formatos compactos**: Códigos sin punto decimal (ej: `J189` en
    lugar de `J18.9`).
2.  **Sufijos de relleno**: Uso de la letra `X` para completar la
    longitud del campo en categorías de 3 dígitos (ej: `I10X` para
    Hipertensión esencial).

Estas variaciones dificultan la interoperabilidad y el cruce con
estándares internacionales. El paquete `ciecl` automatiza la corrección
de estas inconsistencias de forma vectorizada y eficiente.

## 1. Estructura de los datos originales

A continuación, se genera un conjunto de datos sintético que replica la
estructura y las anomalías típicas encontradas en los archivos `.csv`
del DEIS. La columna `DIAG1` representa el diagnóstico principal con los
formatos informales mencionados.

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

## 2. Normalización de códigos con `cie_norm()`

La normalización es el primer paso crítico para garantizar la integridad
del análisis. La función
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
procesa los códigos aplicando las reglas de codificación oficial MINSAL:

- **Remoción de sufijos**: Identifica y elimina la `X` de relleno.
- **Formateo de puntuación**: Inserta el punto decimal en la posición
  estándar según la jerarquía CIE-10.
- **Limpieza de strings**: Elimina espacios en blanco y caracteres no
  imprimibles.

``` r
# Limpieza y estandarización de diagnósticos
egresos <- egresos %>%
  mutate(
    DIAG1_NORM = cie_norm(codes = DIAG1)
  )

# Comparación entre formato original y normalizado
egresos %>% 
  select(DIAG1, DIAG1_NORM) %>% 
  distinct() %>% 
  head(5)
#>   DIAG1 DIAG1_NORM
#> 1  J189      J18.9
#> 2  E119      E11.9
#> 3  E149      E14.9
#> 4  N390      N39.0
#> 5  I10X        I10
```

## 3. Enriquecimiento semántico con `cie_describe()`

Tras la normalización, es necesario asignar las descripciones clínicas
oficiales para facilitar la interpretación de los resultados. El paquete
`ciecl` ofrece la función vectorizada
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md),
diseñada específicamente para integrarse en flujos de `dplyr` de forma
eficiente.

A diferencia de un `left_join` tradicional,
[`cie_describe()`](https://rodotasso.github.io/ciecl/reference/cie_describe.md)
devuelve directamente un vector de caracteres, evitando la creación de
columnas de unión adicionales y manteniendo el código más limpio.

``` r
# Integración directa de descripciones al dataframe principal
egresos_full <- egresos %>%
  mutate(
    descripcion = cie_describe(DIAG1_NORM)
  )

head(egresos_full %>% select(ID_EGRESO, DIAG1, descripcion))
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

Para casos donde se requiera la metadata completa (capítulo, categoría,
grupo), se puede seguir utilizando
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
junto con un cruce de tablas:

``` r
# Obtención de metadata completa vía lookup + join
metadata <- cie_lookup(
  code = unique(egresos$DIAG1_NORM),
  full_description = TRUE
)

egresos_metadata <- egresos %>%
  left_join(metadata, by = c("DIAG1_NORM" = "codigo"))
```

## 4. Exploración del catálogo con `cie_search()`

En fases exploratorias, donde no se conoce el código exacto o se
sospecha de errores de transcripción en las glosas originales,
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
permite realizar búsquedas de texto mediante similitud de strings (fuzzy
matching).

``` r
# Ejemplo de búsqueda con error ortográfico intencional ("diabetis")
# La función retorna las coincidencias más probables ordenadas por score
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

## 5. Cálculo de índices de comorbilidad con `cie_comorbid()`

Una aplicación avanzada de `ciecl` es la estratificación de riesgo
poblacional mediante índices de comorbilidad. La función
[`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)
mapea los diagnósticos normalizados hacia categorías de Charlson o
Elixhauser, adaptadas a la realidad de los datos chilenos.

``` r
# Requiere el paquete 'comorbidity' instalado
# Cálculo del Índice de Charlson por identificador de paciente
comorbilidades <- cie_comorbid(
  data = egresos,
  id = "PACIENTE_ID",
  code = "DIAG1",
  map = "charlson"
)

# El resultado permite el uso inmediato en modelos estadísticos
head(comorbilidades, 10)
```

## Resumen del proceso

El flujo de trabajo con `ciecl` permite una transición reproducible
desde datos administrativos crudos hacia un dataset analítico en cuatro
etapas:

1.  **Estandarización**: Corrección de formatos mediante
    [`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md).
2.  **Contextualización**: Asignación de glosas oficiales con
    [`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md).
3.  **Validación**: Descubrimiento y chequeo de términos con
    [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md).
4.  **Agregación**: Generación de indicadores clínicos complejos con
    [`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md).

------------------------------------------------------------------------

**Fuente de datos:** Esta herramienta utiliza el catálogo CIE-10
estandarizado por el Centro FIC del DEIS, Ministerio de Salud de Chile.
Para más información, visite [deis.minsal.cl](https://deis.minsal.cl).
