# Convert the GCP grids to units:  mgCH4m2day
# The models originally cover: 2000-2017;  truncated to 2001-2017

# get list of all the monthly ncdf files;  units: mg m-2 day-1
p <- "../data/comparison/gcp_models/gcp_models_april2020/prescribed/"
gcp_list <- list.files(path = p, pattern=".nc")
gcp_list

# make empty stack
gcp_avg_stack <- stack()

# Subset for testing
i <- gcp_list[8]



# /---------------------------------------------------------------#
#/  GCP MODELS UNITS:  gCH4/m2/month  
#  Convert to 
gCH4.m2.month.to.mgCH4m2day <- function(x){ x * 1000 / 30 }  #* 1e-9 * 16.04246 * 1000 *86400 }

# Apply unit conv &  Scale by wetland area
run.gCH4.m2.month.to.mgCH4m2day <- function(instack){ 
	stack_mgCH4m2day <- calc(instack, fun=gCH4.m2.month.to.mgCH4m2day)
	# stack_mgCH4m2day <- overlay(stack_mgCH4m2day, Aw_m2, pixarea_m2, fun=function(s, Aw_m2, pixa) s * Aw_m2 / pixa )
	return(stack_mgCH4m2day) }



t_start = 12
t_end = 228

# /------------------------------------------------------
#/ Loop through each model
for (i in gcp_list){

	print(i)  # Print ticker

	# Read ch4 flux from NCDF as raster
	r <- brick(paste0(p, i), varname = "ech4", band = seq(t_start, t_end))

	# Aggregate from 0.5 to 1 deg (for comparison maps)
	#  MAY2021 - WHY AGGREGATE TO 1DEG? INSTEAD DISAGGREGATE TO 0.5DEG?
	# r <- aggregate(r, fact=2, fun=mean, expand=TRUE, na.rm=TRUE)

	r <- run.gCH4.m2.month.to.mgCH4m2day(r)

	# Replace all NAs by zero, for averaging yearly fluxes
	r[r==NA] <- 0

	# Make long term average of monthly timeseries
	r <- calc(r, fun = mean, na.rm = T)

	# Add raster to temporary stack (used for averaging the ensemble)
	gcp_avg_stack <- stack(gcp_avg_stack, r)


	# /---------------------------------------------------
	#/ Save indiv rasters

	# Remove extension from list of filenames
	i_noext <- tools::file_path_sans_ext(i)

	# Make output filename
	f_out <- paste0('../output/results/grids/gcp_models/', i_noext, '_mgCH4m2day_2001_2017.tif')

	# Save to file
	writeRaster(r, f_out, overwrite=T)

}


# /----------------------------------------------------------------------------
#/  Calculate the average of all models
gcp_ens_avg <- calc(gcp_avg_stack, fun = mean, na.rm = T)

# Save to file
writeRaster(gcp_ens_avg, '../output/results/grids/gcp_models/gcp_avg_mgCH4m2day_2001_2015.tif')

