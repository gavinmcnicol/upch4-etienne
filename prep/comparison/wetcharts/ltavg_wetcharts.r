
# WetCHARTs_extended_ensemble.nc4
# Units mg m-2 day-1
# Spatial Resolution: 0.5-degree resolution
# Temporal Resolution: Monthly
# Temporal Coverage: 2001-01-01 to 2015-12-31   - 180 months
# Spatial Extent: (All latitude and longitude given in decimal degrees)
# months since 2001-01-01

print('prepping wetcharts')

# Read in netcdf; # 18 members x 180 months
f <- '../data/comparison/wetcharts/CMS_CH4_1502/data/WetCHARTs_extended_ensemble.nc4'

# Create empty stack
wc_ee_tsavg <- stack()


# /--------------------------------------------------------
#/  loop through the months
for (i in 1:180){

	print(i)

	# Read subset at timestep i
	# Get Extendend Ensemble
	sub <- brick(f, varname='wetland_CH4_emissions', level=i, dims=c(1,2,3,4,5))
    
	# Average ensemble members per timestep
	sub_mean <- calc(sub, fun=mean, na.rm=TRUE)

	print(cellStats(sub_mean, sum, na.rm=T))
	
	# Append on output stack
	wc_ee_tsavg <- stack(wc_ee_tsavg, sub_mean)

	}

# Save time-series average 
writeRaster(wc_ee_tsavg, '../output/comparison/wetcharts/wc_ee_tsavg.tif')

# /-----------------------------------------------------------
#/ Calculate long term average grid 
wc_ee_ltavg <- calc(wc_ee_tsavg, na.rm=TRUE, fun=mean)

writeRaster(wc_ee_ltavg, '../output/comparison/wetcharts/wc_ee_ltavg.tif')
