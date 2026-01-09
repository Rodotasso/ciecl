#' @importFrom stringr str_trim str_replace_all str_detect str_extract str_split
#' @importFrom dplyr select mutate filter all_of any_of bind_rows distinct %>%
#' @importFrom tibble as_tibble
NULL

#' Normalizar texto removiendo tildes y caracteres especiales
#'
#' @param texto Character vector a normalizar
#' @return Character vector sin tildes ni caracteres especiales
#' @keywords internal
#' @noRd
normalizar_tildes <- function(texto) {

  # Manejar NA
  if (length(texto) == 0) return(character(0))


  texto <- stringr::str_replace_all(texto, "\u00e1", "a")  # a

  texto <- stringr::str_replace_all(texto, "\u00e9", "e")  # e

  texto <- stringr::str_replace_all(texto, "\u00ed", "i")  # i
  texto <- stringr::str_replace_all(texto, "\u00f3", "o")  # o
  texto <- stringr::str_replace_all(texto, "\u00fa", "u")  # u
  texto <- stringr::str_replace_all(texto, "\u00fc", "u")  # u dieresis
  texto <- stringr::str_replace_all(texto, "\u00f1", "n")  # n tilde
  texto <- stringr::str_replace_all(texto, "\u00c1", "A")  # A
  texto <- stringr::str_replace_all(texto, "\u00c9", "E")  # E
  texto <- stringr::str_replace_all(texto, "\u00cd", "I")  # I
  texto <- stringr::str_replace_all(texto, "\u00d3", "O")  # O
  texto <- stringr::str_replace_all(texto, "\u00da", "U")  # U
  texto <- stringr::str_replace_all(texto, "\u00dc", "U")  # U dieresis
  texto <- stringr::str_replace_all(texto, "\u00d1", "N")  # N tilde

  return(texto)
}

