# Caso de uso: Egresos hospitalarios con ciecl

Los registros de egresos hospitalarios en Chile (fuente DEIS) almacenan
diagnosticos en formato CIE-10 sin punto (`J189`, `O800`) y en algunos
casos con sufijo `X` (`I10X`, `N40X`) para indicar categorias sin
subcategoria adicional. Esta convencion de codificacion dificulta unir
los datos con catalogos externos que usan el formato normalizado con
punto (`J18.9`, `O80.0`).

Esta vignette reproduce el flujo utilizado en investigacion con datos
DEIS: obtener descripciones CIE-10 para toda la base, unirlas con los
registros originales, y generar perfiles de diagnostico.

## Datos de ejemplo

Simulamos una base con la estructura tipica de los egresos hospitalarios
DEIS. Las columnas `DIAG1` y `ANO` imitan el formato original:

``` r
set.seed(42)

egresos <- data.frame(
  ID_EGRESO = 1:200,
  ANO       = sample(2018:2022, 200, replace = TRUE),
  DIAG1     = sample(
    c(
      # Codigos frecuentes en egresos DEIS (sin punto, formato original)
      "J189", "O800", "Z380", "K359", "N390",
      "I10X", "J449", "E119", "O829", "J069",
      "K922", "N185", "I509", "C509", "A099",
      # Algunos con sufijo X (convencion DEIS)
      "N40X", "K800", "I259", "J180", "E149"
    ),
    size    = 200,
    replace = TRUE,
    prob    = c(
      0.12, 0.10, 0.09, 0.07, 0.06,
      0.08, 0.06, 0.07, 0.05, 0.04,
      0.04, 0.03, 0.05, 0.03, 0.03,
      0.03, 0.03, 0.04, 0.03, 0.05
    )
  ),
  stringsAsFactors = FALSE
)

cat("Registros totales:", nrow(egresos), "\n")
#> Registros totales: 200
cat("Codigos unicos:", length(unique(egresos$DIAG1)), "\n")
#> Codigos unicos: 20
cat("Periodo:", min(egresos$ANO), "-", max(egresos$ANO), "\n\n")
#> Periodo: 2018 - 2022
head(egresos)
#>   ID_EGRESO  ANO DIAG1
#> 1         1 2018  I10X
#> 2         2 2022  I10X
#> 3         3 2018  J189
#> 4         4 2018  N40X
#> 5         5 2019  J449
#> 6         6 2021  J189
```

## 1. Obtener descripciones CIE-10

Filtramos registros validos y usamos
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
con `normalizar = TRUE` para procesar todos los codigos unicos en una
sola llamada vectorizada. El argumento `normalizar = TRUE` acepta los
codigos tal como vienen del sistema: sin punto, con sufijo `X`, en
cualquier capitalizacion.

``` r
# Filtrar registros validos (sin NA en diagnostico)
datos_filtrados <- egresos %>%
  filter(!is.na(DIAG1))

# Codigos unicos a procesar
codigos_unicos <- unique(datos_filtrados$DIAG1)
cat("Codigos unicos a procesar:", length(codigos_unicos), "\n")
#> Codigos unicos a procesar: 20

# Busqueda vectorizada con cie_lookup
inicio <- Sys.time()

resultado_ciecl <- cie_lookup(
  codigo             = codigos_unicos,
  normalizar         = TRUE,
  descripcion_completa = TRUE
)

tiempo <- round(as.numeric(difftime(Sys.time(), inicio, units = "secs")), 2)

cat("Codigos encontrados:", nrow(resultado_ciecl), "de", length(codigos_unicos), "\n")
#> Codigos encontrados: 19 de 20
cat("Tiempo de busqueda:", tiempo, "segundos\n")
#> Tiempo de busqueda: 0.04 segundos
cat("Tasa de exito:", round(nrow(resultado_ciecl) / length(codigos_unicos) * 100, 1), "%\n\n")
#> Tasa de exito: 95 %

# Muestra de resultados
head(resultado_ciecl[, c("codigo", "descripcion")], 5)
#> # A tibble: 5 × 2
#>   codigo descripcion                                                    
#>   <chr>  <chr>                                                          
#> 1 A09.9  Gastroenteritis y colitis de origen no especificado            
#> 2 C50.9  Tumor maligno de la mama, parte no especificada                
#> 3 E11.9  Diabetes mellitus tipo 2 sin complicaciones                    
#> 4 E14.9  Diabetes mellitus, no especificada, sin mención de complicación
#> 5 I10    Hipertensión esencial (primaria)
```

