#' Reset the Project
#' 
#' Starting the entire project from scratch
#' 
#' @param proj The path to the project file (with extension \emph{.dte}).
#' 
#' @export
reset_project <- function(proj)
{
  env <- new.env()
  load(proj, envir = env)
  env$Data <- env$Data[0, ]
  save(list = ls(envir = env), file = proj)
}