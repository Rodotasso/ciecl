#' Generar tabla HTML interactiva GT de codigo CIE-10
#'
#' @description
#' Muestra la jerarquia de un codigo CIE-10 (categoria + subcategorias)
#' como una tabla `gt`. Las columnas "Incluye" y "Excluye" pueden
#' aparecer vacias en subcategorias: el catalogo MINSAL/DEIS no puebla
#' esos campos en todos los niveles (suelen estar solo en la categoria
#' de 3 digitos). Para evitar confusion visual, los `NA` se reemplazan
#' por un guion largo (em dash).
#'
#' @param code String codigo (ej. `"E11"` muestra la jerarquia).
#' @param codigo `r lifecycle::badge("deprecated")` Use `code`.
#' @returns Objeto de clase `gt_tbl` (tabla HTML interactiva).
#' @family visualization
#' @seealso [cie_search()], [cie_lookup()]
#' @export
#' @importFrom dplyr select everything mutate across
#' @examplesIf rlang::is_installed("gt")
#' cie_table("E11")  # Diabetes mellitus tipo 2 completo
cie_table <- function(code, codigo = lifecycle::deprecated()) {
  if (lifecycle::is_present(codigo)) {
    lifecycle::deprecate_warn(
      "0.9.8",
      "cie_table(codigo = )",
      "cie_table(code = )"
    )
    code <- codigo
  }

  rlang::check_installed("gt", reason = "para generar la tabla HTML.")

  datos <- cie_lookup(code, expand = TRUE)

  if (nrow(datos) == 0) {
    cli::cli_abort("Codigo no encontrado: {.val {code}}", class = "ciecl_invalid_code")
  }

  # Reemplazar NA/vacio por em dash (U+2014) en columnas de texto.
  em_dash <- intToUtf8(0x2014)

  # Identificar si columnas de notas estan vacias antes del reemplazo
  notas_vacias <- vapply(c("inclusion", "exclusion"), function(col) {
    all(is.na(datos[[col]]) | datos[[col]] == "")
  }, logical(1))

  datos <- datos |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(c("inclusion", "exclusion", "descripcion")),
        function(x) ifelse(is.na(x) | x == "", em_dash, x)
      )
    )

  tabla <- datos |>
    dplyr::select(codigo, descripcion, inclusion, exclusion) |>
    gt::gt() |>
    gt::tab_header(
      title = sprintf("CIE-10 Chile: %s", code),
      subtitle = "Fuente: MINSAL/DEIS v2018"
    )

  # Ocultar columnas vacias dinamicamente
  if (notas_vacias["inclusion"]) {
    tabla <- tabla |> gt::cols_hide(columns = inclusion)
  }
  if (notas_vacias["exclusion"]) {
    tabla <- tabla |> gt::cols_hide(columns = exclusion)
  }

  tabla <- tabla |>
    gt::cols_label(
      codigo = "Codigo",
      descripcion = "Diagnostico",
      inclusion = "Incluye",
      exclusion = "Excluye"
    ) |>
    gt::fmt_markdown(columns = dplyr::everything()) |>
    gt::tab_options(
      table.font.size = 12,
      heading.background.color = "#1f77b4"
    )

  return(tabla)
}
