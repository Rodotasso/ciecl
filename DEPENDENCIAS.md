# Dependencias del Paquete ciecl

## Resumen Rapido

```
                    +------------------+
                    |      ciecl       |
                    +------------------+
                            |
        +-------------------+-------------------+
        |                                       |
+-------v-------+                       +-------v-------+
|   IMPORTS     |                       |   SUGGESTS    |
|   (8 pkgs)    |                       |   (8 pkgs)    |
|   Requeridos  |                       |   Opcionales  |
+---------------+                       +---------------+
```

| Tipo | Cantidad | Instalacion |
|------|----------|-------------|
| Imports (obligatorias) | 8 | Automatica |
| Suggests (opcionales) | 8 | Manual segun uso |
| **Total** | **16** | - |

---

## Dependencias OBLIGATORIAS (Imports)

Se instalan automaticamente con el paquete:

```
+------------------------------------------------------------------+
|                        CORE DEPENDENCIES                          |
+------------------------------------------------------------------+
|                                                                   |
|  +-------------+     +-------------+     +-------------+          |
|  |    DBI      |     |  RSQLite    |     | stringdist  |          |
|  | DB Interface|---->| SQLite Engn |     | Fuzzy Match |          |
|  +-------------+     +-------------+     +-------------+          |
|                                                                   |
|  +-------------+     +-------------+     +-------------+          |
|  |   stringr   |     |   dplyr     |     |   tibble    |          |
|  | String Ops  |     | Data Manip  |     | Modern DF   |          |
|  +-------------+     +-------------+     +-------------+          |
|                                                                   |
|  +-------------+     +-------------+                              |
|  |    tools    |     |    utils    |  <- Base R (incluidos)       |
|  | User Dirs   |     | Base Utils  |                              |
|  +-------------+     +-------------+                              |
|                                                                   |
+------------------------------------------------------------------+
```

### Detalle por Paquete

| Paquete | Funcion | Justificacion |
|---------|---------|---------------|
| **DBI** | Interfaz DB | Abstraccion para SQLite |
| **RSQLite** | Motor SQLite | Almacena 39,873 codigos CIE-10 |
| **stringdist** | Fuzzy matching | Jaro-Winkler para typos |
| **stringr** | Strings | Normalizar codigos |
| **dplyr** | Data wrangling | Transformar tibbles |
| **tibble** | Data frames | Formato salida consistente |
| **tools** | Utilidades R | Directorios de usuario |
| **utils** | Base R | Funciones basicas |

---

## Dependencias OPCIONALES (Suggests)

Solo se requieren para funcionalidades especificas:

```
+------------------------------------------------------------------+
|                     OPTIONAL DEPENDENCIES                         |
+------------------------------------------------------------------+
|                                                                   |
|  ANALISIS AVANZADO          API EXTERNA           DESARROLLO      |
|  +---------------+          +---------------+     +-------------+ |
|  | comorbidity   |          |    httr2      |     |  testthat   | |
|  | Charlson/Elix |          |   CIE-11 API  |     |    Tests    | |
|  +---------------+          +---------------+     +-------------+ |
|                                                                   |
|  VISUALIZACION              GENERACION DATOS                      |
|  +---------------+          +---------------+     +-------------+ |
|  |      gt       |          |    readxl     |     |   knitr     | |
|  | Tablas HTML   |          |  Excel Import |     |  Vignettes  | |
|  +---------------+          +---------------+     +-------------+ |
|                                                                   |
|  UTILIDADES                                                       |
|  +---------------+          +---------------+                     |
|  |   usethis     |          |  rmarkdown    |                     |
|  |  Dev Tools    |          |    Docs       |                     |
|  +---------------+          +---------------+                     |
|                                                                   |
+------------------------------------------------------------------+
```

### Matriz de Funciones vs Dependencias

| Funcion | Paquete Requerido | Instalacion |
|---------|-------------------|-------------|
| `cie_comorbid()` | comorbidity | `install.packages("comorbidity")` |
| `cie_map_comorbid()` | comorbidity | `install.packages("comorbidity")` |
| `cie_table()` | gt | `install.packages("gt")` |
| `cie11_search()` | httr2 | `install.packages("httr2")` |
| `generar_cie10_cl()` | readxl, usethis | `install.packages(c("readxl", "usethis"))` |

---

## Funciones CORE (Sin dependencias extra)

Estas funciones solo requieren los 8 paquetes base:

```r
library(ciecl)

# Busqueda exacta
cie_lookup("E11.0")                    # Un codigo
cie_lookup(c("E11.0", "I10", "Z00"))   # Multiples

# Busqueda fuzzy (tolera typos)
cie_search("diabetis mellitus")        # Encuentra "diabetes mellitus"

# Normalizacion
cie_normalizar(c("E11.0", "I10.0"))

# Validacion
cie_validate_vector(c("E11.0", "XXX"))

# Expansion jerarquica
cie_expand("E11")                      # E11 -> E11.0, E11.1, ..., E11.9

# Consultas SQL directas
cie10_sql("SELECT * FROM cie10 WHERE codigo LIKE 'E11%'")
```

> **Cobertura**: Estas funciones cubren el **80%** de los casos de uso tipicos.

---

## Instalacion

### Minima (solo core)
```r
# 8 dependencias, funcionalidad basica
install.packages("ciecl")
```

### Completa (todas las funciones)
```r
# 16 dependencias, todas las funcionalidades
install.packages("ciecl", dependencies = TRUE)
```

### Selectiva (segun necesidad)
```r
# Solo comorbilidades
install.packages(c("ciecl", "comorbidity"))

# Solo API CIE-11
install.packages(c("ciecl", "httr2"))

# Solo tablas bonitas
install.packages(c("ciecl", "gt"))
```

---

## Comparacion con Otros Paquetes

```
Dependencias Imports (obligatorias):

ciecl           ████████ 8
Tipico R pkg    ████████████ 12
Tidyverse       ██████████████████████████████ 30+
```

| Paquete | Imports | Total Deps |
|---------|---------|------------|
| **ciecl** | 8 | 16 |
| Paquete tipico | 10-15 | 20-30 |
| Tidyverse | 30+ | 80+ |

---

## Historial de Optimizacion

```
Antes:  14 imports  ████████████████████████████
Ahora:   8 imports  ████████████████

Reduccion: 43% menos dependencias obligatorias
```

Las funciones core ahora funcionan sin paquetes adicionales. Solo instalas lo opcional cuando realmente lo necesitas.
