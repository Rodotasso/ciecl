## Resubmission (v0.9.3)

This is a resubmission addressing issues found after v0.9.2 acceptance:

1. **`generar_cie10_cl()` no longer exported**: This development-only function
   (writes to `data/` directory) was incorrectly exported. Now marked internal
   with `@noRd`.

2. **`cie_lookup()` examples wrapped in `\donttest{}`**: Examples trigger SQLite
   cache initialization (~16s on first run), exceeding CRAN's 5s timeout.

3. **`comorbidity` and `gt` moved from Imports to Suggests**: Both packages are
   used via `requireNamespace()` checks, consistent with optional dependencies.

4. **Messages suppressed in non-interactive sessions**: Database initialization
   messages now wrapped in `if (interactive())`.

5. **Hardcoded path removed from tests**: Removed absolute path from
   `tests/testthat/setup.R`.

## R CMD check results

0 errors | 0 warnings | 1 note

### NOTEs explained

1. **URLs returning 403**: The MINSAL/DEIS URLs in documentation return HTTP 403
   when accessed by automated tools due to anti-bot protection on Chilean
   government servers. These URLs are valid and accessible via browser:
   - https://deis.minsal.cl
   - https://deis.minsal.cl/centrofic/
   - https://repositoriodeis.minsal.cl

## Test environments

* Local: Windows 11 x64, R 4.4.3
* GitHub Actions:
  - macOS-latest (release)
  - windows-latest (release)
  - ubuntu-latest (devel, release, oldrel-1)

## Downstream dependencies

This package has no reverse dependencies.