#' Diccionario de siglas medicas comunes en Chile
#'
#' @return Named list con siglas como keys y terminos de busqueda como values
#' @keywords internal
#' @noRd
get_siglas_medicas <- function() {
  list(
    # Cardiovasculares
    "iam" = "infarto agudo miocardio",
    "iamcest" = "infarto agudo miocardio",
    "iamsest" = "infarto agudo miocardio",
    "sca" = "sindrome coronario agudo",
    "hta" = "hipertension arterial",
    "aha" = "hipertension arterial",
    "icc" = "insuficiencia cardiaca",
    "ic" = "insuficiencia cardiaca",
    "fa" = "fibrilacion auricular",
    "tep" = "embolia pulmonar",
    "tvp" = "trombosis venosa profunda",
    "eap" = "edema agudo pulmon",
    "acv" = "accidente cerebrovascular",
    "ave" = "accidente vascular encefalico",
    "ait" = "isquemico transitorio",

    # Respiratorias
    "tbc" = "tuberculosis",
    "tb" = "tuberculosis",
    "epoc" = "enfermedad pulmonar obstructiva cronica",
    "asma" = "asma",
    "nac" = "neumonia",
    "ira" = "infeccion respiratoria aguda",
    "sdra" = "sindrome distres respiratorio",
    "covid" = "covid",
    "sars" = "coronavirus",

    # Metabolicas/Endocrinas
    "dm" = "diabetes mellitus",
    "dm1" = "diabetes mellitus tipo 1",
    "dm2" = "diabetes mellitus tipo 2",
    "dbt" = "diabetes",
    "hipo" = "hipotiroidismo",
    "hiper" = "hipertiroidismo",
    "erc" = "enfermedad renal cronica",
    "irc" = "insuficiencia renal cronica",
    "ira" = "insuficiencia renal aguda",

    # Gastrointestinales
    "hda" = "hemorragia digestiva alta",
    "hdb" = "hemorragia digestiva baja",
    "rge" = "reflujo gastroesofagico",
    "erge" = "reflujo gastroesofagico",
    "eii" = "enfermedad inflamatoria intestinal",
    "cu" = "colitis ulcerosa",
    "ec" = "enfermedad crohn",
    "dhc" = "dano hepatico cronico",
    "cirrosis" = "cirrosis",

    # Infecciosas
    "vih" = "vih",
    "sida" = "sida",
    "its" = "infeccion transmision sexual",
    "ets" = "enfermedad transmision sexual",
    "itu" = "infeccion tracto urinario",
    "ivu" = "infeccion vias urinarias",
    "meningitis" = "meningitis",
    "sepsis" = "sepsis",

    # Oncologicas
    "ca" = "carcinoma",
    "neo" = "neoplasia",
    "lma" = "leucemia mieloide aguda",
    "lmc" = "leucemia mieloide cronica",
    "lla" = "leucemia linfoblastica aguda",
    "llc" = "leucemia linfocitica cronica",
    "lnh" = "linfoma no hodgkin",
    "lh" = "linfoma hodgkin",
    "mm" = "mieloma multiple",

    # Reumatologicas
    "ar" = "artritis reumatoide",
    "les" = "lupus eritematoso",
    "fm" = "fibromialgia",
    "ea" = "espondilitis anquilosante",

    # Neurologicas
    "epi" = "epilepsia",
    "parkinson" = "parkinson",
    "alzheimer" = "alzheimer",
    "em" = "esclerosis multiple",
    "ela" = "esclerosis lateral amiotrofica",
    "cefalea" = "cefalea",
    "migrana" = "migrana",

    # Psiquiatricas
    "tdah" = "deficit atencion hiperactividad",
    "toc" = "obsesivo compulsivo",
    "tag" = "ansiedad generalizada",
    "tept" = "estres postraumatico",
    "edm" = "depresion mayor",
    "tab" = "trastorno bipolar",

    # Traumatologicas
    "tec" = "traumatismo craneoencefalico",
    "fx" = "fractura",
    "lca" = "ligamento cruzado anterior",

    # Pediatricas
    "sbo" = "sindrome bronquial obstructivo",
    "eda" = "enfermedad diarreica aguda",
    "gea" = "gastroenteritis aguda",

    # Gineco-obstetricias
    "sop" = "sindrome ovario poliquistico",
    "epi" = "enfermedad pelvica inflamatoria",
    "hie" = "hipertension embarazo",
    "pe" = "preeclampsia",
    "dpp" = "desprendimiento prematuro placenta",
    "rciu" = "restriccion crecimiento intrauterino"
  )
}

#' Expandir siglas medicas a terminos de busqueda
#'
#' @param texto Texto que puede contener siglas
#' @return Texto con siglas expandidas o NULL si no es sigla
#' @keywords internal
#' @noRd
expandir_sigla <- function(texto) {
  siglas <- get_siglas_medicas()
  texto_lower <- tolower(stringr::str_trim(texto))

  if (texto_lower %in% names(siglas)) {
    return(siglas[[texto_lower]])
  }

  return(NULL)
}

#' Listar siglas medicas soportadas
#'
#' Muestra todas las siglas medicas que pueden usarse en cie_search().
#'
#' @param categoria Character opcional, filtrar por categoria
#'   ("cardiovascular", "respiratoria", "metabolica", "infecciosa",
#'   "oncologica", "neurologica", "psiquiatrica", "otra")
#' @return tibble con columnas: sigla, termino_busqueda
#' @export
#' @examples
#' # Ver todas las siglas
#' cie_siglas()
#'
#' # Buscar una sigla especifica
#' cie_siglas() |> dplyr::filter(sigla == "iam")
cie_siglas <- function(categoria = NULL) {
  siglas <- get_siglas_medicas()

  resultado <- tibble::tibble(
    sigla = names(siglas),
    termino_busqueda = unlist(siglas)
  )

  return(resultado)
}

