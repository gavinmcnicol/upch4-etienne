# Description: This script calculates the annual fluxes from carbon tracker over 2000-2010.
# It then calculates the total per biome zone.


# get list of all the monthly ncdf files;  units: mg m-2 day-1
p <- "../data/carbontracker/"
ct_list <- list.files(path = p)


# create empty dataframe for outputs
interannual_df <- data.frame(year=numeric(), sum =numeric())

# read the raster area from CarbonTracker
area_1x1_m2 <- raster(paste0(p, ct_list[start_idx:end_idx]), varname = "area1x1") 


# loop through files in the list
for (i in seq(1, 11)){
  

  # read in raster
  start_idx <- 1+(12*(i-1))
  end_idx   <- 12+(12*(i-1))
  
  r <- stack(paste0(p, ct_list[start_idx:end_idx]), varname = "natural")
  
  # scale to total flux per gridcell
  r <- r * area_1x1_m2
  # convert to Tg
  r <- r / 10^15
  # convert to monthly
  r <- r * 365/12
  
  # set projection
  proj4string(r)=CRS("+init=EPSG:4326")
  
  # calculate sum of all rasters in thee stack
  ct_sum <- calc(r, fun = sum, na.rm = T)#/12
  

  
  ###  get the sum per biome                   ---------------------------------
  zo <- as.data.frame(zonal(ct_sum, teow_raster, fun='sum', digits=0, na.rm=TRUE) )
  
  # add labels
  zo["biomes_regrouped"] <- c(teow_raster@data@attributes[[1]][2])$V2
  
  # calculate % of flux in each zone
  zo["percent_oftotflux"] <- zo["sum"] / sum(zo$sum) * 100
  
  # write the year to column
  zo$year <- as.numeric(substr(ct_list[start_idx],1,4))
  
  # add the zonal-biome sums to the output DF 
  interannual_df <- bind_rows(interannual_df, zo)
  
  print(paste0("done with: ", as.numeric(substr(ct_list[start_idx],1,4))))
  
}

###  save the sum
write.csv(interannual_df, "../output/results/carbontracker_interannual.csv")

# clean up environment
rm(ct_stack, ct_sum, i, ct_list, p)
