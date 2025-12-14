# Paquete R: ciecl - CIE-10 Chile

## Estructura creada

El paquete `ciecl` ha sido creado exitosamente con la siguiente estructura:

```
ciecl/
├── DESCRIPTION           # Metadata del paquete
├── NAMESPACE            # Exports e imports
├── LICENSE              # Licencia MIT
├── README.Rmd           # Documentacion principal
├── .Rbuildignore        # Archivos ignorados en build
├── .gitignore           # Archivos ignorados en Git
├── ciecl.Rproj          # Proyecto RStudio
├── R/                   # Codigo fuente
│   ├── cie-data.R       # Parseo XLS y dataset
│   ├── cie-sql.R        # SQLite persistente
│   ├── cie-search.R     # Busqueda fuzzy
│   ├── cie-comorbid.R   # Comorbilidades
│   ├── cie-api.R        # API CIE-11 OMS
│   ├── cie-table.R      # Tablas GT
│   └── cie-utils.R      # Utilidades
├── data/                # Datasets (vacio, generar con script)
├── tests/               # Tests unitarios
│   ├── testthat.R
│   └── testthat/
│       ├── test-cie-sql.R
│       ├── test-cie-search.R
│       ├── test-cie-comorbid.R
│       └── test-cie-utils.R
├── vignettes/           # Documentacion extendida
│   └── ciecl.Rmd
├── man/                 # Documentacion generada (vacia)
└── inst/                # Archivos adicionales
```

## PASOS SIGUIENTES (EJECUTAR EN R)

### 1. Instalar dependencias necesarias

```r
# Abrir el proyecto ciecl.Rproj en RStudio
# Luego ejecutar:

install.packages(c(
  "devtools", "usethis", "roxygen2",
  "DBI", "RSQLite", "stringdist", "stringr", 
  "dplyr", "icd", "comorbidity", "gt", 
  "httr2", "readxl", "tibble", "rlang",
  "testthat", "knitr", "rmarkdown", "covr"
))
```

### 2. Generar dataset desde el archivo XLS

IMPORTANTE: Antes de ejecutar este paso, asegurate de que el archivo 
`Lista-Tabular-CIE-10-1-1.xls` exista en `01_Paquete_R/`

```r
# Desde el directorio ciecl/, ejecutar:
setwd("d:/MAGISTER/01_Paquete_R/ciecl")

# Cargar la funcion de parseo
source("R/cie-data.R")

# Generar el dataset (esto crea data/cie10_cl.rda)
generar_cie10_cl()
```

### 3. Generar documentacion con Roxygen2

```r
# Generar archivos .Rd en man/
devtools::document()
```

### 4. Instalar y probar el paquete localmente

```r
# Instalar el paquete en tu biblioteca local
devtools::install()

# Cargar el paquete
library(ciecl)

# Probar funciones basicas
data(cie10_cl)
head(cie10_cl)

# Probar SQL (requiere haber generado el dataset primero)
cie10_sql("SELECT COUNT(*) FROM cie10")
```

### 5. Ejecutar tests

```r
# Correr todos los tests
devtools::test()
```

### 6. Build y Check completo (preparacion CRAN)

```r
# Build del paquete
devtools::build()

# Check completo (puede tomar varios minutos)
devtools::check()

# El objetivo es: 0 errors, 0 warnings, 0 notes
```

### 7. Renderizar README.md

```r
# Convertir README.Rmd a README.md
rmarkdown::render("README.Rmd")
```

## NOTAS IMPORTANTES

1. **Dataset CIE-10**: El archivo `data/cie10_cl.rda` NO se ha generado aun.
   Debes ejecutar `generar_cie10_cl()` con el archivo XLS presente.

2. **Documentacion man/**: Vacia hasta que ejecutes `devtools::document()`

3. **Tests**: Los tests asumen que el dataset ya fue generado. Usa `skip_on_cran()`
   para evitar problemas en CRAN.

4. **Encoding UTF-8**: Todos los archivos usan UTF-8 para caracteres en espanol.

5. **SQLite Cache**: La base de datos SQLite se crea automaticamente en:
   `tools::R_user_dir("ciecl", "data")/cie10.db`

## FUNCIONES PRINCIPALES

- `generar_cie10_cl()`: Generar dataset desde XLS (ejecutar UNA VEZ)
- `cie10_sql()`: Consultas SQL sobre CIE-10
- `cie_search()`: Busqueda fuzzy con Jaro-Winkler
- `cie_lookup()`: Busqueda exacta por codigo
- `cie_comorbid()`: Calculo comorbilidades Charlson/Elixhauser
- `cie_map_comorbid()`: Mapeo categorias comorbilidad Chile
- `cie11_search()`: Busqueda en API CIE-11 OMS
- `cie_table()`: Tablas interactivas GT
- `cie_validate_vector()`: Validacion formato codigos
- `cie_expand()`: Expansion jerarquica de codigos
- `cie10_clear_cache()`: Limpiar cache SQLite

## AUTOR

Rodolfo Tasso Suazo
rtasso@uchile.cl

## LICENCIA

MIT License - Ver archivo LICENSE
