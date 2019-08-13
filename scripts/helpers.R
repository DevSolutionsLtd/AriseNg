# helpers.R

# Helper functions

## Self-contained file paths for data directory
dataDirPath <- function(f)
{
  stopifnot(is.character(f))
  file.path(here::here(), 'data', f)
}


## Pick a spreadsheet by its name
spreadsheetName <- function(f) {
  if (!file.exists(f))
    stop("There is no file ", sQuote(f))
  sht <- readxl::excel_sheets(f)
  ind <-
    utils::menu(sht, title = 'Select a spreadsheet')
  sht[ind]
}


# Add a 'remark' column to the data frame with all values initally NAs
add_remark_col <- function(df)
{
  stopifnot(is.data.frame(df))
  suppressPackageStartupMessages(require(dplyr, quietly = TRUE))
  df %>% 
    mutate(remark = NA_character_)
}

# peek at the data frame
see <- function(df)
{
  if (interactive()) {
    stopifnot(is.data.frame(df))
    dplyr::glimpse(df)
  }
}


# Inspect row(s) with bad entries
bad_gender_entry <- function(df, entry)
{
  require(magrittr)
  stopifnot(is.data.frame(df))
  stopifnot(is.character(entry))
  df %>% 
  {
    .[which(.$gender == entry), ]
  }
}

