# Combine bootstrap outputs (individual timesteps)
# Save as ncdf
library(raster)
library(ncdf4)
library(gtools)


# Loop through members
for (m in c(1:n_members)){

	monthly_dir <- paste0('../output/results/grids/v04/m', m, '/monthly/')
	# ensemble_dir <- paste0('../output/results/grids/v04/m', m)

	# Get list of mean rasters
	mean_ls <- mixedsort(list.files(path = monthly_dir, pattern = 'mean'))
	mean_stack <- stack()

	# Get list of var rasters
	var_ls <- mixedsort(list.files(path = monthly_dir, pattern = 'var'))
	var_stack <- stack()

	# Get list of sd rasters
	sd_ls <- mixedsort(list.files(path = monthly_dir, pattern = 'sd'))
	sd_stack <- stack()



	# Make stacks combining all timesteps
	for (t in c(1:length(mean_ls))){

		print(paste0('t',t))

		mean_stack <- stack(mean_stack, raster(paste0(monthly_dir, '/', mean_ls[t])))
		var_stack  <- stack(var_stack,  raster(paste0(monthly_dir, '/', var_ls[t])))
		sd_stack   <- stack(sd_stack,   raster(paste0(monthly_dir, '/', sd_ls[t])))
		}


	# Crop to same extent as WAD2M;  moced from postprocessing, so that all stacks have same ext. 
	mean_stack <- crop(mean_stack, com_ext)
	sd_stack   <- crop(sd_stack,  com_ext)
	var_stack  <- crop(var_stack, com_ext)


	# /---------------------------------------------------------------#
	#/  Save all three stack into a single NetCDF
	stack_dir <- paste0('../output/results/grids/v04/m', m, '/stack/')
	
	nc_filename <- paste0(stack_dir, 'upch4_v04_m', m, '_nmolm2sec.nc')
	save.as.ncdf(nc_filename, 'nmol m^2 sec^-1', mean_stack, sd_stack, var_stack)

	}




	# # output filename

	# # Longitude and Latitude data
	# xvals <- unique(values(init(mean_stack, "x")))
	# yvals <- unique(values(init(mean_stack, "y")))
	# nx    <- length(xvals)
	# ny    <- length(yvals)
	# lon   <- ncdim_def("longitude", "degrees_east", xvals)
	# lat   <- ncdim_def("latitude", "degrees_north", yvals)

	# # Missing value to use
	# mv <- -999

	# # Time component
	# time <- ncdim_def(name = "Time", 
	# 				  units = "Months since 01/01/2001", 
	# 				  vals = 1:nlayers(mean_stack), 
	# 				  unlim = TRUE,
	# 				  longname = "Months since 01/01/2001")

	# # Define flux variables
	# var_mean <- ncvar_def(name = "mean_ch4",
	# 					  units = "nmol m^2 sec-1",
	# 					  dim = list(lon, lat, time),
	# 					  longname = "mean wetland CH4 flux of predicted 500 bootstraps by random forest",
	# 					  missval = mv,
	# 					  compression = 9)

	# # Define flux variables
	# var_sd <- ncvar_def(name = "sd_ch4",
	# 					  units = "nmol m^2 sec-1",
	# 					  dim = list(lon, lat, time),
	# 					  longname = "standard deviation wetland CH4 flux of predicted 500 bootstraps by random forest",
	# 					  missval = mv,
	# 					  compression = 9)

	# # Define flux variables
	# var_var <- ncvar_def(name = "var_ch4",
	# 					  units = "nmol m^2 sec-1",
	# 					  dim = list(lon, lat, time),
	# 					  longname = "variance wetland CH4 flux of predicted 500 bootstraps by random forest",
	# 					  missval = mv,
	# 					  compression = 9)

	# # Add the variables to the file
	# ncout <- nc_create(nc_filename, list(var_mean, var_sd, var_var))
	# print(paste("The file has", ncout$nvars,"variables"))
	# print(paste("The file has", ncout$ndim,"dimensions"))

	# # add some global attributes
	# ncatt_put(ncout, 0, "Title", "Upscaled CH4 wetland flux")
	# ncatt_put(ncout, 0, "Author", "Gavin McNicol, Etienne Fluet-Chouinard, Sara Knox, Zutao Yang et al.")
	# ncatt_put(ncout, 0, "Comment", "")
	# ncatt_put(ncout, 0, "Version", "Version 0.4")
	# ncatt_put(ncout, 0, "Reference", "")
	# ncatt_put(ncout, 0, "Created on", date())

	# # Place the precip and tmax values in the file 
	# #need to loop through the layers to get them 
	# # to match to correct time index
	# for (i in 1:nlayers(mean_stack)) { 

	# 	print(i)

	# 	#message("Processing layer ", i, " of ", nlayers(prec))
	# 	ncvar_put(nc = ncout, 
	# 			varid = var_mean, 
	# 			vals = values(mean_stack[[i]]), 
	# 			start = c(1, 1, i), 
	# 			count = c(-1, -1, 1))

	# 	ncvar_put(nc = ncout, 
	# 			varid = var_sd, 
	# 			vals = values(sd_stack[[i]]), 
	# 			start = c(1, 1, i), 
	# 			count = c(-1, -1, 1))

	# 	ncvar_put(nc = ncout, 
	# 			varid = var_var,
	# 			vals = values(var_stack[[i]]), 
	# 			start = c(1, 1, i), 
	# 			count = c(-1, -1, 1))
	# 	}

	# # Close the netcdf file when finished adding variables
	# nc_close(ncout)

	# }

# Reopen file to check
# a <- stack(nc_filename, varname='mean_ch4')
# a <- nc_open(nc_filename)
