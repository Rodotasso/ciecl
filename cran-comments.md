## R CMD check results

0 errors | 0 warnings | 2 notes

### NOTEs explained

1. **New submission**: This is the first submission of ciecl to CRAN.

2. **URLs returning 403**: The MINSAL/DEIS URLs in documentation return HTTP 403 (Forbidden)
   when accessed by automated tools due to anti-bot protection on Chilean government servers.
   These URLs are valid and accessible via browser:
   - https://deis.minsal.cl
   - https://deis.minsal.cl/centrofic/
   - https://repositoriodeis.minsal.cl

3. **Example timing**: Some examples take >5s because they initialize an SQLite
   database cache on first run. Subsequent calls are fast (<1s).

## Test environments

* Local: Windows 11 x64, R 4.4.3
* GitHub Actions:
  - macOS-latest (release)
  - windows-latest (release)
  - ubuntu-latest (devel, release, oldrel-1)

## Package purpose

`ciecl` provides tools for working with the official Chilean ICD-10 classification
(CIE-10 MINSAL/DEIS v2018) in R. It includes:

- 39,873 ICD-10 codes from Chile's Ministry of Health
- Optimized SQL search with SQLite caching
- Fuzzy matching for medical terms (Jaro-Winkler algorithm)
- Charlson and Elixhauser comorbidity calculations
- WHO ICD-11 API integration (optional)

## Downstream dependencies

This is a new package with no reverse dependencies.

## Data source

ICD-10 data is from the official Chilean Ministry of Health (MINSAL) Department of
Health Statistics and Information (DEIS), specifically the FIC Chile Center. The data
is for public use according to Chilean Decree 356 Exempt (2017) establishing official
ICD-10 use in Chile.

- Data source: https://deis.minsal.cl/centrofic/
- Legal basis: https://www.bcn.cl/leychile/navegar?i=1112064

## Special notes

### Language
The package is in Spanish (`Language: es` in DESCRIPTION) because:
- Official Chilean ICD-10 data is in Spanish
- Target audience is healthcare professionals in Chile and Latin America
- All medical documentation follows Spanish conventions

### Local cache
The package optionally creates an SQLite database in the user's cache directory
using `tools::R_user_dir("ciecl", "data")` per CRAN recommendations.
Tests include `skip_on_cran()` to avoid file creation during checks.

### External API (optional)
The `cie11_search()` function accesses the WHO API (https://icd.who.int/icdapi).
This is completely optional and requires user credentials.
The function fails gracefully without credentials.
Examples use `\dontrun{}` to avoid requiring internet connection.
