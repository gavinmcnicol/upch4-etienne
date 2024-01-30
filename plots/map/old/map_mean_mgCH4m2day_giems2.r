# Multipanel for GIEMS2 upscaling

# Read full stack
flux_stack <- stack('../output/stack/upch4_v04_m1_mgCH4m2day_Aw_giems2.nc', varname='mean_ch4')

# Average stack into 1 grid
beginCluster(6) # define the number of cores you want to use
flux_mean_giems2 <- clusterR(flux_stack, mean, args=list(na.rm=TRUE))
# endCluster()




## MAKE LOWFLUX MASK FOR VAR & VAR_PERC MAPS
flux_mean_giems2_mask <- flux_mean_giems2 
flux_mean_giems2_mask[flux_mean_giems2_mask < 0.5] <- NA

# /----------------------------------------------------------------------------#
#/ MAKE MEAN MAP
giems2_robin_flux_mean_map <- make_saunois_mg_flux_map(flux_mean_giems2, 'Upscaling with GIEMSv2')



# /----------------------------------------------------------------------------#
#/  Read flux_var_perc raster
flux_var_giems2 <- 
    raster(paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_var_msk_giems2.tif')) %>% 
    mask(., flux_mean_giems_mask) 


wad2m_flux_robin_cv_map <- make_flux_var_map(flux_var_giems2, flux_mean_giems2, 400)




# /-------------------------------------------------
#/ Diff Maps 

flux_mean_giems2_1deg <- aggregate(flux_mean_giems2, fact=4, na.rm=TRUE, fun="mean")


#  Calculate differences between maps at 1deg resolution
diff_giems2_gcp_1 <- flux_mean_giems2_1deg - gcp_1
diff_giems2_wc_1  <- flux_mean_giems2_1deg - wc_1
diff_giems2_ct_1  <- flux_mean_giems2_1deg - ct_1



# Make difference map from function
gcp1_diff_map <- diff_map_function(diff_giems2_gcp_1, 'Upscaling - GCP ensemble')
wc1_diff_map  <- diff_map_function(diff_giems2_wc_1, 'Upscaling - WC')
ct1_diff_map  <- diff_map_function(diff_giems2_ct_1, 'Upscaling - CT')


# /------------------------------------
#/  R^2 maps

# Aggregate low flux map to 1deg
low_flux_mask_1 <- aggregate(low_flux_mask, fact=4, na.rm=T)


# Get Carbon tracker anomaly grid
ct_r2 <- raster('../output/anomaly_r2/upch4_ct_anomaly_r2.tif')
ct_r2_map <- anomaly_r2_map(ct_r2, 1)


# Run for GCP
gcp_r2 = raster('../output/anomaly_r2/upch4_gcp_anomaly_r2.tif')
gcp_r2_map <- anomaly_r2_map(gcp_r2, .4)


wc_r2 = raster('../output/anomaly_r2/upch4_wc_anomaly_r2.tif')
wc_r2_map <- anomaly_r2_map(wc_r2, .2)



# endCluster()


