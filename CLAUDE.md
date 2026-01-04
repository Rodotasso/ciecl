# Instrucciones para Claude Code

## Proyecto
Paquete R `ciecl`: CIE-10 oficial Chile (MINSAL/DEIS v2018). 39,873 códigos con búsqueda SQL, fuzzy matching, comorbilidades Charlson/Elixhauser, API CIE-11 OMS.

## Reglas Obligatorias

### Eficiencia
- Minimizar tokens y llamadas a herramientas
- Usar skills y templates de Claude Code (`/commit`, `/code-review`, etc.)
- Combinar operaciones relacionadas en una sola llamada
- Preferir ediciones precisas sobre reescrituras completas

### Git y CI/CD
- **Antes de commit/push**: Ejecutar `devtools::check()` y verificar que pase
- Verificar que GitHub Actions R-CMD-check esté verde
- **NUNCA** mencionar que el código fue generado por Claude o IA en commits, código o documentación
- Commits concisos en español, formato convencional (`fix:`, `feat:`, `docs:`)

### Código R
- Seguir tidyverse style guide
- Usar `%>%` de dplyr (ya importado)
- Variables globales NSE declarar solo en `R/globals.R`
- Conexiones DB siempre con `on.exit(DBI::dbDisconnect())`
- Dependencias opcionales: verificar con `requireNamespace()`
- Documentación roxygen2 en español

### Estructura del Paquete
```
R/
  cie-search.R   # cie_search(), cie_lookup()
  cie-sql.R      # cie10_sql(), get_cie10_db()
  cie-api.R      # cie11_search() (API OMS)
  cie-comorbid.R # cie_comorbid() (Charlson/Elixhauser)
  cie-data.R     # parsear_cie10_minsal(), dataset docs
  globals.R      # globalVariables NSE
data/
  cie10_cl.rda   # Dataset principal (39,873 códigos)
```

### Comandos Frecuentes
```r
devtools::document()      # Regenerar man/
devtools::check()         # R CMD check completo
devtools::test()          # Correr tests
devtools::load_all()      # Cargar paquete en desarrollo
```

### URLs Oficiales
- Repo: https://github.com/Rodotasso/ciecl
- DEIS: https://deis.minsal.cl
- Centro FIC: https://deis.minsal.cl/centrofic/
- API CIE-11: https://icd.who.int/icdapi

## Rutas del Sistema (Windows)
```bash
# R ejecutable
R_PATH="/c/Program Files/R/R-4.4.3/bin/Rscript.exe"

# Proyecto
PROJECT_DIR="D:/MAGISTER/01_Paquete_R/ciecl"

# Ejecutar comandos R
"$R_PATH" -e "setwd('$PROJECT_DIR'); <comando>"
```

### Ejemplos Bash
```bash
# Documentar
"/c/Program Files/R/R-4.4.3/bin/Rscript.exe" -e "setwd('D:/MAGISTER/01_Paquete_R/ciecl'); devtools::document()"

# Check
"/c/Program Files/R/R-4.4.3/bin/Rscript.exe" -e "setwd('D:/MAGISTER/01_Paquete_R/ciecl'); devtools::check(error_on = 'error')"

# Tests
"/c/Program Files/R/R-4.4.3/bin/Rscript.exe" -e "setwd('D:/MAGISTER/01_Paquete_R/ciecl'); devtools::test()"

# Load all
"/c/Program Files/R/R-4.4.3/bin/Rscript.exe" -e "setwd('D:/MAGISTER/01_Paquete_R/ciecl'); devtools::load_all()"
```

## Contexto Técnico
- Dataset: SQLite cache en `tools::R_user_dir("ciecl", "data")`
- Fuzzy: Jaro-Winkler via `stringdist`
- Solo SELECT queries permitidas (seguridad SQL)
- Encoding: UTF-8, sin tildes en código fuente (usar `\uXXXX`)