#' Busqueda difusa (fuzzy) de terminos medicos CIE-10
#'
#' Busca en descripciones CIE-10 usando multiples estrategias:
#' 1. Expansion de siglas medicas (IAM, TBC, DM, etc.)
#' 2. Busqueda exacta por subcadena (mas rapida)
#' 3. Busqueda fuzzy con Jaro-Winkler (tolera typos)
#'
#' La busqueda es tolerante a tildes: "neumonia" encuentra "neumonia".
#' Soporta siglas medicas comunes: "IAM" busca "infarto agudo miocardio".
#'
#' @param texto String termino medico en espanol o sigla (ej. "diabetes", "IAM", "TBC")
#' @param threshold Numeric entre 0 y 1, umbral similitud Jaro-Winkler (default 0.70)
#' @param max_results Integer, maximo resultados a retornar (default 50)
#' @param campo Character, campo busqueda ("descripcion" o "inclusion")
#' @param solo_fuzzy Logical, usar solo busqueda fuzzy sin busqueda exacta (default FALSE)
#' @return tibble ordenado por score descendente (1.0 = coincidencia exacta).
#'   Incluye atributo "sigla_expandida" si se uso una sigla.
#' @export
#' @importFrom stringdist stringsim
#' @importFrom dplyr mutate filter arrange desc slice_head select everything %>%
#' @examples
#' # Busqueda basica
#' cie_search("diabetes")
#' cie_search("neumonia")
#'
#' # Busqueda por siglas medicas
#' cie_search("IAM")
#' cie_search("tbc")
#' cie_search("DM2")
#' cie_search("EPOC")
#' cie_search("HTA")
#'
#' # Tolerante a tildes
#' cie_search("neumonia")
#' cie_search("rinon")
#'
#' # Buscar con typos
#' cie_search("diabetis")
#'
#' # Buscar en inclusiones
#' cie_search("bacteriana", campo = "inclusion")
cie_search <- function(texto, threshold = 0.70, max_results = 50,
                       campo = c("descripcion", "inclusion"),
                       solo_fuzzy = FALSE) {
  campo <- match.arg(campo)

  # Validacion de parametros
  if (threshold < 0 || threshold > 1) {
    stop("threshold debe estar entre 0 y 1")
  }
  if (max_results < 1) {
    stop("max_results debe ser >= 1")
  }

  texto_limpio <- stringr::str_trim(texto)

  # Permitir siglas de 2 caracteres (DM, TB, FA, etc.)
  if (nchar(texto_limpio) < 2) {
    stop("Texto minimo 2 caracteres")
  }

  # Verificar si es una sigla medica y expandirla

  sigla_expandida <- expandir_sigla(texto_limpio)
  texto_busqueda <- if (!is.null(sigla_expandida)) {
    message("i Sigla detectada: ", toupper(texto_limpio), " -> ", sigla_expandida)
    sigla_expandida
  } else {
    texto_limpio
  }

  # Conexion segura con auto-cierre
  con <- get_cie10_db()
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  # Normalizar texto de busqueda (minusculas + sin tildes)
  texto_norm <- tolower(texto_busqueda)
  texto_sin_tildes <- normalizar_tildes(texto_norm)

  # Construir query SQL
  if (campo == "descripcion") {
    query_sql <- "SELECT codigo, descripcion, categoria FROM cie10"
  } else {
    query_sql <- sprintf("SELECT codigo, descripcion, categoria, %s FROM cie10", campo)
  }

  base <- DBI::dbGetQuery(con, query_sql) %>% tibble::as_tibble()

  # Normalizar texto de la base (minusculas + sin tildes)
  base_texto <- tolower(stringr::str_trim(base[[campo]]))
  base_texto[is.na(base_texto)] <- ""
  base_texto_sin_tildes <- normalizar_tildes(base_texto)

  # ESTRATEGIA 1: Busqueda exacta por subcadena (mas rapida y precisa)
  if (!solo_fuzzy) {
    # Buscar coincidencias exactas (subcadena)
    matches_exactos <- stringr::str_detect(base_texto_sin_tildes,
                                           stringr::fixed(texto_sin_tildes))

    if (any(matches_exactos)) {
      resultado_exacto <- base[matches_exactos, ] %>%
        dplyr::mutate(score = 1.0) %>%
        dplyr::slice_head(n = max_results) %>%
        dplyr::select(codigo, descripcion, score, dplyr::everything())

      return(resultado_exacto)
    }
  }

  # ESTRATEGIA 2: Busqueda fuzzy palabra por palabra
  # Dividir texto en palabras y buscar cada palabra
  palabras <- unlist(stringr::str_split(texto_sin_tildes, "\\s+"))
  palabras <- palabras[nchar(palabras) >= 3]

  if (length(palabras) > 0) {
    # Calcular score basado en cuantas palabras coinciden
    scores_palabras <- sapply(seq_along(base_texto_sin_tildes), function(i) {
      texto_base <- base_texto_sin_tildes[i]
      # Contar palabras que aparecen en la descripcion
      matches <- sapply(palabras, function(p) {
        stringr::str_detect(texto_base, stringr::fixed(p))
      })
      sum(matches) / length(palabras)
    })

    # Si hay coincidencias parciales de palabras
    if (any(scores_palabras > 0)) {
      resultado <- base %>%
        dplyr::mutate(score = scores_palabras) %>%
        dplyr::filter(score > 0) %>%
        dplyr::arrange(dplyr::desc(score)) %>%
        dplyr::slice_head(n = max_results) %>%
        dplyr::select(codigo, descripcion, score, dplyr::everything())

      if (nrow(resultado) > 0) {
        return(resultado)
      }
    }
  }

  # ESTRATEGIA 3: Fuzzy matching con Jaro-Winkler (para typos)
  # Calcular similitud de cada palabra del texto con palabras de la descripcion
  scores_fuzzy <- sapply(seq_along(base_texto_sin_tildes), function(i) {
    texto_base <- base_texto_sin_tildes[i]
    palabras_base <- unlist(stringr::str_split(texto_base, "\\s+"))
    palabras_base <- palabras_base[nchar(palabras_base) >= 3]

    if (length(palabras_base) == 0) return(0)

    # Para cada palabra del texto buscar la mejor coincidencia en la descripcion
    best_scores <- sapply(palabras, function(p) {
      if (length(palabras_base) == 0) return(0)
      max(stringdist::stringsim(p, palabras_base, method = "jw"))
    })

    mean(best_scores)
  })

  # Filtrar + ordenar resultados fuzzy
  resultado <- base %>%
    dplyr::mutate(score = scores_fuzzy) %>%
    dplyr::filter(score >= threshold) %>%
    dplyr::arrange(dplyr::desc(score)) %>%
    dplyr::slice_head(n = max_results) %>%
    dplyr::select(codigo, descripcion, score, dplyr::everything())

  if (nrow(resultado) == 0) {
    message("x Sin coincidencias >= threshold ", threshold)
  }

  return(resultado)
}

