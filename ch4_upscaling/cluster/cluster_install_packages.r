# PAckages should be installed in the shared $GROUP_HOME 
# To specifying destination path for news packages, I created a .Renviron file in our $GROUP_HOME directory.

# The R_libs path can be defined with:
# $ cat << EOF > $HOME/.Renviron
# R_LIBS=~/R_libs
# EOF


#library(animation)
library(ncdf4)
library(gridExtra)
#library(latticeExtra) 
library(grid) 
library(ggplot2)

library(maptools)
library(lubridate)
library(stringr)

library(raster)
library(rgdal)

#library(R.utils)
library(scales)
#library(here)
library(caret)
#library(ranger)
library(stats)



# 
# .libPaths()
# 
# ## local creates a new, empty environment to avoid polluting 
# ## the global environment with the object r
# local({ r = getOption("repos")
# r["CRAN"] = "https://cloud.r-project.org/"
# options(repos = r) })
# 
# 
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
