

# Run mapping function; this was a functionbc of multiple members
flux_mean_wad2m <- raster(paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_mean_msk.tif'))

# reformat rasters  for graph in ggplot
wad2m_robin_flux_mean_map <- make_saunois_mg_flux_map(flux_mean_wad2m, 'Upscaling with GIEMSv2')


