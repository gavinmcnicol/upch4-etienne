# /--------------------------------------------------------------------------#
#/     Convert units of grids from nmol m-2 sec-1  to Tg month-1




# /------------------------------------------------------------------------#
#/     Get wetland area from SWAMPS-GLWD                              -------
#      Do this out of function to avoid repeat


f <- '../data/swampsglwd/v2/gcp-ch4_wetlands_2000-2017_05deg.nc' 

# read wet fraction as raster brick 
Fw <- brick(f, varname="Fw") 


#   Get pixel area (m^2)                                             -----
pixarea_m2 <- area(Fw[[1]]) * 10^6

# Convert wetland fraction to  area
Aw = Fw * pixarea_m2

print("Got SWAMPS-GLWD")


# /--------------------------------------------------------------------------#
#/     Apply unit conv functi

# Get function
source("./prep/fcn/fcn_conv_grid_units.r")


# Convert units
# Format to bricks (to write to NCDF)
med_conv <- conv_grid_units(med_stack, Aw)
min_conv <- conv_grid_units(min_stack, Aw)
max_conv <- conv_grid_units(max_stack, Aw)

# Convert to bricks (to write to NCDF)
med_conv <- brick(med_conv)
min_conv <- brick(min_conv)
max_conv <- brick(max_conv)

print("Converted units")

# /--------------------------------------------------------------------------#
#/      Write out to NCDF
# Saving to RDS doesn't work well for large rasters.
writeRaster(med_conv, '../output/results/grid/upch4_med_nmolm2sec.nc', 
            overwrite=TRUE, format="CDF", varname="upch4", varunit="nmolm2sec", 
            longname="nmolm2sec -- raster stack to netCDF", 
            xname="Longitude",   yname="Latitude", zname="Time (Month)")

writeRaster(min_conv, '../output/results/grid/upch4_min_nmolm2sec.nc', 
            overwrite=TRUE, format="CDF", varname="upch4", varunit="nmolm2sec", 
            longname="nmolm2sec -- raster stack to netCDF", 
            xname="Longitude",   yname="Latitude", zname="Time (Month)")

writeRaster(max_conv, '../output/results/grid/upch4_max_nmolm2sec.nc', 
            overwrite=TRUE, format="CDF", varname="upch4", varunit="nmolm2sec", 
            longname="nmolm2sec -- raster stack to netCDF", 
            xname="Longitude",   yname="Latitude", zname="Time (Month)")

print("saved to NCDF")
