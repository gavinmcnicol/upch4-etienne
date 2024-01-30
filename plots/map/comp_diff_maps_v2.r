# /----------------------------------------------------------------------------#
#/  Read 3 flux inputs: 3 average maps

gcp1_d<- raster('../output/diff/diff_upch4_gcp.tif')
ct1_d <- raster('../output/diff/diff_upch4_wc.tif')
wc1_d <- raster('../output/diff/diff_upch4_ct.tif')

maxcap <- 30
mincap <- -30


### Apply function
wc1_diff_map  <- diff_map_function(wc1_d, 'Upscaling - WC')
gcp1_diff_map <- diff_map_function(gcp1_d, 'Upscaling - GCP ensemble')
ct1_diff_map  <- diff_map_function(ct1_d, 'Upscaling - CT')

