# Installation and Configuration Guide

The `ciecl` package is designed to work with ICD-10 and ICD-11
classifications in the Chilean clinical context. This guide covers the
recommended installation, system requirements, and the configuration of
external credentials.

## Basic Installation

The easiest way to install `ciecl` is using the `pak` package, which
automatically manages system dependencies and R package requirements.

### From CRAN (Stable Version)

``` r
# Install pak if you don't have it
if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")

# Install ciecl
pak::pkg_install("ciecl")
```

### From GitHub (Development Version)

To use the latest features from the `rev-ropensci` branch:

``` r
pak::pkg_install("RodoTasso/ciecl@rev-ropensci")
```

## Installation with Optional Dependencies

The package has minimal dependencies for core functionality. To enable
all features, including comorbidity indices and interactive tables:

``` r
# Full installation with all optional packages
pak::pkg_install("RodoTasso/ciecl", dependencies = TRUE)
```

### Dependencies by Feature

| Feature                           | Required Package | Installation                      |
|-----------------------------------|------------------|-----------------------------------|
| Charlson/Elixhauser Comorbidities | `comorbidity`    | `install.packages("comorbidity")` |
| Interactive GT Tables             | `gt`             | `install.packages("gt")`          |
| WHO ICD-11 API                    | `httr2`          | `install.packages("httr2")`       |
| Read MINSAL Excel Files           | `readxl`         | `install.packages("readxl")`      |

## System Requirements

The package uses a local SQLite database to ensure high performance in
vectorized searches.

### Windows

No additional configuration needed. The installation works out of the
box.

### macOS

Install the Xcode Command Line Tools if you plan to compile from source:

``` bash
xcode-select --install
```

### Linux (Ubuntu/Debian)

Execute the following to install system requirements:

``` bash
sudo apt-get update
sudo apt-get install -y \
  r-base-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev
```

### Linux (Fedora/RHEL/CentOS)

``` bash
sudo dnf install -y \
  R-devel \
  libcurl-devel \
  openssl-devel \
  libxml2-devel
```

## ICD-11 API Configuration (Optional)

To use
[`cie11_search()`](https://rodotasso.github.io/ciecl/reference/cie11_search.md)
and access the WHO ICD-11 international classification, you need free
credentials.

1.  Register at [icd.who.int/icdapi](https://icd.who.int/icdapi).
2.  Obtain your **Client ID** and **Client Secret**.

### Credential Management

**Option A: Using `keyring` (Recommended)**

The `keyring` package stores secrets in the OS native keychain (macOS
Keychain, Windows Credential Store, Linux Secret Service), avoiding
plain text secrets in your environment files.

``` r
# Store credentials once (it will prompt for them)
# Format: "client_id:client_secret"
keyring::key_set("ciecl_icd11")

# Use them in your session
Sys.setenv(ICD_API_KEY = keyring::key_get("ciecl_icd11"))
```

**Option B: Using `.Renviron` File**

Add the following line to your `~/.Renviron` file (you can use
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html)):

    ICD_API_KEY=your_client_id:your_client_secret

Restart R for the changes to take effect. Ensure `.Renviron` is not
tracked by Git.

## Verify Installation

``` r
library(ciecl)

# Check package version
packageVersion("ciecl")

# Verify catalog access
nrow(cie10_cl) # Should return ~39,873 records

# Test basic lookup
cie_lookup("E11.0")

# Test fuzzy search
cie_search("diabetes")
```

## Troubleshooting

### Connection to Local Database

If you encounter errors related to the database connection or corrupt
data, force a rebuild of the local cache:

``` r
ciecl::cie10_clear_cache()
```

### Manual Proxy Configuration

If you are behind a corporate proxy, configure your R environment before
using the WHO API:

``` r
Sys.setenv(https_proxy = "http://your-proxy-url:port")
```

## Support

- Report issues: <https://github.com/RodoTasso/ciecl/issues>
- Documentation: <https://rodotasso.github.io/ciecl/>