#' Busqueda exacta por codigo CIE-10
#'
#' @param codigo Character vector de codigos (ej. "E11", "E11.0", c("E11.0", "Z00"))
#'   o rango (ej. "E10-E14"). Acepta vectores de multiples codigos.
#'   Soporta formatos: con punto (E11.0), sin punto (E110), o solo categoria (E11).
#' @param expandir Logical, expandir jerarquia completa (default FALSE)
#' @param normalizar Logical, normalizar formato de codigos automaticamente (default TRUE)
#' @param descripcion_completa Logical, agregar columna descripcion_completa con formato "CODIGO - DESCRIPCION" (default FALSE)
#' @return tibble con codigo(s) matcheado(s)
#' @export
#' @examples
#' cie_lookup("E11.0")       # Con punto
#' cie_lookup("E110")        # Sin punto
#' cie_lookup("E11")         # Solo categoria
#' cie_lookup("E11", expandir = TRUE)  # Todos E11.x
#' # Vectorizado - multiples codigos y formatos
#' cie_lookup(c("E11.0", "Z00", "I10"))
#' # Con descripcion completa
#' cie_lookup("E110", descripcion_completa = TRUE)
cie_lookup <- function(codigo, expandir = FALSE, normalizar = TRUE, descripcion_completa = FALSE) {
  # Manejar vector vacio

  if (length(codigo) == 0) {
    return(cie10_empty_tibble(add_descripcion_completa = descripcion_completa))
  }

  # Filtrar NAs antes de procesar
  codigo_sin_na <- codigo[!is.na(codigo)]
  if (length(codigo_sin_na) == 0) {
    return(cie10_empty_tibble(add_descripcion_completa = descripcion_completa))
  }

  # Normalizar entrada
  codigo_input <- stringr::str_trim(toupper(codigo_sin_na))
  
  # Normalizar formato si se solicita: agregar punto si falta (E110 -> E11.0)
  if (normalizar) {
    codigo_norm <- ifelse(
      stringr::str_detect(codigo_input, "^[A-Z]\\d{3,}$") & !stringr::str_detect(codigo_input, "\\."),
      stringr::str_replace(codigo_input, "^([A-Z]\\d{2})(\\d.*)$", "\\1.\\2"),
      codigo_input
    )
  } else {
    codigo_norm <- codigo_input
  }
  
  # Si es vector de multiples codigos, procesar cada uno y combinar
  if (length(codigo_norm) > 1) {
    # Procesar cada codigo individualmente y combinar resultados
    resultados_lista <- lapply(codigo_norm, function(cod) {
      cie_lookup_single(cod, expandir = expandir)
    })
    
    # Combinar todos los resultados en un solo tibble
    resultado <- dplyr::bind_rows(resultados_lista)
    
    # Eliminar duplicados que pudieran surgir
    resultado <- dplyr::distinct(resultado)
  } else {
    # Codigo unico - usar funcion interna
    resultado <- cie_lookup_single(codigo_norm, expandir = expandir)
  }
  
  # Agregar columna descripcion_completa si se solicita
  if (descripcion_completa) {
    if (nrow(resultado) > 0) {
      resultado <- resultado %>%
        dplyr::mutate(
          descripcion_completa = paste0(codigo, " - ", descripcion)
        )
    } else {
      # Asegurar que la columna existe incluso cuando el resultado está vacío
      # Necesitamos usar tibble::add_column() para mantener la estructura de tibble
      resultado <- resultado %>%
        tibble::add_column(descripcion_completa = character(0))
    }
  }
  
  return(resultado)
}

