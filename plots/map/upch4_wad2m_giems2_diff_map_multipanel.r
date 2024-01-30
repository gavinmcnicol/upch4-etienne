# Description: Makes a 3 panel figure for SI.  Figure SI15
# Showing maps of two upscaling products and their difference.

# Get WAD2M upscaling
flux_mean_wad2m <- raster(paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_mean_msk.tif'))

# Get GIEMSv2 upscaling
flux_mean_giems2 <- raster(paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_mean_msk_giems2.tif'))


# Compute difference
upch4_diff_r <- flux_mean_wad2m - flux_mean_giems2

# Map of difference 
upch4_diff_map  <- diff_map_function(upch4_diff_r, 'Upscaled WAD2M - Upscaled GIEMSv2')


# /----------------------------------------------------------------------------#
#/    Arrange in panel
d <- plot_grid(wad2m_flux_robin_mean_map,
               giems_robin_flux_mean_map,
               upch4_diff_map, 
               ncol=1,
               labels = c('A','B','C'))

# /----------------------------------------------------------------------------#
#/   Save to file
ggsave('../output/figures/upch4_wad2m_giems2_comparison_3panel_v2.png', d, 
       width=180, height=240, dpi=400, units='mm')


ggsave('../output/figures/upch4_wad2m_giems2_comparison_3panel_v2.pdf', d, 
       width=180, height=240, dpi=400, units='mm')
