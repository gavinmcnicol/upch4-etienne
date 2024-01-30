

setwd('../output/results/grids/v02')

# /---------------------------------------------------------------------------#
#/      Read data                                               -------

stack <- brick('pred_flux_stack_v4.tif')

name_ls <- names(stack) # 5184  =  216 * 24

# MAke group label list
groupn = function(n,m){rep(1:m,rep(n/m,m))}
timestep_grp = groupn(length(name_ls), length(name_ls)/24 )


#  Average per 24 RF model per run
f = function(v){tapply(v, timestep_grp, min)}
min_stack = calc(stack, f)

#  Average per 24 RF model per run'
f = function(v, fun){tapply(v, timestep_grp, mean)}
mean_stack = calc(stack, f)

#  Average per 24 RF model per run
f = function(v){tapply(v, timestep_grp, max)}
max_stack = calc(stack, f)


# Save mean, min, max time-series
writeRaster(min_stack, 'rf_min_ch4_monthly_2001_2018.tif')
writeRaster(mean_stack,'rf_mean_ch4_monthly_2001_2018.tif')
writeRaster(max_stack, 'rf_max_ch4_monthly_2001_2018.tif')


# /------------------------------------------------------------------------#
#/     Get wetland area from SWAMPS-GLWD                             -------
#      Do this out of function to avoid repeat

# f <- '../data/swampsglwd/v2/gcp-ch4_wetlands_2000-2017_025deg.nc'   # 216 long
f <- '../../../../data/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc'   # 216 long


# read wet fraction as raster brick 
Fw <- brick(f, varname='Fw')[[13:228]]  # Exclude year 2000

# Crop Fw to match the flux prediction grids
com_ext <- extent(-180, 180,  -56, 85)
Fw <- crop(Fw, com_ext)
extent(Fw) <- com_ext

#   Get pixel area (m^2)
pixarea_m2 <- area(Fw[[1]]) * 10^6

# Convert wetland fraction to  area
Aw = Fw * pixarea_m2

# Fw_mask[Fw_mask == 0] <- NA


# /--------------------------------------------------------------------------#
#/     Convert units of grids from nmol m-2 sec-1  to Tg month-1

min_stack <- brick('rf_min_ch4_monthly_2001_2018.tif')
mean_stack<- brick('rf_mean_ch4_monthly_2001_2018.tif')
max_stack <- brick('rf_max_ch4_monthly_2001_2018.tif')


conv.units <- function(stack){
	# NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
	date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = 216)

	# Conv nmol to Tg
	# assuming 30 day month
	conv <- stack * Aw * 1e-21 * 16.04246 * 2.592e+6
	names(conv) <- date_ls
	return(conv)
	}

min_conv <- conv.units(min_stack)
mean_conv <- conv.units(mean_stack)
max_conv <- conv.units(max_stack)


writeRaster(min_conv, 'rf_generic_min_ch4_tg.tif')
writeRaster(mean_conv,'rf_generic_mean_ch4_tg.tif')
writeRaster(max_conv, 'rf_generic_max_ch4_tg.tif')




# /---------------------------------------------------------------------#
#/      Make TOTAL sums                                         -------

min_sum <- as.data.frame(cellStats(min_conv, sum))
mean_sum<- as.data.frame(cellStats(mean_conv, sum))
max_sum <- as.data.frame(cellStats(max_conv, sum))

# Combine to single df
sum_df <- bind_cols(data.frame(date_ls), min_sum, mean_sum, max_sum)
names(sum_df) <- c('date','min','mean','max')

# Save to CSV file
write.csv(sum_df, '../output/results/upscaled_sum_v02.csv')



# /------------------------------------------------------------------------#
#/   Unweighted monthly composite of flux predictions                 -------
#    unscaled: nmol m-2 sec-1

mean_stack <- brick('rf_mean_ch4_monthly_2001_2018.tif')

# Make list of month groupings
date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = 216)
monthly_composite_grp = month(as.Date(date_ls))

# Take mean, excluding NAs
f = function(v){tapply(v, monthly_composite_grp, mean)}
monthly_mean_nmol_composite = calc(mean_stack, f)

writeRaster(monthly_mean_nmol_composite, 'rf_mean_ch4_monthly_2001_2018_nmol_m2_day_monthly_composite.tif')



# /-----------------------------------------------------------------------
#/   Weighted monthly composite for GIF: of Tg month-1
# tg month-1


mean_conv <- brick('rf_generic_mean_ch4_tg.tif')  # Get Tg grids
# wetland area scaled: mg m-2 day-1

# Make list of month groupings
monthly_composite_grp = month(as.Date(date_ls))

