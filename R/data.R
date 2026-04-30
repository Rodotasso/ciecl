#' Dataset CIE-10 Chile oficial MINSAL/DEIS v2018
#'
#' @format tibble con 39,877 filas (categorias y subcategorias):
#' \describe{
#'   \item{codigo}{Codigo CIE-10 (ej. "E11.0")}
#'   \item{descripcion}{Diagnostico en espanol chileno}
#'   \item{categoria}{Categoria jerarquica}
#'   \item{seccion}{Seccion dentro del capitulo}
#'   \item{capitulo_nombre}{Nombre descriptivo del capitulo}
#'   \item{inclusion}{Terminos incluidos}
#'   \item{exclusion}{Terminos excluidos}
#'   \item{capitulo}{Capitulo CIE-10 (A-Z)}
#'   \item{es_daga}{Logical, codigo daga (+)}
#'   \item{es_cruz}{Logical, codigo asterisco (*)}
#' }
#' @source \url{https://deis.minsal.cl/centrofic/}
#' @examples
#' data(cie10_cl)
#' head(cie10_cl)
"cie10_cl"
