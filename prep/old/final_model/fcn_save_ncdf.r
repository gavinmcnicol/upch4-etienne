# /---------------------------------------------------------------#
#/  Save as NCDF

save.as.ncdf <- function(nc_filename, unit_str, mean_stack, sd_stack, var_stack){


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
					  unlim = FALSE,
					  longname = "Months since 01/01/2001")

	# Define flux variables
	var_mean <- ncvar_def(name = "mean_ch4",
						  units = unit_str,
						  dim = list(lon, lat, time),
						  longname = "mean wetland CH4 flux of predicted 500 bootstraps by random forest",
						  missval = mv,
						  compression = 9)

	# Define flux variables
	var_sd <- ncvar_def(name = "sd_ch4",
						  units = unit_str,
						  dim = list(lon, lat, time),
						  longname = "standard deviation wetland CH4 flux of predicted 500 bootstraps by random forest",
						  missval = mv,
						  compression = 9)

	# Define flux variables
	var_var <- ncvar_def(name = "var_ch4",
						  units = unit_str,
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