#  Average per 24 RF model per run
f = function(v){tapply(v, monthly_composite_grp, mean)}
monthly_mean_composite = calc(mean_conv, f)


writeRaster(monthly_mean_composite, 'rf_mean_ch4_monthly_2001_2018_tg_month_composite.tif')



# /------------------------------------------------------------------------#
#/   Make monthly composite for GIF: of mg m^2 day                   -------
#  scaled with wetland, then divided by pixel area

mean_comp_tg_month <- brick('rf_mean_ch4_monthly_2001_2018_tg_month_composite.tif')

#   Get pixel area (m^2)
pixarea_m2 <- area(mean_comp_tg_month[[1]]) * 10^6

mean_comp_mg_m2_day <- mean_comp_tg_month * 1e+15 / pixarea_m2 / 30


writeRaster(mean_comp_mg_m2_day, 'rf_mean_ch4_monthly_composite_2001_2018_mg_m2_day.tif')



# /------------------------------------------------------------------------#
#/   Average map  of mg m^2 day                   -------
#  scaled with wetland, then divided by pixel area

# Get wetland-weighted Tg 
mean_conv <- brick('rf_mean_ch4_monthly_2001_2018_tg_month.tif')

#   Get pixel area (m^2)
pixarea_m2 <- area(mean_conv[[1]]) * 10^6

# Convert to mgCH4 m-2 day-1
mean_comp_mg_m2_day <- mean_conv * 1e+15 / pixarea_m2 / 30

# Average the stack, considering NAs as 0s; gives lower values
avg_mg_m2_day <- calc(mean_comp_mg_m2_day, sum, na.rm=TRUE) / 216 


writeRaster(avg_mg_m2_day, 'rf_mean_ch4_2001_2018_mg_m2_day.tif')




# min_conv <- min_stack * Aw * 1e-21 * 16.04246 * 2.592e+6
# mean_conv<- mean_stack * Aw * 1e-21 * 16.04246 * 2.592e+6
# max_conv <- max_stack * Aw * 1e-21 * 16.04246 * 2.592e+6

# NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
# date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = 216)
# names(min_conv) <- date_ls
# names(mean_conv) <- date_ls
# names(max_conv) <- date_ls



# Get function for unit conv
# source('./prep/fcn/fcn_conv_grid_units.r'/)


# # /--------------------------------------------------------------------------#
# #/      Write out to NCDF
# # Saving to RDS doesn't work well for large rasters.
# writeRaster(mean_conv, 'upch4_mean_tg_month.nc', 
#             overwrite=TRUE, format='CDF', varname='upch4', varunit='tg_month', 
#             longname='tg_month -- raster stack to netCDF', 
#             xname='Longitude',   yname='Latitude', zname='Time (Month)')

# writeRaster(min_conv, '../output/results/grid/upch4_min_tg_month.nc', 
#             overwrite=TRUE, format='CDF', varname='upch4', varunit='tg_month', 
#             longname='tg_month -- raster stack to netCDF', 
#             xname='Longitude',   yname='Latitude', zname='Time (Month)')

# writeRaster(max_conv, '../output/results/grid/upch4_max_tg_month.nc', 
#             overwrite=TRUE, format='CDF', varname='upch4', varunit='tg_month', 
#             longname='tg_month -- raster stack to netCDF', 
#             xname='Longitude',   yname='Latitude', zname='Time (Month)')

# print('saved to NCDF')


# Get function
# source('./prep/fcn/fcn_sum_flux_grid.r')
# Apply function
# mean_sum <- sum_stack(mean_conv, date_ls)
# min_sum <- sum_stack(min_conv, date_ls)
# max_sum <- sum_stack(max_conv, date_ls)

# # Add labels
# mean_sum$valtype <- 'mean'
# min_sum$valtype <- 'min'
# max_sum$valtype <- 'max'



# Convert units
# Convert to bricks (to write to NCDF)
# min_conv <- brick( conv_grid_units(min_stack, Aw))
# mean_conv <- brick( conv_grid_units(mean_stack, Aw))
# max_conv <- brick( conv_grid_units(max_stack, Aw))



# # Test plot 
# test_plot <- function(i){
# 	#i = mean_stack[[18]]
# 	d <- as(i, 'SpatialPixelsDataFrame')
# 	d <- as.data.frame(d)
# 	names(d)<- c('layer','x','y')
# 	m <- ggplot(d) +
# 	  geom_tile(aes(x=x, y=y, fill=layer)) +
# 	  coord_equal() 
# 	ggsave('./test_map.png', width=6, height=3.5)
# 	}

