<!-- README.md is generated from README.Rmd. Please edit that file -->
ariseng
=======

This package of for collecing data on Particpant Registration for the Arise Nigeria Conference, holding in Abuja, Nigeria 22-23 January 2019.

How To Use
----------

### Install R

Install the executable normally. Start R on the command line of Window Powershell with this code

    rterm

If you get an error, add R to the path by going to *WinKey &gt; Advanced System Settings* and then click on *Environment Variable*. Under *System variables*, look for and edit the `Path` by adding this line to already existing variables. For instance, for a 64-bit machine

    C:\Program Files\R\R-3.5.2\bin\x64

If using a machine lower than Windows 10, add it to the `PATH` string and remember to add a semicolon at the end i.e. `;`.

### Install package

After installing R, the `ariseng` package can be installed with the following code:

``` r
if (!requireNamespace('remotes'))
  install.packages('remotes')
remotes::install_github("DevSolutionsLtd/ariseng")
```

### Install project dependencies

The `ariseng` package facilitates installation of dependencies needed for the functioning of the data entry GUI. To perform this step, use the following line of code, whilst following all prompts

``` r
fetch_dependencies()
```

### Collect data settings

The variables of interest have been pre-set in a project file named `arise.dte`. Running the function

``` r
fetch_settings()
```

will make that file available in the working directory, `getwd()`. If the user wants to save the settings to a different directory, a string containing the path to the chosen directory is passed as an argument to `path` i.e.

``` r
fetch_settings(path = 'C:/path/to/save/settings/to/')
```

### Open the data entry form

``` r
library(DataEntry)
DataEntry()
```

------------------------------------------------------------------------

Report any issue to the Maintainer: <victor@dev-solu.com>
