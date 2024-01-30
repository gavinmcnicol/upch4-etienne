#  Export the upscaling into a NetCDF file.
# - convert units from mgCH4 to gC m-2 d-1
# - time units (months since YYYY-MM-DD)  2003-2013  (11 years, 132 months)
# - Save mean  & range
#####################################################################

library(raster)
library(ncdf4)

# Read flux grid
setwd('../output/results/grids/v03')
infile_min = stack('pred_v03_gCm2day_em1_min.tif')
infile_mean = stack('pred_v03_gCm2day_em1_mean.tif')
infile_max = stack('pred_v03_gCm2day_em1_max.tif')



### TOWERS TEST ----------------------------------------------------------------
bams_towers <- read.csv('../../../../data/towers/db_v2_site_metadata_Feb2020.csv') %>%
			   filter(IGBP %in% c('WET','WSA'))
xy <- bams_towers[,c('LON','LAT')]
bams_towers_pts <- SpatialPointsDataFrame(coords = xy, data = bams_towers)

infile_mean <- infile_mean[[1:60]]
# Extract raster values @ pts
bams_towers_ex <- data.frame(raster::extract(infile_mean, bams_towers_pts))
bams_towers_ex <- bams_towers_ex[complete.cases(bams_towers_ex), ]


bams_towers_ex_ls <- unlist(array(bams_towers_ex))
mean(bams_towers_ex_ls)
bams_towers_ex %>% summarise_each(mean, na.rm=T)
###------------------------------------------------------------------------------



# Set name for output
outfile <- 'ml_fch4_gCm2day_m1_t180_b50.nc'

# Make list of dates
date_ls <- seq(as.Date('2001/01/01'), by = 'month', length.out = nlayers(infile_mean))

# Longitude and Latitude data
xvals <- unique(values(init(infile_mean, "x")))
yvals <- unique(values(init(infile_mean, "y")))
nx <- length(xvals)
ny <- length(yvals)
lon <- ncdim_def("longitude", "degrees_east", xvals)
lat <- ncdim_def("latitude", "degrees_north", yvals)
mv <- -999  # Missing value to use


# Time component
time <- ncdim_def(	name = "time", 
					units = "Months since 2003/01/01", 
					vals = 0:(nlayers(infile_mean)-1), 
					unlim = FALSE,
					longname = "Number of months elapsed since 2001/01/01")

# Define flux variables
var_flux_min <- ncvar_def(name = "Methane emissions - ensemble minimum",
												units = "gC m^-2 day^-1",
												dim = list(lon, lat, time),
												longname = "Minimum of random forest ensemble for wetland methane flux scaled by wetland area",
												missval = mv,
												compression = 9)

var_flux_mean <- ncvar_def(name = "Methane emissions - ensemble mean",
												units = "gC m^-2 day^-1",
												dim = list(lon, lat, time),
												longname = "Mean of random forest ensemble for wetland methane flux scaled by wetland area",
												missval = mv,
												compression = 9)

var_flux_max <- ncvar_def(name = "Methane emissions - ensemble maximum",
												units = "gC m^-2 day^-1",
												dim = list(lon, lat, time),
												longname = "Maximum of random forest ensemble for wetland methane flux scaled by wetland area",
												missval = mv,
												compression = 9)




# Add the variables to the file
ncout <- nc_create(outfile, list(var_flux_min, var_flux_mean, var_flux_max))
print(paste("The file has", ncout$nvars,"variables and ", ncout$ndim," dimensions."))

# Add some global attributes
ncatt_put(ncout, 0, "Title", "Methane flux from wetlands upscaled with random forest from the FLUXNET-CH4 network of eddy-covariance towers")
ncatt_put(ncout, 0, "Author", "Gavin McNicol, Etienne Fluet-Chouinard, Sara Knox, Zutao Ouyang, Rob Jackon & collaborators; Stanford University")
ncatt_put(ncout, 0, "Version", "v0.3 - Preliminary version using 'final 13 predictors model")
ncatt_put(ncout, 0, "Created on", date())

# Place the precip and tmax values in the file
# need to loop through the layers to get them 
# to match to correct time index
for (i in 1:nlayers(infile_mean)) { 
	print(i)
	#message("Processing layer ", i, " of ", nlayers(prec))

	ncvar_put(nc = ncout, 
						varid = var_flux_min, 
						vals = values(infile_min[[i]]), 
						start = c(1, 1, i), 
						count = c(-1, -1, 1))

	ncvar_put(nc = ncout, 
						varid = var_flux_mean, 
						vals = values(infile_mean[[i]]), 
						start = c(1, 1, i), 
						count = c(-1, -1, 1))

	ncvar_put(nc = ncout, 
						varid = var_flux_max, 
						vals = values(infile_max[[i]]), 
						start = c(1, 1, i), 
						count = c(-1, -1, 1))
}
# Close the netcdf file when finished adding variables
nc_close(ncout)



# /----------------------------------------------------------------------------------------
# Reopen file to check
a <- nc_open(outfile)
a



# ncatt_put(ncout, 0, "Source", "Some example data from the raster package")
# ncatt_put(ncout, 0, "References", "See the raster package")

# /----------------------------------------------------------------------------#
#/   SAVE TO NETCDF                                       ------
# writeRaster(infile, 
#             paste0('../output/results/wetloss/grid/remwet_tot_stack_0.5deg_serial_', params_type,'.nc'), 
#             overwrite=TRUE, 
#             format="CDF", 
#             varname="Temperature", 
#             varunit="Mkm2", 
#             longname="Million square kilometers (10^6 km^2)", 
#             xname="Longitude",   
#             yname="Latitude",
#             zname="Years between 1700-2000 in 10 year intervals",
#             zunit="numeric")

# # /--------------------------------------------------------------------------#
# #/ make function defining netcdf variable  

# wet_res_x = 0.25
# wet_res_y = 0.25

# londim  <- ncdim_def("Longitude","Degrees East",  seq(-180+wet_res_x/2, 180-wet_res_x/2, wet_res_x)) 
# latdim  <- ncdim_def("Latitude" ,"Degrees North", seq(-90+wet_res_y/2,  90-wet_res_y/2,  wet_res_y)) 
# timedim <- ncdim_def("Time", 'Year', hyde_yrs)
# nx = 360/ wet_res_x
# ny = 180/ wet_res_y
# var_unit = "km^2"
# fillvalue <- -999


# define_ncdf_var <- function(var_name, var_unit){
	
#   # define variables
#   temp <- ncvar_def(var_name, 
#                     var_unit, 
#                     list(londim, latdim, timedim), 
#                     fillvalue, 
#                     var_name, 
#                     prec="single")
#   return(temp) }



# #/    Create the netcdf variable for each HYDE vars                     
# var_ls_lu_woverlaps_symbols <-  purrr::map(as.list(var_ls_lu_woverlaps), ~define_ncdf_var(., var_unit))


# o <- "./output/results/hyde_resampled/"
# #ncoutfile <- paste0("hyde32_", wet_res_y,"_allvars.nc")
# ncoutfile <- paste0(o, "overlay_lu_wet_05deg.nc")
# outncdf <- nc_create(ncoutfile, var_ls_lu_woverlaps_symbols)  # create NetCDF file

# # print dimensions
# print(paste("NCDF has", outncdf$nvars,"variables and ", outncdf$ndim," dimensions."))

