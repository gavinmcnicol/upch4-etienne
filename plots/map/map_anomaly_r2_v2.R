

# Aggregate low flux map to 1deg
low_flux_mask_1 <- aggregate(low_flux_mask, fact=4, na.rm=T)


# Get CArbon tracker anomaly grid
ct_r2 <- raster('../output/anomaly_r2/upch4_ct_anomaly_r2.tif')
# Make map
ct_r2_map <- anomaly_r2_map(ct_r2, 1)


# Run for GCP
gcp_r2 <- raster('../output/anomaly_r2/upch4_gcp_anomaly_r2.tif')
gcp_r2_map <- anomaly_r2_map(gcp_r2, .4)


wc_r2 = raster('../output/anomaly_r2/upch4_wc_anomaly_r2.tif')
wc_r2_map <- anomaly_r2_map(wc_r2, .2)
