library(ggplot2)
library(dplyr)
library(tidyr)
library(rgdal)
library(raster)
library(ncdf4)
library(ncdf.tools)
library(stringr)
library(here)
library("colorspace")
#install.packages("devtools")
#devtools::install_github("eliocamp/ggnewscale@v0.1.0")
library("ggnewscale")
here()



sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}



### rasterize teow biomes
source("./data_proc/rasterize_teow.r")



# prep model ensemble             ----------------------------------------------

source("./data_proc/make_gcp_ch4_ensemble.r")


### carbontracker     ----------------------------------------------------------  

# reas and save the long-term
source("./data_proc/carbontracker_annual.r")

# seasonal variability
source("./data_proc/carbontracker_seasonal_variability.r")



### barplot of tower% vs ct_tracker flux     -----------------------------------
source("./plots/barplot_tower_carbontracker.r") 





# Compare topdown bottom up

source("./data_proc/compare_topdown_bottomup.r")


source("./plots/barplot_td_bu_comparison.r")
