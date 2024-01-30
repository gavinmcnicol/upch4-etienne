# file with readunlim=FALSE for potentially faster access, and to illustrate
# (below) how to read in the unlimited dimension values.
#
nc <- nc_open(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"),, readunlim=FALSE )


# nc_readone <-  ncvar_get(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"), 
#                      varid="dlwrf", start=[,,1], count=[,,1])
# print(nc_readone)
  # attributes(nc$dim)$names[1])

v3      <- nc$var[[1]]
varsize <- v3$varsize
ndims   <- v3$ndims
nt      <- varsize[ndims]  # Remember timelike dim is always the LAST dimension!

for( i in 1:nt ) {
	# Initialize start and count to read one timestep of the variable.
	start <- rep(1,ndims)	# begin with start=(1,1,1,...,1)
	start[ndims] <- i	# change to start=(1,1,1,...,i) to read timestep i
	count <- varsize	# begin w/count=(nx,ny,nz,...,nt), reads entire var
	count[ndims] <- 1	# change to count=(nx,ny,nz,...,1) to read 1 tstep
	
	data3 <- ncvar_get( nc, v3, start=start, count=count )

	# Now read in the value of the timelike dimension
	timeval <- ncvar_get( nc, v3$dim[[ndims]]$name, start=i, count=1 )

	print(paste("Data for variable",v3$name,"at timestep",i,
		" (time value=",timeval,v3$dim[[ndims]]$units,"):"))
	print(data3)
	}

nc_close(nc)
# }