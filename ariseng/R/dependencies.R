#' ariseng dependencies
#' 
#' @name dependencies
NULL
# The required packages.
dependencies <- c('gWidgets2', 'gWidgets2RGtk2', 'RGtk2', 'DataEntry')
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' @rdname dependencies
#' 
#' @title Fetch the packages needed for the exercise
#'
#' @description Download and install packages required to use this project.
#'
#' @details The function carries out a check as to whether the packages already
#' exist for the current version of R. The packages are:
#' \itemize{
#'   \item \code{gWidgets2}
#'   \item \code{gWidgets2RGtk2}
#'   \item \code{RGtk2}
#'   \item \code{DataEntry}
#' }
#'
#' @importFrom utils install.packages
#'
#' @export
fetch_dependencies <- function()
{
  if (check_dependencies(silent = TRUE))
    return(invisible(NULL))
  absent <- !(dependencies %in% .packages(all.available = TRUE))
  install.packages(dependencies[absent],
                   repos = 'https://cran.rstudio.com',
                   verbose = TRUE)
}
#' 
#' 
#' 
#' 
#' 
#' @rdname dependencies
#' 
#' @title Check required packages
#' 
#' @description Check whether dependencies are available in R.
#' 
#' @details The packages 'gWidgets2', 'gWidgets2RGtk2', 'RGtk2', 'DataEntry'
#' are needed for this package to work. In carrying out the check, informative
#' message can optionally be provided by setting \code{silent = TRUE}.
#' 
#' @param silent logical; whether or not to provide informative messages.
#' Default is \code{FALSE}.
#' 
#' @return \code{TRUE}/\code{FALSE} (invisibly).
#' 
#' @export
check_dependencies <- function(silent = FALSE)
{
  if ((val <- all(dependencies %in% .packages(all.available = TRUE)))) {
    if (!silent)
      message("Required packages are already installed")
  }
  else {
    if (!silent)
      message("Required package(s) missing. Run 'fetch_dependencies()'")
  }
  invisible(val)
}
