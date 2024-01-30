# carbon tracker  annual average
# first calculate the monthly average then multiply by 12

# get list of all the monthly ncdf files
p <- "../data/carbontracker/"
ct_list <- list.files(path = p)

nc_open(paste0(p, ct_list[1]))

# read the raster area from CarbonTracker
area_1x1_m2 <- raster(paste0(p, ct_list[start_idx:end_idx]), varname = "area1x1") 


# create empty raster stack
ct_stack <- stack()

# loop through CarbonTracker files, each representing a month 
for (i in seq(1, length(ct_list))){

  # print ticker
  print(ct_list[i])
  
  # read in raster
  # units:  mg m-2 day-1
  r <- raster(paste0(p, ct_list[i]), varname = "natural")
  
  # set projection
  proj4string(r)=CRS("+init=EPSG:4326")
  
  # add raster to the stack
  ct_stack <- stack(ct_stack, r)

  }

#  calculate mean monthly
ct_mean <- calc(ct_stack, fun = mean, na.rm = T)

# convert to annual
ct_mean <- ct_mean * 365

# convert to whole pixel
ct_mean <- ct_mean * area_1x1_m2

# convert from mgCH4 to TgCH4
ct_mean <- ct_mean / 10^15

### now the units are  TgCH4 yr-1

# save the decadal monthly average
saveRDS(ct_mean, "../output/results/carbontracker_2000_2010_avg_TgCH4yr.rds")

# clean up environment
rm(ct_stack, ct_mean, i, ct_list, p)
