# Dataset CIE-10 Chile oficial MINSAL/DEIS v2018

Dataset CIE-10 Chile oficial MINSAL/DEIS v2018

## Usage

``` r
cie10_cl
```

## Format

tibble con 39,877 filas (categorias y subcategorias):

- codigo:

  Codigo CIE-10 (ej. "E11.0")

- descripcion:

  Diagnostico en espanol chileno

- categoria:

  Categoria jerarquica

- seccion:

  Seccion dentro del capitulo

- capitulo_nombre:

  Nombre descriptivo del capitulo

- inclusion:

  Terminos incluidos

- exclusion:

  Terminos excluidos

- capitulo:

  Capitulo CIE-10 (A-Z)

- es_daga:

  Logical, codigo daga (+)

- es_cruz:

  Logical, codigo asterisco (\*)

## Source

<https://deis.minsal.cl/centrofic/>

## Examples

``` r
data(cie10_cl)
head(cie10_cl)
#> # A tibble: 6 × 11
#>   codigo descripcion       categoria seccion capitulo_nombre inclusion exclusion
#>   <chr>  <chr>             <chr>     <chr>   <chr>           <chr>     <chr>    
#> 1 A00    Cólera            A00 CÓLE… A00-A0… Cap.01  CIERTA… NA        NA       
#> 2 A00.0  Cólera debido a … A00 CÓLE… A00-A0… Cap.01  CIERTA… NA        NA       
#> 3 A00.1  Cólera debido a … A00 CÓLE… A00-A0… Cap.01  CIERTA… NA        NA       
#> 4 A00.9  Cólera, no espec… A00 CÓLE… A00-A0… Cap.01  CIERTA… NA        NA       
#> 5 A01    Fiebres tifoidea… A01 FIEB… A00-A0… Cap.01  CIERTA… NA        NA       
#> 6 A01.0  Fiebre tifoidea   A01 FIEB… A00-A0… Cap.01  CIERTA… NA        NA       
#> # ℹ 4 more variables: capitulo <chr>, es_daga <lgl>, es_cruz <lgl>,
#> #   uso_cl <chr>
```
