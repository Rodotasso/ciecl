# Dependencias del Paquete ciecl

## ¿Por qué tantas dependencias?

El paquete `ciecl` ha sido **reorganizado** para minimizar las dependencias obligatorias.

## Dependencias OBLIGATORIAS (Imports)

Estas se instalan automáticamente con el paquete:

| Paquete | Uso | ¿Por qué es necesario? |
|---------|-----|------------------------|
| **DBI** | Interfaz base de datos | Abstracción para SQLite |
| **RSQLite** | Motor SQLite | Almacenar y consultar ~9,000 códigos CIE-10 |
| **stringdist** | Fuzzy matching | Búsqueda con errores tipográficos (Jaro-Winkler) |
| **stringr** | Manipulación texto | Normalizar códigos, limpiar strings |
| **dplyr** | Manipulación datos | Transformar y filtrar tibbles |
| **tibble** | Data frames modernos | Formato de salida consistente |
| **tools** | Utilidades R | Gestión de directorios de usuario |
| **utils** | Utilidades base | Funciones básicas de R |

**Total: 8 paquetes** (mínimo necesario para funcionalidad core)

## Dependencias OPCIONALES (Suggests)

Solo se necesitan si usas funciones específicas:

| Paquete | Funciones que lo requieren | ¿Cómo instalar? |
|---------|----------------------------|-----------------|
| **comorbidity** | `cie_comorbid()`, `cie_map_comorbid()` | `install.packages("comorbidity")` |
| **gt** | `cie_table()` | `install.packages("gt")` |
| **httr2** | `cie11_search()` | `install.packages("httr2")` |
| **readxl** | `generar_cie10_cl()` | `install.packages("readxl")` |
| **usethis** | `generar_cie10_cl()` | `install.packages("usethis")` |
| **magrittr** | Operador pipe `%>%` | `install.packages("magrittr")` |
| **testthat** | Pruebas unitarias | Solo para desarrollo |
| **knitr, rmarkdown** | Vignettes | Solo para documentación |

## ¿Qué funciones NO necesitan paquetes opcionales?

### ✅ Funcionalidad CORE (sin dependencias extra):

```r
library(ciecl)

# Búsqueda exacta por código
cie_lookup("E11.0")
cie_lookup(c("E11.0", "I10", "Z00"))

# Búsqueda fuzzy (con typos)
cie_search("diabetis mellitus")

# Normalización de códigos
cie_normalizar(c("E11.0", "I10.0"))

# Validación de formato
cie_validate_vector(c("E11.0", "INVALIDO"))

# Expansión jerárquica
cie_expand("E11")

# Consultas SQL directas
cie10_sql("SELECT * FROM cie10 WHERE codigo LIKE 'E11%'")
```

**Estas funciones cubren el 80% de los casos de uso y solo requieren 8 paquetes.**

## ¿Por qué se sugería 'icd' y 'covr'?

- **`icd`**: No existe en CRAN. Era un remanente de código antiguo. **YA ELIMINADO**.
- **`covr`**: Para medir cobertura de tests en CI/CD. No es necesario para usuarios. **YA ELIMINADO**.

## Comparación con otros paquetes similares

| Paquete | Dependencias Imports | Dependencias Total |
|---------|---------------------|-------------------|
| **ciecl (optimizado)** | 8 | 16 |
| Paquetes típicos de R | 10-15 | 20-30 |
| Tidyverse completo | 30+ | 80+ |

## ¿Puede el paquete funcionar por sí mismo?

**SÍ**, con limitaciones:

1. **Instalación básica** (solo Imports):
   ```r
   install.packages("ciecl")
   ```
   - ✅ Búsqueda de códigos
   - ✅ Fuzzy search
   - ✅ Consultas SQL
   - ✅ Validación
   - ❌ Comorbilidades
   - ❌ Tablas GT
   - ❌ API CIE-11

2. **Instalación completa** (con Suggests):
   ```r
   install.packages("ciecl", dependencies = TRUE)
   ```
   - ✅ Todas las funcionalidades

## Recomendación

Si solo necesitas búsqueda de códigos CIE-10, instala solo el paquete base:

```r
install.packages("ciecl")
```

Si necesitas análisis avanzado (comorbilidades, tablas bonitas), instala con dependencias:

```r
install.packages("ciecl", dependencies = TRUE)
```

O instala solo lo que necesites:
```r
install.packages(c("ciecl", "comorbidity"))  # Solo para comorbilidades
```

## Conclusión

El paquete ahora es **mucho más ligero**:
- **Antes**: 14 imports (obligatorias)
- **Ahora**: 8 imports (obligatorias)
- **Reducción**: 43% menos dependencias obligatorias

Las funciones core funcionan sin paquetes adicionales, y solo pides lo opcional cuando realmente lo necesitas.
