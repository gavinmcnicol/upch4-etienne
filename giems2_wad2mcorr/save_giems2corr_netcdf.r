
# /---------------------------------------------------------------------------#
#/     set R working directory on cluster                             ---------
# library(here);  here()
rm(list = ls(all.names = TRUE))
setwd('/home/groups/robertj2/upch4/scripts')
#  Load packages & misc functions
source('./prep/load_packages.r')
#  Post-processing function
source('./prep/fcn/fcn_post_rf_processing.r') 
# Get mapping theme
source("./plots/theme/theme_gif_map.r")
source("./plots/theme/line_plot_theme.r")
# Get ancillary map data - FIXED BBOX TEARING 
source("./plots/fcn/get_country_bbox_shp_for_ggplot_map.r")


# /----------------------------------------------------------------------------#
#/ GIEMSv2; reprojected in WGS84; 288 months ; 24 years (1992-2015) 
giems2_a <- stack('../../Chap3_holocene_global_wetland_loss/output/results/natwet/preswet/giems2_aw_v3.tif')[[109:288]]
giems2_a <- giems2_a[[109:288]]
s_out <- giems2_a

# /----------------------------------------------------------------------------#
#/  Read corrected GIEMS
giems2_a_corr <- stack('../output/giems2_corr.tif')



# /----------------------------------------------------------------------------#
#/  output filename
nc_filename <- paste0('../output/giems2_area_wgs84_corr.nc')

# s_out <- data.frame(SpatialPoints(giems2[[1]]))
# glimpse(s_out)

# Longitude and Latitude data
xvals <- unique(values(init(s_out, "x")))
yvals <- unique(values(init(s_out, "y")))
nx <- length(xvals)
ny <- length(yvals)
lon <- ncdim_def("longitude", "degrees_east", xvals)
lat <- ncdim_def("latitude", "degrees_north", yvals)

# Missing value to use
mv <- -999

# Time component
time <- ncdim_def(name = "Time", 
                  units = "Months since 01/01/2001", 
                  vals = 1:180, 
                  unlim = TRUE,
                  longname = "Months since 01/01/2001")

# Define raw GIEMSv2
var_aw_orig <- ncvar_def(name = "original_GIEMSv2_wetland_area",
                    units = "km^2",
                    dim = list(lon, lat, time),
                    longname = "Original GIEMSv2 wetland area (km^2) in each 0.25deg grid cell",
                    missval = mv,
                    compression = 9)

# Define corrected GIEMSv2
var_aw_corr <- ncvar_def(name = "corrected_GIEMSv2_wetland_area",
                    units = "km^2",
                    dim = list(lon, lat, time),
                    longname = "Corrected GIEMSv2 wetland area (km^2) representing vegetated wetland (rescaled to static Fmax, subtracted monthly JRC open water cover, subtracted wet rice from MIRCA2000) in each 0.25deg grid cell",
                    missval = mv,
                    compression = 9)


# Add the variables to the file
ncout <- nc_create(nc_filename, list(var_aw_orig, var_aw_corr))
print(paste("The file has", ncout$nvars,"variables"))
print(paste("The file has", ncout$ndim,"dimensions"))

# add some global attributes
ncatt_put(ncout, 0, "Title", "Global Inundation Estimate from Multiple Satellites - Version 2 (GIEMS-2 product)")
ncatt_put(ncout, 0, "Author", "Catherine Prignet, Carlos Jimenez, Philippe Bousquet")
ncatt_put(ncout, 0, "Comment", "Reprojected equal area grid of 0.25°x0.25° at the equator to WGS84, and corrected version by Etienne Fluet-Chouinard (03/08/2021)")
ncatt_put(ncout, 0, "Version", "Version 2.0")
ncatt_put(ncout, 0, "Reference", "Satellite-derived global surface water extent and 2 dynamics over the last 25 years (GIEMS-2); Article DOI: 10.1029/2019JD030711")
ncatt_put(ncout, 0, "Created on", date())

# Place the precip and tmax values in the file 
#need to loop through the layers to get them 
# to match to correct time index
for (i in 1:nlayers(s_out)) { 
    print(i)
    #message("Processing layer ", i, " of ", nlayers(prec))
    ncvar_put(nc = ncout, 
              varid = var_aw_orig, 
              vals = values(giems2_a[[i]]), 
              start = c(1, 1, i), 
              count = c(-1, -1, 1))  
    
    ncvar_put(nc = ncout, 
              varid = var_aw_corr, 
              vals = values(giems2_a_corr[[i]]), 
              start = c(1, 1, i), 
              count = c(-1, -1, 1))  
}

# Close the netcdf file when finished adding variables
nc_close(ncout)




# /----------------------------------------------------------------------------#
#/  Reopen file to check
f1 <- '../output/giems2_area_wgs84_corr.nc'
a <-  stack(f1, varname='original_GIEMSv2_wetland_area')
b <-  stack(f1, varname='corrected_GIEMSv2_wetland_area')

plot(a[[1]])
plot(b[[1]])


# f2 <- '../output/results/natwet/preswet/giems2_wgs84_v2.nc'
# # a1 <- nc_open(f)
# a1 <- stack(f1)[[7]]
# names(a1) <- 'first wrong WGS84 reproject'
# 
# a2 <- stack(f2)[[7]]
# names(a2) <- 'updated correct WGS84 reproject'
# 
# # plot(a1)
# # plot(a2)
# a <- stack(a1, a2)
# 
# plot(a)
# 
# png('../output/figures/giems2_reproject_map.png')
plot(a, width = 800, height = 300)
dev.off()
