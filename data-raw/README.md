# data-raw/

Este directorio contiene los scripts necesarios para regenerar el dataset oficial del paquete (`data/cie10_cl.rda`) a partir de las fuentes originales del DEIS (MINSAL Chile).

## Contenido

- `generate_cie10_cl.R`: Funciones para parsear el XLS/XLSX y guardar el `.rda`.
- `DATASET.R`: Script de entrada estándar (usado por `usethis::use_data_raw()`).
- `test_generate_cie10_cl.R`: Sanity-check para validar el proceso de parseo sin depender de la suite de tests del paquete.

## Cómo regenerar el dataset

1. Asegúrate de tener el archivo `CIE-10 (1).xlsx` (o similar) en la raíz del proyecto o en el directorio superior.
2. Ejecuta el script de generación:
   ```r
   source("data-raw/DATASET.R")
   ```
3. Esto actualizará el archivo `data/cie10_cl.rda`.

## Verificación

Para verificar que el generador funciona correctamente tras cambios en la lógica de parseo, ejecuta:
```bash
Rscript data-raw/test_generate_cie10_cl.R
```
