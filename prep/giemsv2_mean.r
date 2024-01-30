# read GIEMSv2
# The data are gridded on an equal area grid of 0.25°x0.25° at the equator.
# Each grid cell is 773km2 in surface. The file contains the inundated surface for each month for 24 years (1992-2015) for each pixel on the globe. 

f <- '../data/wetland_area/giems2/wetland_1992_2015_Global_monthly_v2.dat'

d <- read.table(f, sep="	", header = FALSE)


# Create output
out_r <- stack()

### 0.25*0.25 degree resolution and extent -180, 180, -90, 90
  template_r = raster(xmn=-180, xmx=180, ymn=-90, ymx=90, nrows=180*4,ncols=360*4,crs="+init=epsg:4326")
transformTo <- function(r1){  projectRaster(r1,r) }


# 4-288
for(i in c(121:122)){

# EPSG:3410 NSIDC EASE-Grid Global

	p <- SpatialPointsDataFrame(d[c(3,2)], d[(3+i)])
	
	crs(p) <- crs('+init=epsg:4053')  # 6933
	p_r <- spTransform(p, crs('+init=epsg:4326'))

	raster(p_r)
	# projectRaster(r1,r)

	r <- rasterFromXYZ( c(p_rd[c(3,2,(3+i))] , res=c(0.25, 0.25), crs=CRS("+proj=longlat +towgs84=0,0,0"))

	# r <- rasterFromXYZ( d[c(3,2,(3+i))] , res=c(0.25, 0.25), crs=CRS("+proj=longlat +towgs84=0,0,0"))
	

	out_r <- stack(out_r, r)
}


# save
writeRaster(out_r, '../output/results/giems2.tif', overwrite=T)


# The data are gridded on an equal area grid of 0.25°x0.25° at the equator.
# To read the ascii file in fortran:
# c integer icell, imonth,surf(288)
# c real alat,alon
# read(30,*) icell,alat,alon,(surf(imonth),imonth=1,288)
# c icell = for internal use only
# c alat = latitude between -90 and 90 of the center of the pixel
# c alon = longitude between -180 and 180 of the center of the pixel
# c surf(imonth) = inundated surface in km2 for the 773km2 pixel.