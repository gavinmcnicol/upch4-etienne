# Packages should be installed in the shared $GROUP_HOME 
# To specifying destination path for news packages, 
# I created a .Renviron file in our $GROUP_HOME directory.

# install.packages('tidyverse', repos = "http://cran.us.r-project.org")
# install.packages('ggplot2', repos = "http://cran.us.r-project.org")

library(raster)
library(tidyverse)
library(ggplot2)
library(rgdal)

suppressPackageStartupMessages(library(animation))
suppressPackageStartupMessages(library(caret))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(grid))
suppressPackageStartupMessages(library(gridExtra))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(latticeExtra))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(maptools))
suppressPackageStartupMessages(library(ncdf4))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(ranger))
suppressPackageStartupMessages(library(raster))
suppressPackageStartupMessages(library(rgdal))
suppressPackageStartupMessages(library(R.utils))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(stats))
suppressPackageStartupMessages(library(tidyr))

# get parallel packages
library(foreach)
library(doMC)
library(doParallel)
library(colorspace)
library(rgeos)

library(doParallel)
library(lubridate)
library(tidyr)
library(here)
# setwd(here())

# /----------------------------------------------------------------------------#
#/       Custom functions

# Create function that tests if object exists                      ------
exist <- function(x) { return(exists(deparse(substitute(x))))}

# Increase memory to speed up process, following: www.gis-blog.com/increasing-the-speed-of-raster-processing-with-r-part-13/
rasterOptions(format='GTiff', overwrite=TRUE, maxmemory = 5e+9, progress = 'text')
# R optioin
options(row.names=FALSE, scipen=999, digits=6, stringsAsFactors = FALSE)



# Misc functiton summing raster values
sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}



# # Function converting format & proj 
# WGSraster2dfROBIN <- function(r){
# 	crs(r) <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
# 	r_robin <- projectRaster(r, crs=CRS('+proj=robin'), method='ngb', over=TRUE)
# 	r_robin <- as(r_robin, 'SpatialPixelsDataFrame')
# 	r_robin_df <- as.data.frame(r_robin)
# 	names(r_robin_df) <- c('layer','x','y')
# 	return(r_robin_df)
# 	}



# /----------------------------------------------------------------------------#
#/   Function converting format & proj 
WGSraster2dfROBIN <- function(r){
    library(terra)
    crs(r) <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
    r <- terra::rast(r)
    r_robin <- terra::project(r, '+proj=robin', method='near', mask=T)
    r_robin_df <- as.data.frame(r_robin, xy=TRUE, na.rm=TRUE) 
    return(r_robin_df)
}




# suppressPackageStartupMessages(library(
# 	caret, dplyr, gridExtra, grid, ggplot2, latticeExtra, lubridate,
# 	maptools, ncdf4, stringr, ranger, raster, rgdal, R.utils, tidyr, scales, stats))


# .libPaths()
# 
# ## local creates a new, empty environment to avoid polluting 
# ## the global environment with the object r
# local({ r = getOption("repos")
# r["CRAN"] = "https://cloud.r-project.org/"
# options(repos = r) })
# 
# 
# if (!require("tidyr")) install.packages("tidyr")
# library(tidyr)
# 
# 
# if (!require("devtools")) install.packages("devtools")
# library(ggplot2)
# 
# 
# if (!require("ggplot2")) install.packages("ggplot2")
# library(ggplot2)
# 
# if (!require("Rmpi")) install.packages("Rmpi")
# library(Rmpi)
# 
# 
# # get list of required packages
# list.of.packages <- c("animation",
#                       'doParallel',
#                       "grid",
#                       "ggplot2",
#                       "gridExtra",
#                       "latticeExtra",
#                       "maptools",
#                       "ncdf4",
#                       "lubridate",
#                       "raster",
#                       "rlang",
#                       "rgdal",
#                       "R.utils",
#                       "stringr")
# 
# 
# # install package if not installed
# new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
# if(length(new.packages)) install.packages(new.packages) #, lib="/home/groups/robertj2/R_libs")
# 
# lapply(list.of.packages, require, character.only = TRUE)
# 
