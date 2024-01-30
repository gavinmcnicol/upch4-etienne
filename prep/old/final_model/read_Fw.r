# /------------------------------------------------------------------------#
#/     Get wetland area from SWAMPS-GLWD                             -------

f <- '/home/groups/robertj2/upch4/data/wetland_area/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc'   # 216 long

# FINAL MODE:  2001-2015
modelname= 'final'
if(modelname=='final') { Fw <- brick(f, varname='Fw')[[13:192]] }

# Crop Fw to match the flux prediction grids
com_ext <- extent(-180, 180, -56, 85)
Fw <- crop(Fw, com_ext)
extent(Fw) <- com_ext

# Get pixel area (originally in km^2, convert to m^2)
pixarea_m2 <- area(Fw[[1]]) * 10^6

# Convert wetland fraction to area
Aw_m2 = Fw * pixarea_m2



# rm(Fw)
# Fw_mask[Fw_mask == 0] <- NA

# Generic model, limit to 2001-2018
# if(modelname=='gen') {  Fw <- brick(f, varname='Fw')[[13:228]]  }
# # All model, limit to 2003-2013
# if(modelname=='all') {	Fw <- brick(f, varname='Fw')[[37:168]]  }

# f <- '/home/groups/robertj2/upch4/data/wetland_area/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc'   # 216 long