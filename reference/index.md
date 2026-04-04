# Package index

## Busqueda de codigos

Funciones para buscar codigos CIE-10 por texto o codigo

- [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
  : Busqueda difusa (fuzzy) de terminos medicos CIE-10
- [`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
  : Busqueda exacta por codigo CIE-10
- [`cie_siglas()`](https://rodotasso.github.io/ciecl/reference/cie_siglas.md)
  : Listar siglas medicas soportadas
- [`cie_guia_busqueda()`](https://rodotasso.github.io/ciecl/reference/cie_guia_busqueda.md)
  : Guia de funciones de busqueda CIE-10

## Base de datos SQL

Acceso directo a la base SQLite CIE-10

- [`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md)
  : Ejecutar consultas SQL sobre CIE-10 Chile
- [`cie10_clear_cache()`](https://rodotasso.github.io/ciecl/reference/cie10_clear_cache.md)
  : Limpiar cache SQLite (forzar rebuild)
- [`cie10_disconnect()`](https://rodotasso.github.io/ciecl/reference/cie10_disconnect.md)
  : Cerrar conexion pooled SQLite

## Comorbilidades

Indices de comorbilidad Charlson y Elixhauser

- [`cie_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_comorbid.md)
  : Calcular comorbilidades Charlson/Elixhauser para Chile
- [`cie_map_comorbid()`](https://rodotasso.github.io/ciecl/reference/cie_map_comorbid.md)
  : Mapeo manual grupos comorbilidad Chile-especifico

## Validacion y utilidades

Normalizacion, validacion y expansion de codigos

- [`cie_normalizar()`](https://rodotasso.github.io/ciecl/reference/cie_normalizar.md)
  : Normalizar codigos CIE-10 a formato con punto
- [`cie_validate_vector()`](https://rodotasso.github.io/ciecl/reference/cie_validate_vector.md)
  : Validar vector de codigos CIE-10 formato
- [`cie_expand()`](https://rodotasso.github.io/ciecl/reference/cie_expand.md)
  : Expandir codigo jerarquico (ej. E11 -\> E11.0-E11.9)

## API CIE-11

Busqueda en la clasificacion CIE-11 via API OMS

- [`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)
  : Buscar codigos CIE-11 via API OMS

## Visualizacion

Tablas interactivas para exploracion de codigos

- [`cie_table()`](https://rodotasso.github.io/ciecl/reference/cie_table.md)
  : Generar tabla HTML interactiva GT de codigo CIE-10

## Datos

Dataset CIE-10 Chile oficial MINSAL/DEIS

- [`cie10_cl`](https://rodotasso.github.io/ciecl/reference/cie10_cl.md)
  : Dataset CIE-10 Chile oficial MINSAL/DEIS v2018
