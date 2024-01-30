# read in ESA ACTIVE soil moisture data

library(ncdf4)
library(raster)
library(dplyr)

library(here)
here()

#==============================================================================#
###        ACTIVE                         --------------------
#==============================================================================#

# list all ncdf in folder
p <- "../data/esa_soil_moisture/ACTIVE/2000/"
lf <- list.files(path = p, pattern = ".nc")

# read ncdf file
#smm_activ <- nc_open(paste0(p, lf[33]))
# read in ESA ACTIVE soil moisture data

# create empty raster stack
smm_activ_stack <- stack()

# loop through files
for (i in seq(1, 30)){  # length(lf)
  
  # print ticker
  print(lf[i])
  
  # read in raster
  r <- raster(paste0(p, lf[i]),  
              varname = "sm")
  
  # set projection
  proj4string(r)=CRS("+init=EPSG:4326")
  
  # add raster to the stack
  smm_activ_stack <- stack(smm_activ_stack, r)
}

# calculate mean value
smm_activ_mean <- calc(smm_activ_stack, fun = mean, na.rm = T)

# calculate mean value
smm_activ_min <- calc(smm_activ_stack, fun = min, na.rm = T)

# calculate number of observations
smm_activ_count <- calc(smm_activ_stack, fun=function(x){sum(x > 1, na.rm=T)})





#==============================================================================#
###       COMBINED                          ------------------------------------
#==============================================================================#

# list all ncdf in folder
p <- "../data/esa_soil_moisture/COMBINED/2000/"
lf <- list.files(path = p, pattern = ".nc")

# read ncdf file
# smm_comb <- nc_open(paste0(p, lf[33]))

# read in raster
#smm_comb <- raster(paste0(p, lf[1:30]), varname = "sm")



# create empty raster stack
smm_comb_stack <- stack()

# loop through files
for (i in seq(183, 213)){  # length(lf)
  
  # print ticker
  print(lf[i])
  
  # read in raster
  r <- raster(paste0(p, lf[i]),  
              varname = "sm")
  
  # set projection
  proj4string(r)=CRS("+init=EPSG:4326")
  
  # add raster to the stack
  smm_comb_stack <- stack(smm_comb_stack, r)
}

# calculate mean value
smm_comb_mean <- calc(smm_comb_stack, fun = mean, na.rm = T)




#==============================================================================#
###   GIEMS  w/  NAN        ------------------------
#==============================================================================#

# read in giems table as dataframe
giemsNaN <- data.frame(read.table("../data/giemsNaN/giemsNaN.txt",
                                  header = FALSE, sep = "", dec = "."))

# create list of colnames
giems_time <- c("ID","Lat","Long")

# loop through years
for (y in seq(1993, 2007)){
  # loop through months
  for (m in seq(01, 12)){
    # add a 0 if value only one digit long
    if (m < 10){ m = paste0("0",m)}
  # append to list
  giems_time <- c(giems_time, paste0(y,m))  
  }
}


# set column names
names(giemsNaN) <- giems_time

# Replace the NaN string by R-read NA
giemsNaN[giemsNaN=="NaN"] <- NA

# drop the ID column
giemsNaN <- giemsNaN[,c(2:183)]


# select one columm
# 93 is july 2000
giemsNaN2 <- giemsNaN[c(2,1,93)]






## Fit GIEMS points to 
r <- raster(extent(-180, 180, -90, 90), ncol=1440, nrow=720, CRS("+init=EPSG:4326"))


# you need to provide a function 'fun' for when there are multiple points per cell
# alternative CRS:EASE grid  -      CRS("+init=EPSG:3410")
giemsNaN_rast <- rasterize(giemsNaN2[, 1:2], r, giemsNaN2[,3], fun=mean)

# convert to fraction of gridcell
giemsNaN_rast <- giemsNaN_rast / area(r) * 100
giemsNaN_rast[giemsNaN_rast > 100] <- 100


names(giemsNaN_rast) <- "giemsNaN_rast"


#==============================================================================#
###   GET ANCILLARY DATA                 ------------------------------------
#==============================================================================#


#  Wetland fraction
p <- "../data/esa_soil_moisture/ancillary/ESACCI-SOILMOISTURE-WETLAND_FRACTION_V01.1.nc"
a <- nc_open(p)
glwdfrac <- raster(p, varname = "wetland_fraction")



#  VOD
p <- "../data/esa_soil_moisture/ancillary/ESACCI-SOILMOISTURE-AMSRE_D_MEAN_VOD_069_2002_2011.nc"
a <- nc_open(p)
vod <- raster(p, varname = "vod")


#  Porosity
p <- "../data/esa_soil_moisture/ancillary/ESACCI-SOILMOISTURE-POROSITY_V01.1.nc"
a <- nc_open(p)
porosity <- raster(p, varname = "porosity")

porosity <- porosity / 100
porosity[porosity == -9999.99] <- NA


smm_comb_mean_degsat <- smm_comb_mean / porosity


names(smm_comb_mean_degsat) <- "smm_comb_mean_degsat"

#
# SM (%) =  SM_vol (m3m-3) / porosity_vol (m3m-3).




#==============================================================================#
###     COMPARISON              --------------
#==============================================================================#

# stack the layers to compare
comp_stack <- stack(giemsNaN_rast, smm_comb_mean_degsat, glwdfrac, vod)


# convert to table
comp_stack_pts <- as.data.frame(comp_stack) %>%
                  filter(complete.cases(.))



# make scatterplot
library(ggplot2)


ggplot(comp_stack_pts) +
  geom_point(aes(x=giemsNaN_rast, 
                 y=smm_comb_mean_degsat, 
                 color=Vegetation.Optical.Depth.Mean), size=0.9) +
  
  xlab("Fraction inundated GIEMS") +
  ylab("Degree of saturation (ESA SSM ACTIVE)") +
  ggtitle(paste0("January 2000 ", " (n= ", nrow(comp_stack_pts), ")")) +
  scale_color_gradientn(colours = rev(terrain.colors(4))) +
  
  theme_bw()




### save plot
ggsave("../output/figures/scatter_esassm_giems_vod.png",
       width=190, height=120, dpi=300, units='mm', type = "cairo-png")

dev.off()

# round_any = function(x, accuracy, f=round){f(x/ accuracy) * accuracy}
# giemsNaN2$Long <- round_any(giemsNaN2$Long, 0.25)
# giemsNaN2 <- giemsNaN2[giemsNaN2[,1] != max(giemsNaN2[,1], na.rm=T) ,]
# points <- SpatialPointsDataFrame(coords=giemsNaN2[,c('Long','Lat')], data=giemsNaN2[3])
# pixels <- SpatialPixelsDataFrame(points, tolerance = 0.1, points@data, proj4string= CRS("+init=EPSG:4326"))
# raster <- raster(x=pixels[,'199301'])
# plot(raster)




