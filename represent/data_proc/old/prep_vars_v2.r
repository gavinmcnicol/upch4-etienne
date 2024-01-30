# LSWI - Land surface water index - LSWI is known to be sensitive to the total amount of liquid water in vegetation and its soil backgroun
# LE  - related to GPP
# LAI - related to GPP
# Reco - similar to CH4 production
# MAT - WorldClim 1
# Shortwave radiation (potential radiation)



# limit to 2003-2013 as common period - 132 months, 11 years
# LAI only for 2002.7 to 2013.12
# Subset all monthly predictor to 2003-2013 


# Atmospheric Pressure/VPD?

dir = '../data/predictors/all/'
dir2 ='../data/predictors/all/agg_025/'

# /----------------------------------------------------------------------------#
#/    Get predictors (preprocessed to 0.25deg)
# Google doc of predictors: https://docs.google.com/spreadsheets/d/1SfoKzd6NwBoqO5QJPKiFZhAm3MgFmaUrt-fnCku85v0/edit#gid=0

com_ext <- extent(-180, 180,  -56, 85)  # Set smaller extent, excl. Antarctica


# LSWI_F_LAG16    <- stack(paste0(dir, 'LSWI_16_lag.nc'))[[7:138]]    %>% crop(com_ext)
LAI_F_LEAD24  <- stack(paste0(dir, 'LSWI_16_lag.nc'))[[7:138]]   %>% crop(com_ext)
SRWI_F_LAG8   <- stack(paste0(dir, 'SRWI.nc'))[[7:138]]        %>% crop(com_ext)
LE            <- stack(paste0(dir2, 'LE_fluxcom.tif'))[[24:156]]   %>% crop(com_ext)
RECO_DT       <- stack(paste0(dir2, 'Reco_fluxcom.tif'))[[25:156]] %>% crop(com_ext)

mat <- aggregate( raster('../data/predictors/bioclim/wc2.0_bio_5m_01.tif'), fact=3, fun=mean, na.rm=TRUE) %>% crop(com_ext)
Rpot   <- stack("../data/predictors/generic/Rpot.nc")   %>% crop(com_ext)



# /---------------------------------------------------------------------------------#
#/ Calculate average

# LSWI_F_LAG16m <- calc(LSWI_F_LAG16, mean, na.rm=T)
LAI_F_LEAD24m 	<- calc(LAI_F_LEAD24, mean, na.rm=T)
rm(LAI_F_LEAD24)

SRWI_F_LAG8m  	<- calc(SRWI_F_LAG8, mean, na.rm=T)
rm(SRWI_F_LAG8)

LEm 		 	<- calc(LE, mean, na.rm=T)
rm(LE)

RECO_DTm 		<- calc(RECO_DT, mean, na.rm=T)
rm(RECO_DT)

Rpotm 			<- calc(Rpot, mean, na.rm=T)
rm(Rpot)


# /---------------------------------------------------------------------------------#
#/ Stack averages for each predictor

preds <- stack(LAI_F_LEAD24m,
               SRWI_F_LAG8m,
               LEm,
               RECO_DTm,
               mat,
               Rpotm)


# name the images in stack
names(preds) <- c('LAI_F_LEAD24m', 'SRWI_F_LAG8m', 'LEm', 'RECO_DTm', 'mat', 'Rpotm')

# save to file
writeRaster(preds, '../output/results/grids/representativeness_vars/subset_vars.tif', overwrite=TRUE)

