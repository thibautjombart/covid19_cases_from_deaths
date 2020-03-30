[![DOI](https://zenodo.org/badge/244454364.svg)](https://zenodo.org/badge/latestdoi/244454364)

# Using the shiny app

All content below relates to the `app/` folder.

## What this does

Infer the number of circulating COVID-19 cases from newly reported deaths. This
is expected to be useful in places where surveillance has not picked up cases
yet, and new deaths are the only indication that there are more circulating
cases.


## How to use it

### Packages needed

The following instructions will install the packages needed if they are not present on your system:

```r

if (!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
p_load("shiny")
p_load("ggplot2")
p_load("magrittr")
p_load("incidence")
p_load("projections")
p_load("distcrete")
p_load("DT")
p_load_gh("reconhub/reportfactory")

```

Note that you only need to do this once (or not at all, if all these packages
are already on your system).



### Starting the app

To start the app, open R inside this folder and type
`shiny::runApp("death_to_case.R")`. If using Rstudio, make sure you view the app
within a decent web browser by clicking on "Open in Browser".




# Using the 'analyses' reportfactory

This folder contains a
[reportfactory](https://github.com/reconhub/reportfactory) with reports
providing a proof of concept and implementation of the model used for
predicting cases from recent COVID-19 deaths.


## Initial setup

You will first need to install dependencies before compiling the documents in
this factory. We recommend using the latest version of R. Double-click on
`open.Rproj` (or just start R in the `model/` folder) and copy-paste the
following instructions:

```r

if (!require(reportfactory)) remotes::install_github("reconhub/reportfactory")

library(reportfactory)
rfh_load_scripts()
install_deps()

```



## Compiling the reports

 To compile the report, double-click on `open.Rproj` (or just start R
in the `analyses/` folder) and type:

```r

reportfactory::update_reports(clean_report_sources = TRUE)

```

Dated and time-stamped outputs (including the `html` version of the report) will
be generated in `report_outputs`.



## Using the source

The source of the report is an *Rmarkdown* document stored in
`report_sources/`. If you plan on working on your own local copy, we recommend
either using version control systems (e.g. GIT) to track changes, or creating
new versions in `report_sources/` with a more recent date in the file name. Note
that by default, `reportfactory::update_reports()` will always compile the
latest version of reports.



## Disclaimer

This is work in progress, which has not been peer-reviewed yet. Do not use
without consulting me before.
