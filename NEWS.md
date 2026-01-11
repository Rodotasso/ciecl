# ciecl 0.1.0 (2026-01-11)
## Tests de Comorbilidad

Validacion exhaustiva de funciones `cie_comorbid()` y `cie_map_comorbid()` con bases sinteticas:

### Bases de Prueba Generadas
* `15_comorbid_charlson.csv`: 500 pacientes, 2007 diagnosticos
  - Codigos de 17 categorias Charlson (MI, CHF, PVD, CEVD, demencia, EPOC, etc.)
  - Scores validados: rango 1-15 puntos
* `16_comorbid_elixhauser.csv`: 500 pacientes, 3219 diagnosticos
  - Codigos de 31 categorias Elixhauser
  - Categorias por paciente: 1-8
* `17_comorbid_mixto.csv`: 200 pacientes, edge cases
  - 50 pacientes con NA en diagnosticos (ignorados correctamente)
  - 50 pacientes con codigos invalidos mezclados
  - 50 pacientes con un solo codigo
  - Validacion de robustez ante datos sucios

### Resultados de Validacion
* `cie_comorbid(map="charlson")`: Calculo correcto de score_charlson
* `cie_comorbid(map="elixhauser")`: Calculo correcto de categorias booleanas
* Manejo robusto de NA y codigos vacios (warnings informativos)
* Codigos invalidos no afectan calculo de pacientes validos

### Codigos CIE-10 Testeados por Categoria
* **Infarto miocardio**: I21.0-I22.9, I25.2
* **Insuficiencia cardiaca**: I50.0-I50.9, I11.0, I13.0
* **Diabetes**: E10.0-E14.9 (sin/con complicaciones)
* **Enfermedad renal**: N18.1-N18.9, N19
* **EPOC**: J40-J44.9
* **Cancer**: C18.x, C34.x, C50.x, C61, C67.x, C71.x, C73
* **VIH/SIDA**: B20-B24

## Bug Fixes

* `cie_lookup_single()`: Corregir emisión de warning para rangos invertidos
  - Usar `paste0()` en lugar de concatenación con comas en `warning()`
  - Tests ahora suprimen warnings esperados con `suppressWarnings()`

## Mejoras

* `cie_lookup()`: Documentación mejorada del parámetro `extract`:
  - Advertencia clara de usar `extract=TRUE` solo con códigos escalares
  - Ejemplos de uso correcto con prefijos/sufijos
  - Evita confusiones con vectores múltiples

* `extract_cie_from_text()`: Función interna para extraer código CIE-10 de texto con ruido
  - Soporta prefijos: "CIE:E11.0" -> "E11.0"
  - Soporta sufijos: "E11.0-confirmado" -> "E11.0"
  - Soporta ambos: "CIE:E11.0-prov" -> "E11.0"

## Tests

* `test-cie-search.R`: Modificar test de rangos invertidos para usar `suppressWarnings()`
* `test-edge-cases.R`: Modificar test de rangos para usar `suppressWarnings()`

# ciecl 0.1.0.9000 (desarrollo - historico)

## Nuevas funcionalidades

* `cie_search()`: Soporte para **88 siglas medicas** comunes en Chile:
  - Cardiovasculares: IAM, HTA, ACV, FA, ICC, TEP, TVP
  - Respiratorias: TBC, EPOC, NAC, SDRA
  - Metabolicas: DM, DM1, DM2, ERC, IRC
  - Infecciosas: VIH, ITU, ITS
  - Oncologicas: CA, LMA, LMC, LLA, LLC
  - Neurologicas: TEC, EPI, EM, ELA
  - Y muchas mas (ver `cie_siglas()`)

* `cie_search()`: Tolerancia a tildes mejorada:
  - "neumonia" ahora encuentra "neumonía"
  - "rinon" encuentra "riñón"
  - "corazon" encuentra "corazón"

* `cie_search()`: Busqueda por subcadena como estrategia principal:
  - Mas rapido y preciso para terminos exactos
  - Fuzzy search como fallback para typos

* `cie_siglas()`: Nueva funcion para listar todas las siglas medicas soportadas

## Datos

