# Combine bootstrap outputs (individual timesteps)
# Save as ncdf


library(raster)
library(ncdf4)
library(gtools)

for (m in c(1:8)){

	ensemble_dir <- paste0('../output/results/grids/v03/m', m)

	# Initialize stacks
	mean_ls <- mixedsort(list.files(path = ensemble_dir, pattern = 'mean'))
	mean_stack <- stack()

	var_ls <- mixedsort(list.files(path = ensemble_dir, pattern = 'var'))
	var_stack <- stack()

	sd_ls <- mixedsort(list.files(path = ensemble_dir, pattern = 'sd'))
	sd_stack <- stack()


	# Make stacks combining all 180 timesteps
	for (t in c(1:length(mean_ls))){

		print(paste0('t',t))

		mean_stack <- stack(mean_stack, raster(paste0(ensemble_dir, '/', mean_ls[t])))
		var_stack  <- stack(var_stack, raster(paste0(ensemble_dir, '/', var_ls[t])))
		sd_stack   <- stack(sd_stack, raster(paste0(ensemble_dir, '/', sd_ls[t])))
		}


	# /---------------------------------------------------------------#
	#/  Save as NCDF

	# output filename
	nc_filename <- paste0('../output/results/grids/v03/pred_v03_nmolm2sec_m', m, '.nc')

	# Longitude and Latitude data
	xvals <- unique(values(init(mean_stack, "x")))
	yvals <- unique(values(init(mean_stack, "y")))
	nx    <- length(xvals)
	ny    <- length(yvals)
	lon   <- ncdim_def("longitude", "degrees_east", xvals)
	lat   <- ncdim_def("latitude", "degrees_north", yvals)

	# Missing value to use
	mv <- -999

	# Time component
	time <- ncdim_def(name = "Time", 
					  units = "Months since 01/01/2001", 
					  vals = 1:nlayers(mean_stack), 
					  unlim = TRUE,
					  longname = "Months since 01/01/2001")

	# Define flux variables
	var_mean <- ncvar_def(name = "mean_ch4",
						  units = "nmol m^2 sec-1",
						  dim = list(lon, lat, time),
						  longname = "mean wetland CH4 flux of predicted 500 bootstraps by random forest",
						  missval = mv,
						  compression = 9)

	# Define flux variables
	var_sd <- ncvar_def(name = "sd_ch4",
						  units = "nmol m^2 sec-1",
						  dim = list(lon, lat, time),
						  longname = "standard deviation wetland CH4 flux of predicted 500 bootstraps by random forest",
						  missval = mv,
						  compression = 9)

	# Define flux variables
	var_var <- ncvar_def(name = "var_ch4",
						  units = "nmol m^2 sec-1",
						  dim = list(lon, lat, time),
						  longname = "variance wetland CH4 flux of predicted 500 bootstraps by random forest",
						  missval = mv,
						  compression = 9)

	# Add the variables to the file
	ncout <- nc_create(nc_filename, list(var_mean, var_sd, var_var))
	print(paste("The file has", ncout$nvars,"variables"))
	print(paste("The file has", ncout$ndim,"dimensions"))

	# add some global attributes
	ncatt_put(ncout, 0, "Title", "Upscaled CH4 wetland flux")
	ncatt_put(ncout, 0, "Author", "Gavin McNicol, Etienne Fluet-Chouinard, Sara Knox, Zutao Yang et al.")
	ncatt_put(ncout, 0, "Comment", "")
	ncatt_put(ncout, 0, "Version", "Version 0.3")
	ncatt_put(ncout, 0, "Reference", "")
	ncatt_put(ncout, 0, "Created on", date())

	# Place the precip and tmax values in the file 
	#need to loop through the layers to get them 
	# to match to correct time index
	for (i in 1:nlayers(mean_stack)) { 

		print(i)

		#message("Processing layer ", i, " of ", nlayers(prec))
		ncvar_put(nc = ncout, 
				varid = var_mean, 
				vals = values(mean_stack[[i]]), 
				start = c(1, 1, i), 
				count = c(-1, -1, 1))

		ncvar_put(nc = ncout, 
				varid = var_sd, 
				vals = values(sd_stack[[i]]), 
				start = c(1, 1, i), 
				count = c(-1, -1, 1))

		ncvar_put(nc = ncout, 
				varid = var_var,
				vals = values(var_stack[[i]]), 
				start = c(1, 1, i), 
				count = c(-1, -1, 1))
		}

	# Close the netcdf file when finished adding variables
	nc_close(ncout)

	}

# Reopen file to check
# a <- stack(nc_filename, varname='mean_ch4')
# a <- nc_open(nc_filename)
