library(raster)
library(MODIS)
library(here)
library(lubridate)

here::here()

# set NASA login credentials
#EarthdataLogin(usr = 'efluet', pwd = 'isthis1ANYSAFER')

#Set or Retrieve Permanent MODIS Package Options
# MODISoptions(localArcPath= "../../data/modis",
#              outDirPath= "../../data/modis",
#              dataFormat = "Gtiff")

MODISoptions(localArcPath= "C:/Users/efluet/modis",
             outDirPath= "C:/Users/efluet/modis",
             dataFormat = "Gtiff")



MODISoptions()


getProduct("MOD11C3")  #  ("MOD11A2")("MOD11C1")
# diff MOD11 products:
# https://modis.gsfc.nasa.gov/data/dataprod/mod11.php




####  get nighttime  -----------------------------------------------------------

# it starts in march 2000
d1 = "2000-02-01"
d2 = "2000-02-28"

# create empty raster
LST_Night_CMG_stack <- raster::stack()


#for (i in seq(123,131)){
#for (i in seq(123,201)){
for (i in seq(119,143)){
  
  startdate <- ymd(d1) %m+% months(i) #years(i)
  enddate <- ymd(d2) %m+% months(i) #years(i+1)
  
  print(paste0("start date:   ", startdate))
  print(paste0("enddate date: ", enddate))
  
  
  # # download data MOD11C3 Monthly CMG LST
  LST_Night_CMG = runGdal("MOD11C3", 
                          collection = "006",
                          #job="upscale",
                          tileH = 8, tileV = 7,
                          begin = startdate, end = enddate,
                          SDSstring = "00000100000000000")
  
  
  l <- unlist(LST_Night_CMG)
  
  #paste(c(strsplit(",MOD11C3.006.2000.04.01", split="[.]")[[1]][3:5]),"-")
  
  # convert to raster stacks
  st <- raster::stack(l)
  
  names(st) <- c(names(LST_Night_CMG$MOD11C3.006))
  
  print(names(st))
  
  # aggregate to 0.25 deg resolution
  # convert to Celcius
  y <- aggregate(st, fact=5, fun=mean, expand=TRUE, na.rm=TRUE) * 0.02 - 273
  
  # add to stack
  LST_Night_CMG_stack <- raster::stack(LST_Night_CMG_stack, y)
  

}


unlink("C:/Users/efluet/modis", recursive = T)
unlink("C:/Users/efluet/modis", recursive = T)


# # delete the temp folder directories
# unlink("../../data/modis/MODIS", recursive = T)
# unlink("../../data/modis/upscale", recursive = T)



#==============================================================================#
####  Get Daytime temperature      ---------------------------------------------
#==============================================================================#

# create empty raster
LST_Day_CMG_stack <- raster::stack()


#ymd(s) #+ %+m% year(1)

for (i in seq(119,143)){
  
  startdate <- ymd(d1) %m+% months(i) #years(i)
  enddate <- ymd(d2) %m+% months(i) #years(i+1)
  
  # print(paste0("start date:   ", startdate))
  # print(paste0("enddate date: ", enddate))
  
  
  # # download data MOD11C3 Monthly CMG LST
  LST_Day_CMG = runGdal("MOD11C3", 
                          collection = "006",
                          #job="upscale",
                          tileH = 8, tileV = 7,
                          begin = startdate, end = enddate,
                          SDSstring = "10000000000000000")
  
  
  l <- unlist(LST_Day_CMG)
  
  #paste(c(strsplit(",MOD11C3.006.2000.04.01", split="[.]")[[1]][3:5]),"-")
  
  # convert to raster stacks
  st <- raster::stack(l)
  
  names(st) <- c(names(LST_Day_CMG$MOD11C3.006))
  
  print(names(st))
  
  # aggregate to 0.25 deg resolution
  # convert to Celcius
  y <- aggregate(st, fact=5, fun=mean, expand=TRUE, na.rm=TRUE) * 0.02 - 273
  
  # add to stack
  LST_Day_CMG_stack <- raster::stack(LST_Day_CMG_stack, y)
  

}

# delete the temp folder directories
unlink("C:/Users/efluet/modis", recursive = T)
unlink("C:/Users/efluet/modis", recursive = T)


# save the rasters
saveRDS(LST_Day_CMG_stack, "../../data/modis_processed/LST_Day_CMG_stack.rds")
saveRDS(LST_Night_CMG_stack, "../../data/modis_processed/LST_Night_CMG_stack.rds")




#==============================================================================#
###  Make  Latitude  grid    ---------------------------------------------------
#==============================================================================#
# 
# lat <- LST_Day_CMG_stack[[1]]
# 
# 
# # Convert raster to SpatialPointsDataFrame
# r.pts <- rasterToPoints(lat, spatial=TRUE)
# # proj4string(r.pts)
# # Assign coordinates to @data slot, display first 6 rows of data.frame
# r.pts@data <- data.frame(r.pts@data,lat=coordinates(r.pts)[,2])                         
# head(r.pts@data)
# 
# 
# lat@data@values <- coordinates(lat)[,2]
# 
# plot(lat)
# saveRDS(lat, "../../data/modis_processed/lat_grid.rds")

