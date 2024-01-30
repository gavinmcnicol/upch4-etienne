# /-------------------------------------------------
#/  Read 3 flux inputs: 3 average maps

# /----------------------------------------------------------------------------#
#/  Machine learning upsaling
# upch4_025 <- raster('../output/results/grids/v04/m1/for_map/upch4_v04_m1_mgCH4m2day_Aw_mean_msk.tif') # 0.25
upch4_025 <- raster('../output/for_map/upch4_v04_m1_mgCH4m2day_Aw_mean_msk.tif') # 0.25
upch4_1   <- aggregate(upch4_025, fact=4, na.rm=TRUE, fun="mean")


# /----------------------------------------------------------------------------#
#/  GCP Land Surface Models
# gcp_05 <- raster('../output/comparison/gcp_models/avg/gcp_ltavg_mgCH4m2day_2001_2015_1deg.tif')
# gcp_1 <- raster('../output/comparison/gcp_models/avg/gcp_avg_mgCH4m2day_2001_2015_1deg.tif')
gcp_05 <- raster('../output/comparison/gcp_models/avg/gcp_ltavg_mgCH4m2day_2001_2017.tif')
gcp_1 <- aggregate(gcp_05, fact=2, na.rm=TRUE, fun="mean")
gcp_1 <- crop(gcp_1, com_ext)



if(0){
    # Get GCP time-series; for what?
    gcp_ts_05 <- stack('../output/comparison/gcp_models/avg/gcp_tsavg_mgCH4m2day_2001_2017.tif')
    gcp_ts_1 <- aggregate(gcp_ts_05, fact=2, na.rm=TRUE, fun="mean")
    gcp_ts_1 <- crop(gcp_ts_1, com_ext)
    }


# /----------------------------------------------------------------------------#
#/   Wetcharts 
wc_05 <- stack('../output/comparison/wetcharts/wc_ee_ltavg.tif')
wc_05 <- crop(wc_05, com_ext)
wc_1 <- aggregate(wc_05, fact=2, na.rm=TRUE, fun="mean")
# wc  <- disaggregate(wc, fact=, method='')  # Disaggregate to 0.25deg


# /----------------------------------------------------------------------------#
#/   TD inversions
td_1  <- raster("../output/comparison/inversions/td_ltavg_mgCH4m2day_2010_2017.tif")
td_1 <- crop(td_1, com_ext)




# /----------------------------------------------------------------------------#
#/   Carbon Tracker
# ct_1  <- raster("../output/comparison/carbontracker/ct_ltavg_2000_2010_mgCH4m2yr.tif")
# ct_1 <- crop(ct_1, com_ext)

# /-------------------------------------------------
#/   SAVE DIFFERENCE RASTERS
# 
# if(0){
#     writeRaster(diff_gcp_1, '../output/comparison/diff/diff_upch4_gcp.tif')
#     writeRaster(diff_wc_1, '../output/comparison/diff/diff_upch4_wc.tif')
#     writeRaster(diff_ct_1, '../output/comparison/diff/diff_upch4_ct.tif')
#     }