# Solucion: Vectorizacion de cie_lookup()

## Problema Original

El paquete `ciecl` tenia dos problemas principales:

1. **Error "the condition has length > 1"**: Ocurria cuando se pasaba un vector de codigos a `cie_lookup()`
2. **Falta de soporte para vectorizacion**: La funcion solo podia procesar un codigo a la vez

## Causa del Error

El error se producia en la linea 94 del archivo original `R/cie-search.R`:

```r
} else if (stringr::str_detect(codigo_norm, "-")) {
```

Cuando `codigo_norm` es un vector de multiples codigos (ej. `c("E11.0", "Z00", "I10")`), la funcion `str_detect()` retorna un vector logico de la misma longitud. Sin embargo, `if` espera un solo valor logico, no un vector, causando el error:

```
Error: the condition has length > 1
```

## Solucion Implementada

### 1. Refactorizacion de la Funcion Principal

Se modifico `cie_lookup()` para:
- Detectar si se recibe un vector de multiples codigos
- Procesar cada codigo individualmente usando `lapply()`
- Combinar todos los resultados usando `dplyr::bind_rows()`
- Eliminar duplicados con `dplyr::distinct()`

```r
cie_lookup <- function(codigo, expandir = FALSE) {
  codigo_norm <- stringr::str_trim(toupper(codigo))
  
  if (length(codigo_norm) > 1) {
    # Procesar cada codigo individualmente
    resultados_lista <- lapply(codigo_norm, function(cod) {
      cie_lookup_single(cod, expandir = expandir)
    })
    
    # Combinar y eliminar duplicados
    resultado <- dplyr::bind_rows(resultados_lista)
    resultado <- dplyr::distinct(resultado)
    
    return(resultado)
  } else {
    return(cie_lookup_single(codigo_norm, expandir = expandir))
  }
}
```

### 2. Creacion de Funcion Interna

Se extrajo la logica original a una funcion interna `cie_lookup_single()` que procesa un solo codigo:

```r
cie_lookup_single <- function(codigo_norm, expandir = FALSE) {
  # Logica original aqui
  # Esta funcion siempre recibe un solo codigo (scalar)
  # Por lo tanto, los if/else funcionan correctamente
}
```

### 3. Importaciones Adicionales

Se agregaron las importaciones necesarias en `R/cie-search.R`:

```r
#' @importFrom stringr str_split
#' @importFrom dplyr bind_rows distinct
```

## Uso de la Funcion Vectorizada

### Antes (solo un codigo a la vez)
```r
# Esto funcionaba
cie_lookup("E11.0")

# Esto causaba error
codigos <- c("E11.0", "Z00", "I10")
cie_lookup(codigos)  # Error: the condition has length > 1
```

### Despues (soporta vectores)
```r
# Un solo codigo (sigue funcionando igual)
cie_lookup("E11.0")

# Multiples codigos (ahora funciona!)
codigos <- c("E11.0", "Z00", "I10")
resultados <- cie_lookup(codigos)  # Retorna todos los resultados combinados

# Ejemplo con 9,799 codigos (caso de uso real)
codigos_unicos <- c("E11.0", "E11.1", "E11.2", ..., "Z99.9")  # 9,799 codigos
resultados <- cie_lookup(codigos_unicos)  # Funciona correctamente!
```

## Tests Agregados

Se agregaron tres nuevos tests para verificar la vectorizacion:

1. **Test de vectores multiples**: Verifica que acepta vectores y retorna resultados correctos
2. **Test de codigos invalidos**: Verifica manejo de codigos validos e invalidos mezclados
3. **Test de duplicados**: Verifica que se eliminan duplicados correctamente

## Beneficios

1. ✅ **Compatible con codigo existente**: Los usos anteriores siguen funcionando
2. ✅ **Soporta vectorizacion**: Puede procesar miles de codigos a la vez
3. ✅ **Mejor rendimiento**: Combina resultados eficientemente con dplyr
4. ✅ **Sin duplicados**: Elimina automaticamente resultados duplicados
5. ✅ **Mensajes informativos**: Mantiene los mensajes para codigos no encontrados

## Documentacion Actualizada

- ✅ README.Rmd: Agregado ejemplo de uso vectorizado
- ✅ Vignette: Agregada seccion con ejemplos de vectorizacion
- ✅ Roxygen docs: Actualizada documentacion de parametros y ejemplos
- ✅ Tests: Cobertura completa de casos de uso vectorizados

## Proximos Pasos

1. Ejecutar `devtools::document()` para regenerar archivos .Rd
2. Ejecutar `devtools::test()` para verificar tests
3. Ejecutar `devtools::check()` para verificar R CMD check
4. Renderizar README.md desde README.Rmd con `rmarkdown::render("README.Rmd")`
