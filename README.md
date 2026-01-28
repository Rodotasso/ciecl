
> **Language / Idioma:**
> [English](https://github.com/RodoTasso/ciecl/blob/main/README.en.md)
> \| **Español**

<!-- README.md is generated from README.Rmd. Please edit that file -->

# ciecl <img src="man/figures/logo-CDSP_color.png" align="right" height="80" alt="CDSP">

**Grupo de Ciencia de Datos para Salud Pública** | Universidad de Chile

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN
status](https://www.r-pkg.org/badges/version/ciecl)](https://CRAN.R-project.org/package=ciecl)
[![GitHub
release](https://img.shields.io/github/v/release/RodoTasso/ciecl)](https://github.com/RodoTasso/ciecl/releases)
[![R-CMD-check](https://github.com/RodoTasso/ciecl/actions/workflows/r.yml/badge.svg)](https://github.com/RodoTasso/ciecl/actions/workflows/r.yml)
![Visitors](https://komarev.com/ghpvc/?username=RodoTasso&repo=ciecl&label=Visitas&color=blue)
<!-- badges: end -->

**Clasificación Internacional de Enfermedades (CIE-10) oficial de Chile
para R**.

Paquete especializado para búsqueda, validación y análisis de códigos
CIE-10 en el contexto chileno. Incluye 39,873 códigos (categorías y
subcategorías) con búsqueda optimizada, cálculo de comorbilidades y
acceso a la API CIE-11 de la OMS.

## Finalidad

`ciecl` facilita el trabajo con códigos CIE-10 en investigación y
análisis de datos de salud en Chile, eliminando la necesidad de
manipular archivos Excel manualmente y proporcionando herramientas
especializadas para:

- Validación rápida de códigos diagnósticos
- Búsqueda tolerante a errores (fuzzy search)
- Cálculo automático de índices de comorbilidad (Charlson, Elixhauser)
- Consultas SQL optimizadas sobre más de 39 mil códigos
- Expansión de categorías a subcategorías (ej: E11 -\> E11.0, E11.1, …,
  E11.9)

## Por qué usar ciecl en lugar de un archivo XLSX

### Ventajas sobre archivos Excel:

1.  **Rendimiento**: Base de datos SQLite indexada con búsquedas 10-100x
    más rápidas que Excel
2.  **Integración nativa**: Funciona directamente en R sin dependencias
    externas pesadas
3.  **Fuzzy search**: Encuentra “neumonía bacteriana” aunque esté mal
    escrito (tolera errores tipográficos)
4.  **Validación vectorizada**: Procesa miles de códigos en milisegundos
5.  **Normalización automática**: Acepta E110, E11.0, e11.0
    indistintamente
6.  **Sin errores de encoding**: Los archivos XLSX tienen problemas con
    tildes y ñ en diferentes sistemas
7.  **Reproducibilidad**: Versión controlada del catálogo CIE-10 (no
    cambia entre computadores)
8.  **Comorbilidades predefinidas**: Mapeos Charlson/Elixhauser listos
    para usar
9.  **API CIE-11**: Acceso directo a la clasificación internacional
    actualizada
10. **Cache inteligente**: Guarda consultas frecuentes para mayor
    velocidad

### Ejemplo comparativo:

``` r
# Con XLSX (lento, manual, propenso a errores)
library(readxl)
cie10 <- read_excel("CIE-10.xlsx")
diabete_codes <- cie10[grepl("diabetes", tolower(cie10$descripcion)), ]

# Con ciecl (rápido, robusto, con cache)
library(ciecl)
diabete_codes <- cie_search("diabetes")
```

## Características principales

- **39,873 códigos CIE-10**: Incluye todas las categorías (3 dígitos) y
  subcategorías (4+ dígitos)
- **Búsqueda fuzzy**: Algoritmo de distancia Levenshtein para tolerar
  errores de escritura
- **SQL directo**: Acceso completo a la base de datos para consultas
  complejas
- **Vectorización**: Procesa miles de códigos simultáneamente
- **Cache SQLite**: Almacena resultados frecuentes para consultas
  instantáneas
- **Comorbilidades**: Mapeos validados de Charlson y Elixhauser
- **Expansión jerárquica**: Obtiene todos los subcodes de una categoría
- **API CIE-11**: Búsqueda en la clasificación internacional actualizada
  (OMS)
- **Sin dependencias pesadas**: Solo requiere readxl, dplyr, stringr,
  DBI y RSQLite

## Instalación

``` r
# Instalación básica (funcionalidad core - 8 dependencias)
install.packages("ciecl")

# Instalación completa (incluye paquetes opcionales)
install.packages("ciecl", dependencies = TRUE)

# Desde GitHub (desarrollo)
devtools::install_github("RodoTasso/ciecl")
```

**Nota**: El paquete tiene **dependencias mínimas** para funcionalidad
core. Paquetes adicionales solo se requieren para funciones específicas.
Ver [DEPENDENCIAS.md](DEPENDENCIAS.md) para detalles.

## Uso rápido

``` r
library(ciecl)

# Búsqueda exacta (soporta múltiples formatos)
cie_lookup("E11.0")   # Con punto
cie_lookup("E110")    # Sin punto
cie_lookup("E11")     # Solo categoría

# Vectorizado - múltiples códigos
cie_lookup(c("E11.0", "I10", "Z00"))

# Con descripción completa formateada
cie_lookup("E110", descripcion_completa = TRUE)

# Extraer código de texto con prefijos/sufijos (solo código escalar)
cie_lookup("CIE:E11.0", extract = TRUE)       # Retorna E11.0
cie_lookup("E11.0-confirmado", extract = TRUE) # Retorna E11.0
cie_lookup("dx-G20", extract = TRUE)          # Retorna G20
# Nota: extract=TRUE solo funciona con códigos escalares

# Fuzzy search con errores tipográficos
cie_search("diabetis mellitus")  # Encuentra "diabetes mellitus"

# Búsqueda por siglas médicas (88 abreviaturas soportadas)
cie_search("IAM")   # Infarto Agudo al Miocardio
cie_search("TBC")   # Tuberculosis
cie_search("DM2")   # Diabetes Mellitus tipo 2
cie_search("EPOC")  # Enfermedad Pulmonar Obstructiva Crónica
cie_search("HTA")   # Hipertensión Arterial

# Ver todas las abreviaturas disponibles
cie_siglas()

# SQL directo
cie10_sql("SELECT * FROM cie10 WHERE codigo LIKE 'E11%' LIMIT 3")

# Comorbilidades (requiere: install.packages("comorbidity"))
df %>% cie_comorbid(id = "paciente", code = "diagnostico", map = "charlson")
```

## Configuración CIE-11 (opcional)

Para usar `cie11_search()` y acceder a la clasificación internacional
actualizada, necesitas credenciales gratuitas de la OMS:

### Paso 1: Obtener credenciales

1.  Visita <https://icd.who.int/icdapi>
2.  Regístrate con tu email (proceso gratuito)
3.  Obtendrás un `Client ID` y `Client Secret`

### Paso 2: Configurar en R

**Opción A: Variable de entorno (recomendado)**

Crea un archivo `.Renviron` en tu directorio de trabajo o home:

``` r
# En .Renviron
ICD_API_KEY=tu_client_id:tu_client_secret
```

**Opción B: En cada sesión**

``` r
Sys.setenv(ICD_API_KEY = "tu_client_id:tu_client_secret")
```

### Paso 3: Usar CIE-11

``` r
library(ciecl)

# Buscar en CIE-11 (requiere httr2)
cie11_search("diabetes mellitus", max_results = 5)
#> # A tibble: 5 x 3
#>   codigo  titulo                                    capitulo
#>   <chr>   <chr>                                     <chr>
#> 1 5A14    Diabetes mellitus, tipo no especificado   05
#> 2 5A11    Diabetes mellitus tipo 2                  05
#> 3 5A10    Diabetes mellitus tipo 1                  05
```

**Nota**: CIE-11 es opcional. Todas las funciones core (CIE-10)
funcionan sin API key.

## Datos

Basado en **MINSAL/DEIS v2018** (repositorio público):  
<https://repositoriodeis.minsal.cl>

## Licencia

MIT + datos MINSAL dominio público (Decreto 356/2017)

## Contribuir

Las contribuciones son bienvenidas:

- Reportar bugs en [GitHub Issues](https://github.com/RodoTasso/ciecl/issues)
- Sugerir mejoras o nuevas funcionalidades
- Enviar pull requests

## Autor

**Rodolfo Tasso Suazo** | <rtasso@uchile.cl>

### Afiliación Institucional

<p align="center">
<img src="man/figures/logo-CDSP_color.png" height="100" alt="Grupo de Ciencia de Datos para Salud Pública">
</p>

**Grupo de Ciencia de Datos para Salud Pública**<br>
Escuela de Salud Pública, Facultad de Medicina<br>
Universidad de Chile

Este paquete fue desarrollado como parte del trabajo del Grupo de Ciencia
de Datos para Salud Pública, dedicado a aplicar métodos computacionales y
estadísticos para mejorar la investigación en salud pública en Chile.

## Enlaces

- **Repositorio**: <https://github.com/RodoTasso/ciecl>
- **Reportar issues**: <https://github.com/RodoTasso/ciecl/issues>
- **DEIS MINSAL**: <https://deis.minsal.cl>
- **Centro FIC Chile**: <https://deis.minsal.cl/centrofic/>
- **API CIE-11 OMS**: <https://icd.who.int/icdapi>
