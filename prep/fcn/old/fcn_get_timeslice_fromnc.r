# file with readunlim=FALSE for potentially faster access, and to illustrate
# (below) how to read in the unlimited dimension values.


# nc = netCDF file
# i = timestep index?
get_tslice <- function(nc, i){


	v3      <- nc$var[[2]]
	varsize <- v3$varsize
	ndims   <- v3$ndims
	nt      <- varsize[ndims]  # Remember timelike dim is always the LAST dimension!
	#nt      <- 4

	#for( i in 1:nt ) {
	# Initialize start and count to read one timestep of the variable.
	start <- rep(1,ndims)	# begin with start=(1,1,1,...,1)
	# Changed to 241, to start reading in 2000-01, to match SWAMPS-GLWD timeseries
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

	# print(paste("Data for variable",v3$name,"at timestep",i, " (time value=",timeval,v3$dim[[ndims]]$units,"):"))

	r <- raster(t(data3), 
				xmn=-180, xmx=180, ymn=-90, ymx=90, 
				# xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
				crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

	r <- flip(r, 'y')

	return(r)
	}
