# ciecl 0.1.0

## Funcionalidades principales

* Sistema de busqueda SQL optimizado con SQLite persistente
* Busqueda fuzzy con algoritmo Jaro-Winkler para matching de terminos medicos
* Calculo de comorbilidades Charlson y Elixhauser adaptadas a codigos chilenos
* Integracion con API CIE-11 de la OMS
* Validacion y expansion de codigos jerarquicos CIE-10
* Tablas interactivas con paquete gt
* Dataset completo CIE-10 Chile oficial MINSAL/DEIS v2018

## Funciones exportadas

* `generar_cie10_cl()` - Generar dataset desde XLS MINSAL
* `cie10_sql()` - Consultas SQL sobre CIE-10
* `cie10_clear_cache()` - Limpiar cache SQLite
* `cie_search()` - Busqueda fuzzy de terminos medicos
* `cie_lookup()` - Busqueda exacta por codigo
* `cie_comorbid()` - Calculo comorbilidades
* `cie_map_comorbid()` - Mapeo categorias comorbilidad
* `cie11_search()` - Busqueda API CIE-11 OMS
* `cie_table()` - Tablas interactivas GT
* `cie_validate_vector()` - Validacion formato codigos
* `cie_expand()` - Expansion jerarquica

## Dataset incluido

* `cie10_cl` - ~10,000 codigos CIE-10 Chile oficial MINSAL/DEIS v2018

## Primera release

Primera version del paquete ciecl para trabajar con Clasificacion Internacional
de Enfermedades CIE-10 de Chile en R.
