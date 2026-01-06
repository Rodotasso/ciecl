# ciecl 0.1.0.9000 (desarrollo)

## Mejoras

* `cie_normalizar()`: Ahora elimina automaticamente el sufijo "X" de codigos CIE-10
  (ej. I10X -> I10, J00X -> J00). Esto permite trabajar con codigos que usan "X"
  para indicar ausencia de subcategoria adicional (#nueva-funcionalidad).

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
