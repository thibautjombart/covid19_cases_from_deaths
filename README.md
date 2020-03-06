
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




## Disclaimer

This is work in progress, which has not been peer-reviewed yet. Do not use
without consulting me before.
