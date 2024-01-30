# /---------------------------------------------------------------------------#
#/   Make raster sum function (shorten)                                   -------

# Misc functiton summing raster values
sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}


# /---------------------------------------------------------------------------#
#/     Sum each raster of stack                                        -------

# s = stack of rasters
# t = list of timesteps
sum_stack <- function(s, t) {
	
	# create empty df
	sum_df <- data.frame(time=as.character(),
						 sum_flux=as.numeric())
	
	# loop through the stack of rasters
	for (i in 1:length(names(s))){

		sum_df <- bind_rows(sum_df,
							data.frame(time = as.character(t[i]), 
							  sum_flux = sum_raster(s[[i]])))

		# Add output grid to stack if it doesnt exitst yet.
		#if (exist(sum_df)) { sum_df <- bind_rows(sum_df, sum_row) } else { sum_df <- sum_row } 
		# sum_row)
	}

	return(sum_df)
}