## 2. Unir descripciones con la base de egresos

Los codigos en la base DEIS no tienen punto (`J189`), pero
[`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md)
devuelve los codigos en formato normalizado (`J18.9`). Para el join es
necesario quitar el punto y ademas eliminar el sufijo `X` que algunos
codigos tienen en la base original:

``` r
# Tabla de lookup: codigo sin punto -> descripcion completa
# cie_lookup() devuelve con punto (J18.9), la BBDD tiene sin punto (J189)
tabla_lookup <- resultado_ciecl %>%
  mutate(
    codigo_sin_punto = gsub("\\.", "", codigo),
    DIAG_COMPLETO    = paste0(codigo, " - ", descripcion)
  ) %>%
  select(codigo_sin_punto, DIAG_COMPLETO)

# Funcion para normalizar el codigo de la BBDD antes del join:
# 1. Quitar puntos si los hubiera
# 2. Quitar sufijo X final (I10X -> I10, N40X -> N40)
normalizar_codigo_bbdd <- function(codigo) {
  codigo <- gsub("\\.", "", codigo)
  codigo <- gsub("X$", "", codigo)
  return(codigo)
}

# Unir con los datos originales
datos_con_desc <- datos_filtrados %>%
  mutate(codigo_busqueda = normalizar_codigo_bbdd(DIAG1)) %>%
  left_join(tabla_lookup, by = c("codigo_busqueda" = "codigo_sin_punto")) %>%
  mutate(
    DIAG_COMPLETO = if_else(is.na(DIAG_COMPLETO), DIAG1, DIAG_COMPLETO)
  ) %>%
  select(-codigo_busqueda)

# Verificar resultado
n_con_desc <- sum(grepl(" - ", datos_con_desc$DIAG_COMPLETO), na.rm = TRUE)
pct_exito  <- round(n_con_desc / nrow(datos_con_desc) * 100, 1)

cat("Registros con descripcion CIE-10:", n_con_desc, "de", nrow(datos_con_desc), "\n")
#> Registros con descripcion CIE-10: 184 de 200
cat("Tasa de exito:", pct_exito, "%\n\n")
#> Tasa de exito: 92 %

# Ejemplos de diagnosticos procesados
datos_con_desc %>%
  select(DIAG1, DIAG_COMPLETO) %>%
  distinct() %>%
  head(10)
#>    DIAG1
#> 1   I10X
#> 2   J189
#> 3   N40X
#> 4   J449
#> 5   Z380
#> 6   J180
#> 7   E149
#> 8   N185
#> 9   E119
#> 10  K359
#>                                                              DIAG_COMPLETO
#> 1                                   I10 - Hipertensión esencial (primaria)
#> 2                                        J18.9 - Neumonía, no especificada
#> 3                                         N40 - Hiperplasia de la próstata
#> 4         J44.9 - Enfermedad pulmonar obstructiva crónica, no especificada
#> 5                               Z38.0 - Producto único, nacido en hospital
#> 6                                  J18.0 - Bronconeumonía, no especificada
#> 7  E14.9 - Diabetes mellitus, no especificada, sin mención de complicación
#> 8                              N18.5 - Enfermedad renal crónica, estadio 5
#> 9                      E11.9 - Diabetes mellitus tipo 2 sin complicaciones
#> 10                                                                    K359
```

## 3. Perfil de diagnosticos

Con las descripciones incorporadas calculamos la distribucion de
diagnosticos y la proporcion que representa cada uno sobre el total de
egresos:

``` r
perfil_diag <- datos_con_desc %>%
  filter(grepl(" - ", DIAG_COMPLETO)) %>%
  count(DIAG_COMPLETO, sort = TRUE) %>%
  mutate(
    pct       = round(n / sum(n) * 100, 1),
    pct_acum  = cumsum(pct)
  )

cat("Top 10 diagnosticos:\n\n")
#> Top 10 diagnosticos:
head(perfil_diag, 10)
#>                                                              DIAG_COMPLETO  n
#> 1                                        J18.9 - Neumonía, no especificada 29
#> 2         O80.0 - Parto único espontáneo, presentación cefálica de vértice 19
#> 3                      E11.9 - Diabetes mellitus tipo 2 sin complicaciones 14
#> 4         J44.9 - Enfermedad pulmonar obstructiva crónica, no especificada 14
#> 5                                   I10 - Hipertensión esencial (primaria) 13
#> 6                               Z38.0 - Producto único, nacido en hospital 13
#> 7               N39.0 - Infección de vías urinarias, sitio no especificado 11
#> 8  E14.9 - Diabetes mellitus, no especificada, sin mención de complicación 10
#> 9                              N18.5 - Enfermedad renal crónica, estadio 5  9
#> 10       I25.9 - Enfermedad isquémica crónica del corazón, no especificada  8
#>     pct pct_acum
#> 1  15.8     15.8
#> 2  10.3     26.1
#> 3   7.6     33.7
#> 4   7.6     41.3
#> 5   7.1     48.4
#> 6   7.1     55.5
#> 7   6.0     61.5
#> 8   5.4     66.9
#> 9   4.9     71.8
#> 10  4.3     76.1
```

``` r
top10_pct <- sum(head(perfil_diag, 10)$pct)
cat("Los 10 diagnosticos mas frecuentes representan el", top10_pct, "% del total de egresos\n")
#> Los 10 diagnosticos mas frecuentes representan el 76.1 % del total de egresos
```

## 4. Busqueda por texto

Cuando no se conoce el codigo exacto,
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
encuentra diagnosticos por descripcion textual con tolerancia a errores
tipograficos:

``` r
# Terminos clinicos comunes en egresos (con y sin typos)
terminos <- c("neumonia", "diabetis", "hipertension")

for (termino in terminos) {
  cat("Buscando:", termino, "\n")
  res <- cie_search(termino, threshold = 0.70, max_results = 3)
  if (nrow(res) > 0) {
    print(res[, c("codigo", "descripcion")])
  }
  cat("\n")
}
#> Buscando: neumonia 
#> # A tibble: 3 × 2
#>   codigo descripcion                                                          
#>   <chr>  <chr>                                                                
#> 1 B01.2  Neumonía debida a varicela (J17.1*)                                  
#> 2 B05.2  Sarampión complicado con neumonía (J17.1*)                           
#> 3 B20.6  Enfermedad por VIH, resultante en neumonía por Pneumocystis jirovecii
#> 
#> Buscando: diabetis 
#> # A tibble: 3 × 2
#>   codigo descripcion                              
#>   <chr>  <chr>                                    
#> 1 E10    Diabetes mellitus insulinodependiente    
#> 2 E10.0  Diabetes mellitus tipo 1 con coma        
#> 3 E10.1  Diabetes mellitus tipo 1 con cetoacidosis
#> 
#> Buscando: hipertension 
#> # A tibble: 3 × 2
#>   codigo descripcion                      
#>   <chr>  <chr>                            
#> 1 G93.2  Hipertensión intracraneal benigna
#> 2 I10    Hipertensión esencial (primaria) 
#> 3 I15    Hipertensión secundaria
```

## 5. Validacion de codigos

Antes de procesar una base conviene identificar codigos que no
corresponden a ningun diagnostico valido en el catalogo CIE-10:

``` r
validos <- cie_validate_vector(codigos_unicos)

cat("Codigos validos:  ", sum(validos), "\n")
#> Codigos validos:   20
cat("Codigos invalidos:", sum(!validos), "\n")
#> Codigos invalidos: 0

if (any(!validos)) {
  cat("\nCodigos no reconocidos:\n")
  print(codigos_unicos[!validos])
}
```

## Fuente de datos

- Catalogo CIE-10 Chile: Centro FIC DEIS
  <https://deis.minsal.cl/centrofic/>
- Repositorio: <https://github.com/RodoTasso/ciecl>
