# LSWI - Land surface water index - LSWI is known to be sensitive to the total amount of liquid water in vegetation and its soil backgroun
# LE  - related to GPP
# LAI - related to GPP
# Reco - similar to CH4 production
# MAT - WorldClim 1
# Shortwave radiation

# Atmospheric Pressure/VPD?
# Read aggregated 0.25deg predictors

dir = '../data/predictors/all/'
dir2 ='../data/predictors/all/agg_025/'

# /----------------------------------------------------------------------------#
#/    Get predictors (preprocessed to 0.25deg)
# Google doc of predictors:
# https://docs.google.com/spreadsheets/d/1SfoKzd6NwBoqO5QJPKiFZhAm3MgFmaUrt-fnCku85v0/edit#gid=0

com_ext <- extent(-180, 180,  -56, 85)  # Set smaller extent, excl. Antarctica

# limit to 2003-2013 as common period - 132 months, 11 years
# LAI only for 2002.7 to 2013.12
# Subset all monthly predictor to 2003-2013 

# [1] 'EVI_F_LAG24'   -  138 long   for 2002.7 to 2013.12  # limit to 2003-2013
# EVI_F_LAG24     <- stack(paste0(dir, 'EVI_24_lag.nc'))[[7:138]]     %>% crop(com_ext)
# [2] 'LSWI_F_LAG16' 
LSWI_F_LAG16    <- stack(paste0(dir, 'LSWI_16_lag.nc'))[[7:138]]    %>% crop(com_ext)
# [3] 'SRWI_F_LAG8'  
# SRWI_F_LAG8     <- stack(paste0(dir, 'SRWI.nc'))[[7:138]]           %>% crop(com_ext)
# [4] 'aetS_LAG60'   - 12 long
# aetS_LAG60    <- stack(paste0(dir2, 'aetS_LAG60.tif'))            %>% crop(com_ext)
# [5] 'LAI_F_LEAD24'
LAI_F_LEAD24  <- stack(paste0(dir, 'LSWI_16_lag.nc'))[[7:138]]    %>% crop(com_ext)
# [6] 'LSWI_F_LAG8'  
LSWI_F_LAG8     <- stack(paste0(dir, 'LSWI_8_lag.nc'))[[7:138]]      %>% crop(com_ext)
# [7 & 8] 'LE' & 'LE_LAG30'    - 156 long;  2000 - 2013;  limit to Dec 2002 for 1month lag
LE          <- stack(paste0(dir2, 'LE_fluxcom.tif'))[[24:156]]   %>% crop(com_ext)
# [9] 'soilwaterR'
# soilwaterR      <- stack(paste0(dir2, 'soilwaterR_025.tif'))[[3:13]] %>% crop(com_ext)
# [10] 'RECO_DT'
RECO_DT     <- stack(paste0(dir2, 'Reco_fluxcom.tif'))[[25:156]] %>% crop(com_ext)
# [11] 'sgrids_oc'    
# sgrids_oc       <- raster(paste0(dir2, 'sgrids_oc_025.tif'))         %>% crop(com_ext)
# [12] 'Diss' 
# Diss      <- raster(paste0(dir2,'Diss_025.tif'))               %>% crop(com_ext)
# [13] 'wc7'
# wc7       <- raster(paste0(dir2, 'wc7_025.tif'))               %>% crop(com_ext)


mat <- aggregate( raster('../data/predictors/bioclim/wc2.0_bio_5m_01.tif'),  fact=3, fun=mean, na.rm=TRUE)
Rpot   <- stack("../data/predictors/generic/Rpot.nc")

#-----------------------------------------------------------------------------------
# Stack averages for each predictor

EVI_F_LAG24m  <- calc(EVI_F_LAG24, mean, na.rm=T)
LSWI_F_LAG16m <- calc(LSWI_F_LAG16, mean, na.rm=T)
SRWI_F_LAG8m <- calc(SRWI_F_LAG8, mean, na.rm=T)
LAI_F_LEAD24m <- calc(LAI_F_LEAD24, mean, na.rm=T)
LEm <- calc(LE, mean, na.rm=T)
soilwaterRm <- calc(soilwaterR, mean, na.rm=T)
RECO_DTm <- calc(RECO_DT, mean, na.rm=T)
# sgrids_ocm <- calc(sgrids_oc, mean, na.rm=T)
# Dissm <- calc(Diss, mean, na.rm=T)
# wc7m <- calc(wc7, mean, na.rm=T)




preds <- stack(EVI_F_LAG24m,
               LSWI_F_LAG16m,
               SRWI_F_LAG8m,
               LAI_F_LEAD24m,
               LEm,
               soilwaterRm,
               RECO_DTm,
               sgrids_oc,
               Diss,
               wc7)


writeRaster(preds, '../output/results/grids/representativeness_vars/all_vars.tif', overwrite=TRUE)


