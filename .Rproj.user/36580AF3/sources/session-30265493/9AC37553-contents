# For the lm regression to work, NAs have to be identical across two datasets
# Q- NAs the same over space or over time?
# Apply data mask
# JAN2022 - DID i ever solve the clusterR??? wtf 
# ERROR: "cannot use this function", "cluster error"

# source('plots/fcn/fcn_calc_r2_anomaly.r') # <- did clusterR eventually work, or did I give up? (Jan 2022?)
source('plots/fcn/fcn_calc_r2_anomaly_v2.r')


# /------------------------------------------------------------------------#
#/  R2 - Comparing monthly anomaly across space

beginCluster(6)

# vdir <- '../output/results/grids/v04/m1/'
vdir <- '../output/stack/'

# Get WAD2M upscaling - 216 long - 2001-2017
upch4_025 <- stack(paste0(vdir,'upch4_v04_m1_mgCH4m2day_Aw.nc'), varname='mean_ch4') # [[1:12]]
upch4_025 <- crop(upch4_025, com_ext)
upch4_1 <- aggregate(upch4_025, fact=4, fun='mean', expand=TRUE, na.rm=TRUE)
upch4_1[is.na(upch4_1)] <- 0



# Get GIEMS2 upscaling - 180 long; 2001-2015
upch4_giems2_025 <- stack(paste0(vdir,'upch4_v04_m1_mgCH4m2day_Aw_giems2.nc'), varname='mean_ch4') #[[1:12]]
upch4_giems2_025 <- crop(upch4_giems2_025, com_ext)
upch4_giems2_1 <- aggregate(upch4_giems2_025, fact=4, fun='mean', expand=TRUE, na.rm=TRUE)
upch4_giems2_1[is.na(upch4_giems2_1)] <- 0


# GCP  - 204 long - 2001-2017
gcp_05 <- stack('../output/comparison/gcp_models/avg/gcp_tsavg_mgCH4m2day_2001_2017.tif') # [[1:12]]
gcp_05 <- crop(gcp_05, com_ext)
gcp_1 <- aggregate(gcp_05, fact=2, fun='mean', expand=TRUE, na.rm=TRUE)
# gcp_1[is.na(gcp_1)] <- 0
gcp_1 = reclassify(gcp_1, cbind(NA, NA, 0), right=FALSE)  # this is faster than is.na()<-0


# Wetcharts - 180 long  - 2001-2015
wc_05 <- stack('../output/comparison/wetcharts/wc_ee_tsavg.tif')
wc_05 <- crop(wc_05, com_ext)
wc_1 <- aggregate(wc_05, fact=2, na.rm=TRUE, fun="mean")
# wc_1[is.na(wc_1)] <- 0
wc_1 = reclassify(wc_1, cbind(NA, NA, 0), right=FALSE)  # this is faster than is.na()<-0


# Topdown inversion  - 96 long   -  2010 - 2017
p <- "../output/comparison/inversions/"
td_1 <- stack(paste0(p, 'td_tsavg_mgCH4m2day_2010_2017.tif'))
td_1 <- crop(td_1, com_ext)
# ct_1[is.na(ct_1)] <- 0
td_1 = reclassify(td_1, cbind(NA, NA, 0), right=FALSE)  # this is faster than is.na()<-0


endCluster()


# /--------------------------------------------------------------------------#
#/  Run r2 functions for WAD2M

# beginCluster(6)
# r2 <- detrended_r2_map(upch4_1, gcp_1)



time <- 1:204
r2 <- detrended_r2_map(upch4_1[[1:204]], gcp_1)  # over 2001-2017
writeRaster(r2, '../output/comparison/anomaly_r2/wad2m_gcp_anomaly_r2.tif')

time <- 1:180
r2 <- detrended_r2_map(upch4_1[[1:180]], wc_1)  # 2001-2015  
writeRaster(r2, '../output/comparison/anomaly_r2/wad2m_wc_anomaly_r2.tif')

time <- 1:120
r2 <- detrended_r2_map(upch4_1[[109:204]], td_1) # 2010-2017 [[13:132]]
writeRaster(r2, '../output/comparison/anomaly_r2/wad2m_td_anomaly_r2.tif')



# /--------------------------------------------------------------------------#
#/  Run r2 functions for GIEMS2 - over 2001-2015

time <- 1:180
r2 <- detrended_r2_map(upch4_giems2_1[[1:180]], gcp_1[[1:180]])  # over 2001-2015
writeRaster(r2, '../output/comparison/anomaly_r2/giems2_gcp_anomaly_r2.tif')

time <- 1:180
r2 <- detrended_r2_map(upch4_giems2_1[[1:180]], wc_1)  # 2001-2015  
writeRaster(r2, '../output/comparison/anomaly_r2/giems2_wc_anomaly_r2.tif')

time <- 1:120
r2 <- detrended_r2_map(upch4_giems2_1[[97:168]], td_1[[1:72]]) # 2010-2015 [[13:132]]
writeRaster(r2, '../output/comparison/anomaly_r2/giems2_td_anomaly_r2.tif')



endCluster()



# library(tictoc)
# 
# tic()
# # beginCluster(6)
# r2 <- detrended_r2_map(upch4_1[[1:24]], gcp_1[[1:24]])
# # endCluster()
# toc()
# 
# 
# beginCluster(10)
# # r2 <- detrended_r2_map(upch4_1[[1:24]], gcp_1[[1:24]])
# # r2 <- detrended_r2_map(s1=upch4_1[[1:24]] , s2= gcp_1[[1:24]])
# time <- 1:nlayers(upch4_1[[1:204]])
# r2 <- detrended_r2_map(upch4_1[[1:204]] , gcp_1[[1:204]])
# 
# endCluster()

# r2 <- clusterR(upch4_1[[1:24]], gcp_1[[1:24]], calc, args=list(mean, na.rm=T))
# toc()


# # CarbonTracker  - 132 long   -  2000 - 2010
# p <- "../output/comparison/carbontracker/"
# ct_1 <- stack(paste0(p, 'ct_ts_2000_2010_mgCH4m2yr.tif'))
# ct_1 <- crop(ct_1, com_ext)
# # ct_1[is.na(ct_1)] <- 0
# ct_1 = reclassify(ct_1, cbind(NA, NA, 0), right=FALSE)  # this is faster than is.na()<-0

