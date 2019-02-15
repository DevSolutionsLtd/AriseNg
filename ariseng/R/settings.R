#' Fetch the project template/data
#'
#' Enables the user to use the predefined variables for this project
#'
#' @param path The path to a directory where the settings are to be
#' saved.
#'
#' @export
fetch_settings <- function(path = '.')
{
  stopifnot(dir.exists(path))
  f <- system.file('extdata', 'arise.dte', package = 'ariseng', mustWork = TRUE)
  file.copy(f, file.path(path, basename(f)))
}
