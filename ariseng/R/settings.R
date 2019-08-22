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
  path <- normalizePath(path)
  stopifnot(dir.exists(path))
  orig <-
    system.file('extdata',
                'arise.dte',
                package = 'ariseng',
                mustWork = TRUE)
  cpy <- file.path(path, basename(orig))
  
  overwrite <- FALSE
  if (file.exists(cpy)) {
    opt <-
      menu(
        c("Yes", "No"),
        graphics = TRUE,
        title = sprintf(
          "Overwrite %s?",
          sQuote(basename(cpy))
        )
      )
    if (opt == 2L)
      return(FALSE)
    else if (opt == 1L)
      overwrite <- TRUE
  }
  
  file.copy(orig, cpy, overwrite = overwrite)
}
