# Get average carbon tracker grid;
# flux over 2001-2010, in mgCH4m-2day-1, at 1x1 resolution
# float natural[lon,lat,time]   
# units: mg m-2 day-1
# long_name: natural_flux
# comment: optimized surface CH4 flux due to wetlands, soil, oceans and insects/wild animals

# Get list of all the monthly ncdf files
# p <- "../data/comparison/carbontracker/"
p <- "../output/comparison/carbontracker/"
ct_list <- list.files(path = p)

# create empty raster stack
ct_stack <- stack()

# /--------------------------------------------------------
#/  Loop through CarbonTracker files, each representing a month 
for (ct in ct_list) {

  # print ticker
  print(ct)
  
  # read in raster
  r <- raster(paste0(p, ct), varname = "natural")
  
  # set projection
  # proj4string(r) <- CRS("+init=EPSG:4326")

  # Replace NAs with 0 (for averaging)
  r[is.na(r)] <- 0

  # add raster to the stack
  ct_stack <- stack(ct_stack, r)

}

# Save time series 
writeRaster(ct_stack, "../output/comparison/carbontracker/ct_ts_2000_2010_mgCH4m2day.tif")


# /--------------------------------------------------------
#/   Calculate long-term mean
ct_mean <- calc(ct_stack, fun = mean, na.rm = T)

# Save the decadal monthly average
writeRaster(ct_mean, "../output/comparison/carbontracker/ct_ltavg_2000_2010_mgCH4m2day.tif")



# float natural[lon,lat,time]   
# units: mg m-2 day-1
# long_name: natural_flux
# comment: optimized surface CH4 flux due to wetlands, soil, oceans and insects/wild animals


# float q_natural[lon,lat,time]   
# units: mg m-2 s-1
# long_name: natural_flux_estimated_uncertainty
# comment: estimated uncertainty of surface CH4 flux due to wetlands, soils, oceans and insects/wild animals
   