# Language support and internationalization

## Supported languages

The `ciecl` package works primarily in Chilean Spanish, but offers
multilingual search when the data source allows it. The table summarizes
the behavior by function.

| Function | Dataset language | Search language | Notes |
|----|----|----|----|
| [`cie_lookup()`](https://rodotasso.github.io/ciecl/reference/cie_lookup.md) | Spanish (Chile) | — | Search by code; language not applicable |
| [`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md) | Spanish (Chile) | Spanish | Descriptions in Chilean Spanish |
| [`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md) | Spanish / English | Spanish / English | Configurable via the `lang` parameter |
| [`cie10_sql()`](https://rodotasso.github.io/ciecl/reference/cie10_sql.md) | Spanish (Chile) | SQL | `descripcion` column in Spanish |

## The Chilean ICD-10 dataset

The `cie10_cl` dataset contains the codes currently in force with
descriptions in Chilean Spanish according to the official MINSAL/DEIS
catalog v2018. See
[`?cie10_cl`](https://rodotasso.github.io/ciecl/reference/cie10_cl.md)
for column details.

``` r

library(ciecl)

head(cie10_cl[, c("codigo", "descripcion", "capitulo")])
#> # A tibble: 6 × 3
#>   codigo descripcion                                          capitulo
#>   <chr>  <chr>                                                <chr>   
#> 1 A00    Cólera                                               A00     
#> 2 A00.0  Cólera debido a Vibrio cholerae O1, biotipo cholerae A00     
#> 3 A00.1  Cólera debido a Vibrio cholerae O1, biotipo El Tor   A00     
#> 4 A00.9  Cólera, no especificado                              A00     
#> 5 A01    Fiebres tifoidea y paratifoidea                      A01     
#> 6 A01.0  Fiebre tifoidea                                      A01
```

The `descripcion` column preserves the accents and ñ’s of the original
catalog. This matters because many cleaning routines strip accents; in
`ciecl` normalization happens only at the *search* stage, not in the
stored data.

### Features of Chilean Spanish

- **Accents preserved in the dataset**: “Neumonía”, “Riñón”, “Corazón”.
- **Local terminology**: uses medical terms common in Chile.
- **No anglicisms**: official MINSAL translations.

## Accent- and ñ-tolerant search

[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
internally normalizes the query so users can type with or without
accents. This is especially useful in mixed clinical data, where the
same term appears with and without an accent.

``` r

# With or without accent: same result
cie_search("neumonia")
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 B01.2  Neumonía debida a varicela (J17.1*)                        1 B01 VARI…
#>  2 B05.2  Sarampión complicado con neumonía (J17.1*)                 1 B05 SARA…
#>  3 B20.6  Enfermedad por VIH, resultante en neumonía por Pneumo…     1 B20 ENFE…
#>  4 J10.0  Influenza con neumonía, debida a otro virus de la inf…     1 J10 INFL…
#>  5 J11.0  Influenza con neumonía, virus no identificado              1 J11 INFL…
#>  6 J12    Neumonía viral, no clasificada en otra parte               1 J12 NEUM…
#>  7 J12.0  Neumonía debida a adenovirus                               1 J12 NEUM…
#>  8 J12.1  Neumonía debida a virus sincitial respiratorio             1 J12 NEUM…
#>  9 J12.2  Neumonía debida a virus parainfluenza                      1 J12 NEUM…
#> 10 J12.3  Neumonía por metapneumovirus humano                        1 J12 NEUM…
#> # ℹ 40 more rows
cie_search("neumonía")
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 B01.2  Neumonía debida a varicela (J17.1*)                        1 B01 VARI…
#>  2 B05.2  Sarampión complicado con neumonía (J17.1*)                 1 B05 SARA…
#>  3 B20.6  Enfermedad por VIH, resultante en neumonía por Pneumo…     1 B20 ENFE…
#>  4 J10.0  Influenza con neumonía, debida a otro virus de la inf…     1 J10 INFL…
#>  5 J11.0  Influenza con neumonía, virus no identificado              1 J11 INFL…
#>  6 J12    Neumonía viral, no clasificada en otra parte               1 J12 NEUM…
#>  7 J12.0  Neumonía debida a adenovirus                               1 J12 NEUM…
#>  8 J12.1  Neumonía debida a virus sincitial respiratorio             1 J12 NEUM…
#>  9 J12.2  Neumonía debida a virus parainfluenza                      1 J12 NEUM…
#> 10 J12.3  Neumonía por metapneumovirus humano                        1 J12 NEUM…
#> # ℹ 40 more rows
cie_search("NEUMONIA")
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 B01.2  Neumonía debida a varicela (J17.1*)                        1 B01 VARI…
#>  2 B05.2  Sarampión complicado con neumonía (J17.1*)                 1 B05 SARA…
#>  3 B20.6  Enfermedad por VIH, resultante en neumonía por Pneumo…     1 B20 ENFE…
#>  4 J10.0  Influenza con neumonía, debida a otro virus de la inf…     1 J10 INFL…
#>  5 J11.0  Influenza con neumonía, virus no identificado              1 J11 INFL…
#>  6 J12    Neumonía viral, no clasificada en otra parte               1 J12 NEUM…
#>  7 J12.0  Neumonía debida a adenovirus                               1 J12 NEUM…
#>  8 J12.1  Neumonía debida a virus sincitial respiratorio             1 J12 NEUM…
#>  9 J12.2  Neumonía debida a virus parainfluenza                      1 J12 NEUM…
#> 10 J12.3  Neumonía por metapneumovirus humano                        1 J12 NEUM…
#> # ℹ 40 more rows
```

The same logic applies to the ñ: searching `"rinon"` finds “Riñón” in
the catalog.

``` r

cie_search("rinon")
#> # A tibble: 49 × 4
#>    codigo  descripcion                                           score categoria
#>    <chr>   <chr>                                                 <dbl> <chr>    
#>  1 C64     Tumor maligno del riñón, excepto de la pelvis renal       1 C64 TUMO…
#>  2 C79.0   Tumor maligno secundario del riñón y de la pelvis re…     1 C79 TUMO…
#>  3 D30.0   Tumor benigno del riñón                                   1 D30 TUMO…
#>  4 D41.0   Tumor de comportamiento incierto o desconocido del r…     1 D41 TUMO…
#>  5 M8964/3 Sarcoma de células claras del riñón (C64)                 1 M893-M89…
#>  6 M8964/6 Sarcoma de células claras del riñón (C64), metastási…     1 M893-M89…
#>  7 M9044/3 Sarcoma de células claras (excepto del riñón M8964/3)     1 M904-M90…
#>  8 M9044/6 Sarcoma de células claras (excepto del riñón M8964/3…     1 M904-M90…
#>  9 N13.2   Hidronefrosis con obstrucción por cálculos del riñón…     1 N13 UROP…
#> 10 N20     Cálculo del riñón y del uréter                            1 N20 CÁLC…
#> # ℹ 39 more rows
```

## Chilean medical abbreviations

The package includes a dictionary of **medical abbreviations** in
clinical use in Chile. This allows an analyst to type `IAM` instead of
the full term and `ciecl` resolves the abbreviation to the official
catalog term.

``` r

# List all available abbreviations
head(cie_short())
#> # A tibble: 6 × 3
#>   sigla   termino_busqueda         categoria     
#>   <chr>   <chr>                    <chr>         
#> 1 iam     infarto agudo miocardio  cardiovascular
#> 2 iamcest infarto agudo miocardio  cardiovascular
#> 3 iamsest infarto agudo miocardio  cardiovascular
#> 4 sca     sindrome coronario agudo cardiovascular
#> 5 hta     hipertension arterial    cardiovascular
#> 6 aha     hipertension arterial    cardiovascular

# Filter by category
cie_short(category = "cardiovascular")
#> # A tibble: 15 × 3
#>    sigla   termino_busqueda              categoria     
#>    <chr>   <chr>                         <chr>         
#>  1 iam     infarto agudo miocardio       cardiovascular
#>  2 iamcest infarto agudo miocardio       cardiovascular
#>  3 iamsest infarto agudo miocardio       cardiovascular
#>  4 sca     sindrome coronario agudo      cardiovascular
#>  5 hta     hipertension arterial         cardiovascular
#>  6 aha     hipertension arterial         cardiovascular
#>  7 icc     insuficiencia cardiaca        cardiovascular
#>  8 ic      insuficiencia cardiaca        cardiovascular
#>  9 fa      fibrilacion auricular         cardiovascular
#> 10 tep     embolia pulmonar              cardiovascular
#> 11 tvp     trombosis venosa profunda     cardiovascular
#> 12 eap     edema agudo pulmon            cardiovascular
#> 13 acv     accidente cerebrovascular     cardiovascular
#> 14 ave     accidente vascular encefalico cardiovascular
#> 15 ait     isquemico transitorio         cardiovascular

# Use the abbreviation directly in a search
cie_search("IAM")   # Acute Myocardial Infarction
#> ℹ Sigla detectada: "IAM" -> "infarto agudo
#> miocardio"
#> # A tibble: 50 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 I21    Infarto agudo del miocardio                                1 I21 INFA…
#>  2 I21.0  Infarto transmural agudo del miocardio de la pared an…     1 I21 INFA…
#>  3 I21.1  Infarto transmural agudo del miocardio de la pared in…     1 I21 INFA…
#>  4 I21.2  Infarto agudo transmural del miocardio de otros sitios     1 I21 INFA…
#>  5 I21.3  Infarto transmural agudo del miocardio, de sitio no e…     1 I21 INFA…
#>  6 I21.4  Infarto subendocárdico agudo del miocardio                 1 I21 INFA…
#>  7 I21.9  Infarto agudo del miocardio, sin otra especificación       1 I21 INFA…
#>  8 I23    Ciertas complicaciones presentes posteriores al infar…     1 I23 CIER…
#>  9 I23.0  Hemopericardio como complicación presente posterior a…     1 I23 CIER…
#> 10 I23.3  Ruptura de la pared cardíaca sin hemopericardio como …     1 I23 CIER…
#> # ℹ 40 more rows
cie_search("EPOC")  # Chronic Obstructive Pulmonary Disease
#> ℹ Sigla detectada: "EPOC" -> "enfermedad pulmonar
#> obstructiva cronica"
#> # A tibble: 3 × 4
#>   codigo descripcion                                             score categoria
#>   <chr>  <chr>                                                   <dbl> <chr>    
#> 1 J44.0  Enfermedad pulmonar obstructiva crónica con infección …     1 J44 OTRA…
#> 2 J44.1  Enfermedad pulmonar obstructiva crónica con exacerbaci…     1 J44 OTRA…
#> 3 J44.9  Enfermedad pulmonar obstructiva crónica, no especifica…     1 J44 OTRA…
cie_search("DM2")   # Type 2 Diabetes Mellitus
#> ℹ Sigla detectada: "DM2" -> "diabetes mellitus tipo
#> 2"
#> # A tibble: 11 × 4
#>    codigo descripcion                                            score categoria
#>    <chr>  <chr>                                                  <dbl> <chr>    
#>  1 E11.0  Diabetes mellitus tipo 2 con coma                          1 E11 DIAB…
#>  2 E11.1  Diabetes mellitus tipo 2 con cetoacidosis                  1 E11 DIAB…
#>  3 E11.2  Diabetes mellitus tipo 2 con complicaciones renales        1 E11 DIAB…
#>  4 E11.3  Diabetes mellitus tipo 2 con complicaciones oftálmicas     1 E11 DIAB…
#>  5 E11.4  Diabetes mellitus tipo 2 con complicaciones neurológi…     1 E11 DIAB…
#>  6 E11.5  Diabetes mellitus tipo 2 con complicaciones  circulat…     1 E11 DIAB…
#>  7 E11.6  Diabetes mellitus tipo 2 con otras complicaciones  es…     1 E11 DIAB…
#>  8 E11.7  Diabetes mellitus tipo 2 con complicaciones múltiples      1 E11 DIAB…
#>  9 E11.8  Diabetes mellitus tipo 2 con complicaciones no especi…     1 E11 DIAB…
#> 10 E11.9  Diabetes mellitus tipo 2 sin complicaciones                1 E11 DIAB…
#> 11 O24.1  Diabetes mellitus tipo 2 preexistente                      1 O24 DIAB…
```

The following table summarizes the available categories and their
approximate size. Numbers may vary between package versions.

| Category         | Examples               |
|------------------|------------------------|
| Cardiovascular   | IAM, HTA, ACV, FA, ICC |
| Respiratory      | TBC, EPOC, NAC, SDRA   |
| Metabolic        | DM, DM1, DM2, ERC, IRC |
| Gastrointestinal | HDA, HDB, RGE, DHC     |
| Infectious       | VIH, ITU, ITS, sepsis  |
| Oncological      | CA, LMA, LMC, LLA, LLC |
| Neurological     | TEC, EPI, EM, ELA      |
| Psychiatric      | TDAH, TOC, TAG, TEPT   |

## Multilingual ICD-11 API

[`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)
queries the official WHO API and allows specifying the language, since
the WHO server provides official translations. `ciecl` exposes the
parameter `lang = "es"` (default) or `lang = "en"`.

``` r

# Search in Spanish (default)
# Requires a WHO API Key
cie11_search("diabetes mellitus", lang = "es")
```

> Note: this section requires WHO API credentials. See the vignette
> [Installation and Configuration
> Guide](https://rodotasso.github.io/ciecl/articles/installation.md) to
> learn how to store them securely using `keyring`.

## Encoding and special characters

The package is encoded in **UTF-8** and the dataset preserves all
Spanish characters (accents, ñ, diaeresis) and the dual-coding symbols
(dagger †, asterisk \*) that appear in the MINSAL catalog. When
searching,
[`cie_search()`](https://rodotasso.github.io/ciecl/reference/cie_search.md)
and
[`cie_norm()`](https://rodotasso.github.io/ciecl/reference/cie_norm.md)
know how to clean them.

``` r

Encoding(cie10_cl$descripcion[1])
#> [1] "UTF-8"
```

## References

- **ICD-10 Chile**: <https://deis.minsal.cl/centrofic/>
- **WHO ICD-11**: <https://icd.who.int/>
- **ICD-11 API**: <https://icd.who.int/icdapi>
