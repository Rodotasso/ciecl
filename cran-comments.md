## Submission ciecl 0.9.6

This is an update of ciecl (currently 0.9.2 on CRAN) with substantial
improvements in performance, security, testing, and documentation.
No user-facing breaking changes affecting the CRAN-published surface.

## Summary of changes since 0.9.2

* **SQLite connection pooling** with atomic versioned cache in
  `get_cie10_db()`. Reuses active connections and rebuilds the cache
  when corrupted or outdated.
* **Vectorized** `cie_map_comorbid()` and `cie_normalizar()` for
  efficient batch processing.
* **FTS5 input sanitization** against SQL injection, SQL comment
  stripping, and stricter input validation on exported functions.
* **pkgdown site** with dark mode (light-switch), hex logo, and
  favicons.
* **New vignette** `caso-uso-egresos` with simulated hospital discharge
  data using DEIS essential columns.
* **Bilingual community files**: CONTRIBUTING.md, CODE_OF_CONDUCT.md,
  SECURITY.md (English + Spanish).
* **`@family` and `@seealso`** added across all exported functions.
* **English-first documentation** with full Spanish translations.
* **CI/CD**: multi-platform R-CMD-check (Windows, macOS, Ubuntu),
  coverage workflow, automatic pkgdown deployment, R-hub workflow.
* Pipe standardization to `%>%`, `codemeta.json` sync with DESCRIPTION,
  removal of bundled `inst/extdata/cie10.db` (was causing a 21.3 MB
  NOTE), cross-platform compatibility fixes.

Full changelog in NEWS.md.

## Test results

* **Tests**: 1148 PASS, 0 FAIL, 4 WARN, 14 SKIP (95.6% coverage).
* **R CMD check**: 0 errors | 0 warnings | 2 notes.

### NOTEs explained

1. **CRAN incoming feasibility — invalid URLs (HTTP 403)**:
   The MINSAL/DEIS URLs in documentation return HTTP 403 when
   accessed by automated tools due to anti-bot protection on Chilean
   government servers. These URLs are valid and accessible via
   regular browsers:
   - https://deis.minsal.cl
   - https://deis.minsal.cl/centrofic/
   - https://repositoriodeis.minsal.cl

2. **Examples with elapsed time > 5s** (only under `--run-donttest`):
   Examples for `cie_search()` and `cie_lookup()` are already wrapped
   in `\donttest{}` because they trigger first-run SQLite cache
   initialization. They do not execute under standard CRAN checks;
   the NOTE is only produced when `--run-donttest` is passed
   explicitly.

## Test environments

* Local: Windows 11 x64, R 4.4.3
* GitHub Actions R-CMD-check:
  - macOS-latest (release)
  - windows-latest (release)
  - ubuntu-latest (devel, release, oldrel-1)
* R-hub (Windows, macOS, Linux)

## Downstream dependencies

This package has no reverse dependencies (verified via
`revdepcheck::revdep_check()`).
