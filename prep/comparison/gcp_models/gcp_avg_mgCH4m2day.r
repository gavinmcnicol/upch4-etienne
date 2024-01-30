# Convert the GCP grids to units:  mgCH4m2day
# The models originally cover: 2000-2017;  truncated to 2001-2017

# get list of all the monthly ncdf files;  units: mg m-2 day-1
p <- "../data/comparison/gcp_models/gcp_models_april2020/prescribed/"
gcp_list <- list.files(path = p, pattern=".nc")

# Subset for testing
# i <- gcp_list[8]



# /---------------------------------------------------------------#
#/  GCP MODELS UNITS:  gCH4/m2/month  
#  Convert to 
gCH4.m2.month.to.mgCH4m2day <- function(x){ x * 1000 / 30 }  #* 1e-9 * 16.04246 * 1000 *86400 }

# Apply unit conv &  Scale by wetland area
run.gCH4.m2.month.to.mgCH4m2day <- function(instack){ 
	stack_mgCH4m2day <- calc(instack, fun=gCH4.m2.month.to.mgCH4m2day)
	# stack_mgCH4m2day <- overlay(stack_mgCH4m2day, Aw_m2, pixarea_m2, fun=function(s, Aw_m2, pixa) s * Aw_m2 / pixa )
	return(stack_mgCH4m2day) }



t_start = 13  
t_end = 216  # 228

# make empty stack
gcp_temp_stack <- stack()
gcp_tsavg_stack  <- stack()


# /-------------------------------------------------------
#/  Loop through timesteps
for (t in t_start:t_end) {



	# /------------------------------------------------------
	#/ Loop through each model
	for (i in gcp_list){

		print(paste0('t: ', t, '  i: ', i))  # Print ticker

		# Read ch4 flux from NCDF as raster
		r <- raster(paste0(p, i), varname = "ech4", band = t)

		# Aggregate from 0.5 to 1 deg (for comparison maps)
		#  MAY2021 - WHY AGGREGATE TO 1DEG? INSTEAD DISAGGREGATE TO 0.5DEG?
		# r <- aggregate(r, fact=2, fun=mean, expand=TRUE, na.rm=TRUE)

		r <- run.gCH4.m2.month.to.mgCH4m2day(r)

		# Replace all NAs by zero, for averaging yearly fluxes
		r[r==NA] <- 0

		# Add raster of model i to stack
		gcp_temp_stack <- stack(gcp_temp_stack, r) 

		}

	# Average all models for timestep t
	temp_raster <- calc(gcp_temp_stack, fun = mean, na.rm = T)


	# Add avg raster to time_series stack
	gcp_tsavg_stack <- stack(gcp_tsavg_stack, temp_raster)

	}


# Save avg time-series to file
writeRaster(gcp_tsavg_stack, '../output/comparison/gcp_models/gcp_tsavg_mgCH4m2day_2001_2017.tif')



# /----------------------------------------------------------------------------
#/  Calculate long-term average 

gcp_ltavg_stack <- calc(gcp_tsavg_stack, fun = mean, na.rm = T)
writeRaster(gcp_ltavg_stack, '../output/comparison/gcp_models/gcp_ltavg_mgCH4m2day_2001_2017.tif')