* Dataset `cie10_cl`: Agregados 4 codigos COVID-19 de actualizaciones OMS 2021:
  - U08.9: Historia personal de COVID-19
  - U09.9: Condicion post COVID-19 (COVID prolongado)
  - U10.9: Sindrome inflamatorio multisistemico (PIMS)
  - U12.9: Efecto adverso de vacunas COVID-19 (ESAVI)
  - Total codigos: 39,877 (antes 39,873)

## Mejoras

* `cie_normalizar()`: Manejo robusto de caracteres especiales comunes en datos clinicos:
  - Espacios internos (E 11 0 -> E11.0)
  - Guiones en lugar de puntos (I10-0 -> I10.0)
  - Puntos multiples consecutivos (E..11 -> E.11)
  - Puntos iniciales (.I10 -> I10)
  - Simbolos daga y asterisco de codificacion dual (A17.0† -> A17.0, G01* -> G01)

* `cie_normalizar()`: Ahora elimina automaticamente el sufijo "X" de codigos CIE-10
  (ej. I10X -> I10, J00X -> J00). Esto permite trabajar con codigos que usan "X"
  para indicar ausencia de subcategoria adicional.

* `cie_normalizar()`: Preserva X en codigos largos (>5 chars) donde es placeholder
  obligatorio del 7o caracter de extension en trauma/lesiones (ej. S72X01A).
  Esto asegura compatibilidad con codificacion ICD-10-CM.

# ciecl 0.1.0 (BETA)

> **NOTA**: Esta es una version beta en desarrollo activo. La API puede cambiar
> antes de la version estable 1.0.0.

## Funcionalidades principales

* Sistema de busqueda SQL optimizado con SQLite persistente
* Busqueda fuzzy con algoritmo Jaro-Winkler para matching de terminos medicos
* Calculo de comorbilidades Charlson y Elixhauser adaptadas a codigos chilenos
* Integracion con API CIE-11 de la OMS
* Validacion y expansion de codigos jerarquicos CIE-10
* Tablas interactivas con paquete gt (opcional)
* Dataset completo CIE-10 Chile oficial MINSAL/DEIS v2018

## Funciones exportadas

### Busqueda y consulta
* `cie_lookup()` - Busqueda exacta por codigo (vectorizada)
* `cie_search()` - Busqueda fuzzy de terminos medicos
* `cie10_sql()` - Consultas SQL directas sobre CIE-10
* `cie11_search()` - Busqueda en API CIE-11 OMS (requiere credenciales)

### Utilidades
* `cie_expand()` - Expansion jerarquica de categorias
* `cie_validate_vector()` - Validacion formato de codigos
* `cie_normalizar()` - Normalizacion de codigos
* `cie10_clear_cache()` - Limpiar cache SQLite

### Comorbilidades (requiere paquete comorbidity)
* `cie_comorbid()` - Calculo de indices de comorbilidad
* `cie_map_comorbid()` - Mapeo de categorias de comorbilidad

### Visualizacion (requiere paquete gt)
* `cie_table()` - Tablas interactivas GT

### Generacion de datos
* `generar_cie10_cl()` - Generar dataset desde XLS/XLSX MINSAL (requiere readxl)

## Dataset incluido

* `cie10_cl` - **39,873 codigos** CIE-10 Chile oficial MINSAL/DEIS v2018
  - Incluye categorias (3 digitos) y subcategorias (4+ digitos)
  - Columnas: codigo, descripcion, categoria, inclusion, exclusion, capitulo, es_daga, es_cruz

## Estado del desarrollo

* Dataset generado y validado: 39,873 registros
* Tests unitarios: 8 archivos de tests
* R CMD check: 0 errores, 0 warnings
* Documentacion completa con roxygen2
* Vignette funcional incluida

## Notas para usuarios beta

Esta version esta siendo probada activamente. Por favor reporta cualquier
problema en: <https://github.com/RodoTasso/ciecl/issues>

## Primera release

Primera version beta del paquete ciecl para trabajar con Clasificacion
Internacional de Enfermedades CIE-10 de Chile en R.

Fuente de datos: [Centro FIC Chile DEIS](https://deis.minsal.cl/centrofic/)
