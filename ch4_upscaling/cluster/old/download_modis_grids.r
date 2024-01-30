###  Get gridded predictors and converting to monthly 0.25deg grids


library(devtools)
devtools::install_github('babaknaimi/rts', force=T)

library(rts)
library(raster)
library(RCurl)
library(here)
here::here()


# Set authentication credentials on https://urs.earthdata.nasa.gov/
setNASAauth(username='efluet',password='isthis1ANYSAFER', update=T) 


# print product list:
modisProducts(version=5)
modisProducts(version=6)
modisProducts(version=NULL) # both versions



# setNASAauth("yourNASAlogin", "yourNASApassword", update = T) # authenticates at NASA's server
# > username and password are successfully updated...!
ModisDownload(x='MOD13A3',h=c(25,26),v=c(06,06),dates=c('2013.01.01','2013.12.31'), mosaic=F, proj=F)



#------------------------------------------------------------


getMODIS(x="MOD11A2",h=c(25,26),v=c(06,06), dates=c('2013.01.01','2013.12.31'), forceReDownload=TRUE,ncore='auto')



source("./ModisDownload.R")

library(sp)
library(bitops)
library(raster)
library(RCurl)
library(rgdal)
#setwd('D:/MODIS_Download_R')
modisProducts() 

#------------------------------------------------------------


### set the wanted layer
#  MOD11A2    Terra Land Surface Temperature & Emissivity  Tile      1000m    8 day
x="MOD11A2"

ModisDownload(x=x,h=c(25,26),v=c(06,06),dates=c('2013.01.01','2013.12.31'))


ModisDownload(x=x, h=c(17), v=c(4,5), 
              dates=c('2015.01.01','2015.04.15'),
              MRTpath= 'd:/MRT/bin', #'./data/modis',
              mosaic=T,
              proj=T,
              bands_subset="0 1 0 0 0 0", 
              proj_type="UTM",
              #proj_params="-3 0 0 0 0 0 0 0 0 0 0 0 0 0 0",
              #utm_zone=30,
              datum="WGS84",
              pixel_size=1000)


# Same as above command, but it spatially subsets the images into the specified box (UL and LR):

ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),MRTpath='d:/MRT/bin',
              mosaic=T,proj=T,UL=c(-42841.0,4871530.0),LR=c(1026104,3983860), 
              bands_subset="0 1 0 0 0 0", proj_type="UTM",
              proj_params="-3 0 0 0 0 0 0 0 0 0 0 0 0 0 0",utm_zone=30,datum="WGS84",
              pixel_size=1000)



## Not run:
file <- system.file("external/ndvi", package="rts")
ndvi <- rts(file) # read the ndvi time series from the specified file
ndvi
ndvi.y <- apply.monthly(ndvi, mean) # apply mean function for each year
ndvi.y
ndvi.q <- apply.quarterly(ndvi,sd) # apply sd function for each quarter of years
ndvi.q




#x=3 # or x="MOD14A1"

# download 4 tiles (h14v04, h14v05, h15v04, h15v05) in single date (2011.05.01)

# Following command only downloads the source HDF images, no mosaic and no projection

ModisDownload(x=x,h=c(17,18),v=c(4,5),dates='2011.05.01',mosaic=F,proj=F)


# alternatively, you can use modisHDF to download only HDF images:

modisHDF(x=x,h=c(17,18),v=c(4,5),dates='2011.05.01')

# same as the above command, but downloads all available images in 2011:

ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.01.01','2011.12.31'))

#------

# Downloads selected tiles, and mosaic them, but no projections:

ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),
              MRTpath='d:/MRT/bin',mosaic=T,proj=F)

#--- alternatively, you can first download the HDF images using getMODIS, 
#and then mosaic them using mosaicHDF!

# Downloads selected tiles, and mosaic, reproject them in UTM_WGS84, zone 30 projection and 
#convert all bands into Geotif format (the original HDF will be deleted!):

ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),MRTpath='d:/MRT/bin',
              mosaic=T,proj=T,proj_type="UTM",utm_zone=30,datum="WGS84",pixel_size=1000)

# Same as above command, but only second band out of 6 bands will be kept. (You do not need 
#to specify proj_params when "UTM" is selected as proj_type and the zone also is specified,
#but for other types of projections you do).

ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),MRTpath='d:/MRT/bin',
              mosaic=T,proj=T, bands_subset="0 1 0 0 0 0", proj_type="UTM",
              proj_params="-3 0 0 0 0 0 0 0 0 0 0 0 0 0 0",utm_zone=30,
              datum="WGS84",pixel_size=1000)


# Same as above command, but it spatially subsets the images into the specified box (UL and LR):

ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),MRTpath='d:/MRT/bin',
              mosaic=T,proj=T,UL=c(-42841.0,4871530.0),LR=c(1026104,3983860), 
              bands_subset="0 1 0 0 0 0", proj_type="UTM",
              proj_params="-3 0 0 0 0 0 0 0 0 0 0 0 0 0 0",utm_zone=30,datum="WGS84",
              pixel_size=1000)



## End(Not run)



# library(MODISTools)
# products <- mt_products()
# head(products)
# 
# 
# 
# bands <- mt_bands(product = "MOD11A2")
# head(bands)
# 
# 
# # Land surface temp. night	LSTn	MOD11A2
# # Land surface temp. day	LSTd	MOD11A2
# # Enhanced vegetation index	EVI		MOD13Q1
# # Simple ratio water index	SRWI		MOD09A1
# 
# 
# 
# 
# 
# 
# subset <- mt_subset(product = "MOD11A2",
#                     # lat = 40,
#                     # lon = -110,
#                     band = "LST_Day_1km",
#                     start = "2004-01-01",
#                     end = "2004-06-01",
#                     km_lr = 0,
#                     km_ab = 0,
#                     site_name = "testsite",
#                     internal = TRUE)
# head(subset)