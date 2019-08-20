#' @name save_data
NULL

#' @rdname save_data
#' 
#' @title Save Data from Project Files
#' 
#' @details \emph{dte.file} is the \code{.dte} project file specific to the
#' project.
#' @details \emph{dest} is the directory where the database is to be saved.
#' 
#' @param dte.file Character vector of length 1 - path to the project file
#' @param dest The destination folder. Defaults to working directory.
#' 
#' @import RSQLite
#' 
#' @export
save_data_sql <- function(dte.file, dest = getwd())
{
  env <- new.env()
  load(dte.file, envir = env)
  info <- Sys.info()
  thisComp <- paste(info["nodename"], info["effective_user"], sep = "_")
  dbPath <- file.path(dest, paste0("Arise_Ng_", thisComp, ".sqlite"))
  conx <- dbConnect(SQLite(), dbPath)
  on.exit(dbDisconnect(conx))
  if (!dbIsValid(conx))
    stop("Database connection failed")
  try({
    dbWriteTable(conx, "AriseNigeria", env$Data, overwrite = TRUE)
  })
}