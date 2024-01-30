# WAD2M multipanel


# /----------------------------------------------------------------------------#
#/   WAD2M UPSCALING  MEAN MAP                                               --------

# Run mapping function; this was a functionbc of multiple members
flux_mean <- raster(paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_mean_msk.tif'))

#  MAKE LOWFLUX MASK FOR all following maps
low_flux_mask <- flux_mean 
low_flux_mask[low_flux_mask < 0.5] <- NA

# Panel A - Mean flux map 
flux_robin_mean_map <- make_saunois_mg_flux_map(flux_mean, 'Upscaling with WAD2M')
# assign to another variable; to make another figure: S13
wad2m_flux_robin_mean_map <- flux_robin_mean_map

# /----------------------------------------------------------------------------#
#/   GRID of flux variance of upscaled flux map                                    --------

# Read flux_var_perc raster
flux_var <- raster(paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_var_msk.tif'))

# Panel B - CV flux map
flux_robin_cv_map <- make_flux_var_map(flux_var, flux_mean, 400)


# /----------------------------------------------------------------------------#
#/   DIFFERENCE MAP x3                                                  --------

# Aggregate upscaling to 1 deg
flux_mean_1   <- aggregate(flux_mean, fact=4, na.rm=TRUE, fun="mean")

#/  Calculate differences between maps at 1deg resolution
diff_gcp_1 <- flux_mean_1 - gcp_1
diff_wc_1  <- flux_mean_1 - wc_1
diff_td_1  <- flux_mean_1 - td_1


# Make diff maps
#   Panel C
gcp1_diff_map <- diff_map_function(diff_gcp_1, 'Upscaling - Bottom-up ensemble')
#   Panel E
wc1_diff_map  <- diff_map_function(diff_wc_1, 'Upscaling - WetCharts v1.0')
#   Panel G
td1_diff_map  <- diff_map_function(diff_td_1, 'Upscaling - Top-down ensemble')


# /----------------------------------------------------------------------------#
#/   R2 Anomaly maps                                                    --------

# Aggregate low flux map to 1deg
low_flux_mask_1 <- aggregate(low_flux_mask, fact=4, na.rm=T)
# Run for GCP
gcp_r2 = raster('../output/comparison/anomaly_r2/wad2m_gcp_anomaly_r2.tif')
gcp_r2_map <- anomaly_r2_map(gcp_r2, 1)

# Get Carbon tracker anomaly grid
td_r2 <- raster('../output/comparison/anomaly_r2/wad2m_td_anomaly_r2.tif')
td_r2_map <- anomaly_r2_map(td_r2, 1)

# WetCharts
wc_r2 = raster('../output/comparison/anomaly_r2/wad2m_wc_anomaly_r2.tif')
wc_r2_map <- anomaly_r2_map(wc_r2, 1)


# /----------------------------------------------------------------------------#
#/    Assemble all in single panel                                      --------

d <- plot_grid(flux_robin_mean_map, flux_robin_cv_map,
               gcp1_diff_map, gcp_r2_map,
               td1_diff_map, td_r2_map,
               wc1_diff_map, wc_r2_map,
               ncol=2, 
               #align='hv'
               labels = c('A','B','C','D','E','F','G','H'))



# /----------------------------------------------------------------------------#
#/    Save to file                                      --------

ggsave('../output/figures/comparison_multipanel/comparison_multipanel_wad2m_v10.png',
       d, width=180, height=190, dpi=300, units='mm')

ggsave('../output/figures/comparison_multipanel/comparison_multipanel_wad2m_v10.pdf',
       d, width=180, height=190, dpi=300, units='mm')

