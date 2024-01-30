# file with readunlim=FALSE for potentially faster access, and to illustrate
# (below) how to read in the unlimited dimension values.


get_merra_tslice <- function(nc, i){

	print(nc)
	# nc_readone <-  ncvar_get(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"), 
	#                      varid="dlwrf", start=[,,1], count=[,,1])
	# print(nc_readone)
	  # attributes(nc$dim)$names[1])

	v3      <- nc$var[[2]]
	varsize <- v3$varsize
	ndims   <- v3$ndims
	nt      <- varsize[ndims]  # Remember timelike dim is always the LAST dimension!
	nt      <- 4

	#for( i in 1:nt ) {
	# Initialize start and count to read one timestep of the variable.
	start <- rep(1,ndims)	# begin with start=(1,1,1,...,1)
	start[ndims] <- i	# change to start=(1,1,1,...,i) to read timestep i
	count <- varsize	# begin w/count=(nx,ny,nz,...,nt), reads entire var
	count[ndims] <- 1	# change to count=(nx,ny,nz,...,1) to read 1 tstep
	
	# read data time slice
	data3 <- ncvar_get( nc, v3, start=start, count=count )

	# Get fill value
	fillvalue <- ncatt_get(nc, v3, "_FillValue")

	# replace character fillvalue with R's NA
	data3[data3 == fillvalue$value] <- NA

	# Read value of the timelike dimension
	timeval <- ncvar_get( nc, v3$dim[[ndims]]$name, start=i, count=1 )

	print(paste("Data for variable",v3$name,"at timestep",i, " (time value=",timeval,v3$dim[[ndims]]$units,"):"))
	
	data3 <-  flip(t(data3), direction = "x")
	
	r <- raster(t(data3), 
				xmn=-180, xmx=180, ymn=-90, ymx=90, 
				# xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
				crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

	return(r)
	}


# dir = "../data/merra2/monthly/"
# nc <- nc_open(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"), readunlim=FALSE )
# r <- get_merra_tslice(nc, 10)
# print(r)

# nc_close(nc)

# add minutes to the start time to convert to current date
# step_time <- merra2_start_time + minutes(100)