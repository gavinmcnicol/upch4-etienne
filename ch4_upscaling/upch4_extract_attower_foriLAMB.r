setwd('C:/Users/efluet/Dropbox/upch4/output/results/upscaling/v03')

library(raster)
library(dplyr)

gCm2day <- stack('pred_v03_gCm2day_em1_mean.tif')



#/     Get tower locations                                               -------
bams_towers <- read.csv("../../../../data/towers/BAMS_site_coordinates.csv")

# Convert to pts
xy <- bams_towers[,c(4,3)]
bams_towers_pts <- SpatialPointsDataFrame(coords = xy, data = bams_towers)

# Extract raster values @ pts
bams_towers_ex <- data.frame(extract(gCm2day, bams_towers_pts))

# Bind data cols to extracted values
bams_towers_ex <- cbind(bams_towers_ex, bams_towers)
glimpse(bams_towers_ex)



hist(bams_towers_ex[[5]])

mean(bams_towers_ex$pred_v03_gCm2day_em1_mean.5, na.rm=T)
