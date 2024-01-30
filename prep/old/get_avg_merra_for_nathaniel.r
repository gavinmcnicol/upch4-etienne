
# nc = netCDF file
# i = timestep index?
# number  of timesteps
# get_merra_tslice <- function(nc, i, n){


# 	v3      <- nc$var[[2]]
# 	varsize <- v3$varsize
# 	ndims   <- v3$ndims
# 	nt      <- varsize[ndims]  # Remember time dim is always the LAST dimension!
# 	#nt      <- 4

# 	#for( i in 1:nt ) {
# 	# Initialize start and count to read one timestep of the variable.
# 	start <- rep(1,ndims)	# begin with start=(1,1,1,...,1)
# 	# Changed to 241, to start reading in 2000-01, to match SWAMPS-GLWD timeseries
# 	start[ndims] <- i	# change to start=(1,1,1,...,i) to read timestep i
# 	count <- varsize	# begin w/count=(nx,ny,nz,...,nt), reads entire var
# 	count[ndims] <- n	# change to count=(nx,ny,nz,...,1) to read 1 tstep
	
# 	# read data time slice
# 	data3 <- ncvar_get( nc, v3, start=start, count=count )

# 	# Get fill value
# 	fillvalue <- ncatt_get(nc, v3, "_FillValue")

# 	# replace character fillvalue with R's NA
# 	data3[data3 == fillvalue$value] <- NA

# 	# Read value of the timelike dimension
# 	timeval <- ncvar_get( nc, v3$dim[[ndims]]$name, start=i, count=1 )

# 	# print(paste("Data for variable",v3$name,"at timestep",i, " (time value=",timeval,v3$dim[[ndims]]$units,"):"))

# 	r <- stack(t(data3), 
# 				xmn=-180, xmx=180, ymn=-90, ymx=90, 
# 				# xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
# 				crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

# 	r <- flip(r, 'y')

# 	return(r)
# 	}


print(getwd())

# /----------------------------------------------------------------------------#
#/    Read MERRA2 data as raster bricks  

dir = "../data/merra2/monthly/"

# dlwrf <- nc_open(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"), readunlim=FALSE )
# dswrf <- nc_open(paste0(dir, "merra2.0.5d.dswrf.monthly.nc"), readunlim=FALSE )
# pre   <- nc_open(paste0(dir, "merra2.0.5d.pre.monthly.nc"),   readunlim=FALSE )
# pres  <- nc_open(paste0(dir, "merra2.0.5d.pres.monthly.nc"),  readunlim=FALSE )
# spfh  <- nc_open(paste0(dir, "merra2.0.5d.spfh.monthly.nc"),  readunlim=FALSE )
# tmp   <- nc_open(paste0(dir, "merra2.0.5d.tmp.monthly.nc"),   readunlim=FALSE )
print(" - Opened MERRA2 NetCDFs")


# read wet fraction as raster brick
dlwrf <- brick(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"), varname="dlwrf")
dswrf <- brick(paste0(dir, "merra2.0.5d.dswrf.monthly.nc"), varname="dswrf")
pre   <- brick(paste0(dir, "merra2.0.5d.pre.monthly.nc"),   varname="pre")
pres  <- brick(paste0(dir, "merra2.0.5d.pres.monthly.nc"),  varname="pres")
spfh  <- brick(paste0(dir, "merra2.0.5d.spfh.monthly.nc"),  varname="spfh")
tmp   <- brick(paste0(dir, "merra2.0.5d.tmp.monthly.nc"),   varname="tmp")


yr_idx = 240:264  #444
print(yr_idx)

dlwrf_sl <- dlwrf[[yr_idx]]
dswrf_sl <- dswrf[[yr_idx]]
pre_sl   <- pre[[yr_idx]]
pres_sl  <- pres[[yr_idx]]
spfh_sl  <- spfh[[yr_idx]]
tmp_sl   <- tmp[[yr_idx]]


# /----------------------------------------------------------------------------#
#/     Get list of time dimension
#      Time dimension of MERRA2: minutes since 1980-1-1 00:30:00"
t <- nc_open(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"))
minutes_since1980 <- c(t$dim$time$vals)
nc_close(t)

# convert time since 1980 to dates (YYYY-MM)
parseddates <- ymd_hms("1980-1-1 00:30:00") + minutes(minutes_since1980) # %m+%
parseddates <- as.Date(parseddates)

# subset to list starting in 2000-01
parseddatessubset <- parseddates[241:length(parseddates)]

# Save list
# saveRDS(parseddates, '../output/results/parsed_dates.rds')


print(paste0("Loop for:  ", parseddates[240], "  at index: ", 240))

# Returns a stack
# dlwrf_sl <- get_merra_tslice(dlwrf, 240, 10)
# dswrf_sl <- get_merra_tslice(dswrf, i, 10)
# pre_sl   <- get_merra_tslice(pre,   i, 10)
# pres_sl  <- get_merra_tslice(pres,  i, 10)
# spfh_sl  <- get_merra_tslice(spfh,  i, 10)
# tmp_sl   <- get_merra_tslice(tmp,   i, 10)


# Get average of stack for each varirable
dlwrf_avg <- mean(dlwrf_sl)
dswrf_avg <- mean(dswrf_sl)
pre_avg   <- mean(pre_sl)
pres_avg  <- mean(pres_sl)
spfh_avg  <- mean(spfh_sl)
tmp_avg   <- mean(tmp_sl)


# Save average 
writeRaster(dlwrf_avg, '../output/results/merra_avg_grid/dlwrf_avg.tif', options=c('TFW=YES'), overwrite=TRUE)
writeRaster(dswrf_avg, '../output/results/merra_avg_grid/dswrf_avg.tif', options=c('TFW=YES'), overwrite=TRUE)
writeRaster(pre_avg,   '../output/results/merra_avg_grid/pre_avg.tif',   options=c('TFW=YES'), overwrite=TRUE)
writeRaster(pres_avg,  '../output/results/merra_avg_grid/pres_avg.tif',  options=c('TFW=YES'), overwrite=TRUE)
writeRaster(spfh_avg,  '../output/results/merra_avg_grid/spfh_avg.tif',  options=c('TFW=YES'), overwrite=TRUE)
writeRaster(tmp_avg,   '../output/results/merra_avg_grid/tmp_avgr.tif',  options=c('TFW=YES'), overwrite=TRUE)