#' Busqueda interna de un solo codigo CIE-10
#' @keywords internal
#' @noRd
cie_lookup_single <- function(codigo_norm, expandir = FALSE) {
  # Asegurar que codigo_norm es un escalar (longitud 1)
  if (length(codigo_norm) != 1) {
    stop("cie_lookup_single() solo acepta un codigo a la vez")
  }

  # Manejar NA
  if (is.na(codigo_norm)) {
    return(cie10_empty_tibble())
  }

  # Manejar cadena vacia
  if (nchar(stringr::str_trim(codigo_norm)) == 0) {
    return(cie10_empty_tibble())
  }

  # Sanitizar entrada para prevenir SQL injection
  # Solo permitir caracteres validos para codigos CIE-10: letras, numeros, punto, guion
  if (!stringr::str_detect(codigo_norm, "^[A-Za-z0-9.\\-]+$")) {
    message("x Codigo con caracteres invalidos: ", codigo_norm)
    return(cie10_empty_tibble())
  }

  # Conexion con queries parametrizadas (previene SQL injection)
  con <- get_cie10_db()
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  if (expandir) {
    # Buscar jerarquia completa (E11 -> E11.x)
    query <- "SELECT * FROM cie10 WHERE codigo LIKE ? ORDER BY codigo"
    resultado <- DBI::dbGetQuery(con, query, params = list(paste0(codigo_norm, "%")))
  } else if (stringr::str_detect(codigo_norm, "-")) {
    # Rango (ej. "E10-E14")
    partes <- stringr::str_split(codigo_norm, "-")[[1]]
    query <- "SELECT * FROM cie10 WHERE codigo BETWEEN ? AND ? ORDER BY codigo"
    resultado <- DBI::dbGetQuery(con, query, params = list(partes[1], partes[2]))
  } else {
    # Exacto
    query <- "SELECT * FROM cie10 WHERE codigo = ?"
    resultado <- DBI::dbGetQuery(con, query, params = list(codigo_norm))
  }

  resultado <- tibble::as_tibble(resultado)

  if (nrow(resultado) == 0) {
    message("x Codigo no encontrado: ", codigo_norm)
  }

  return(resultado)
}
