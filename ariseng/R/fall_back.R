#' Fall-back function
#'
#' Use spreadsheet format for data entry instead of GUI.
#'
#' @details A fall-back function to use for data entry in the event of failure to
#' to initialize the GUI
#'
#' @importFrom utils edit
#'
#' @export
fall_back <- function()
{
  fetch_settings()
  f <- file.path(getwd(), "arise.dte")
  if (!file.exists(f))
    stop("Could not find path", f)
  
  env <- new.env()
  load(f, envir = env)
  env$Data <- edit(env$Data)
  save(list = ls(envir = env),
       file = f,
       envir = env)
  message("Project data and settings are at", f)
}
