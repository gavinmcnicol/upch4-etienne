
# Read flux_var_perc raster
flux_var <- raster(paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_var_msk.tif'))

wad2m_flux_robin_cv_map <- make_flux_var_map(flux_var, flux_mean, 400)

