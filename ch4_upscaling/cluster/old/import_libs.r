
library(animation)
library(latticeExtra) 
library(grid) 
library(ggplot2)
library(gridExtra)
library(maptools)
library(ncdf4)
library(lubridate)
library(raster)
library(rgdal)
library(R.utils)
library(stringr)


# install.packages("reshape2", dependencies="Depends")
# # install.packages("ggplot2", repos='http://cran.us.r-project.org')
# install.packages('doParallel', repos='http://cran.us.r-project.org')

# set home dir
setwd("/home/groups/robertj2/ch4_upscaling")


# get list of required packages
list.of.packages <- c("animation",
                      'doParallel',
                      "grid",
                      "ggplot2",
                      "gridExtra",
                      "latticeExtra",
                      "maptools",
                      "ncdf4",
                      "lubridate",
                      "raster",
                      "rgdal",
                      "R.utils",
                      "stringr")

## local creates a new, empty environment
## This avoids polluting the global environment with the object r
local({
  r = getOption("repos")
  r["CRAN"] = "https://cloud.r-project.org/"
  options(repos = r)
})


list.of.packages <- c("rlang","ggplot2")

# install package if not installed
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, lib="/home/groups/robertj2/R_libs")

lapply(list.of.packages, require, character.only = TRUE)
