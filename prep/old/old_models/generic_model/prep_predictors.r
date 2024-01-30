
dir = "../data/predictors/generic/"


# /----------------------------------------------------------------------------#
#/  Aggregate  Static predictors  -  to 0.25 deg


com_ext <- extent(-180, 180,  -56, 85)


sgrids_cc <- raster(paste0(dir, "sgrids_cc.tif"))
sgrids_cc <- crop(sgrids_cc, com_ext)
extent(sgrids_cc) <- com_ext
sgrids_cc <- aggregate(sgrids_cc, fact=120, fun=mean, na.rm=TRUE)
writeRaster(sgrids_cc, paste0(dir, 'agg_025/', 'sgrids_cc_025.tif'), overwrite=TRUE)


sgrids_ph <- raster(paste0(dir, "sgrids_ph.tif")) %>% crop(com_ext)
extent(sgrids_ph) <- com_ext
sgrids_ph <- aggregate(sgrids_ph, fact=120, fun=mean, na.rm=TRUE)   # original res= 0.0020833
writeRaster(sgrids_ph, paste0(dir, 'agg_025/', 'sgrids_ph_025.tif'), overwrite=TRUE)


Var       <- aggregate(raster(paste0(dir, "Var.tif")) ,     fact=30, fun=mean, na.rm=TRUE)
HD7       <- aggregate(raster(paste0(dir, "HD7.tif")),      fact=30, fun=mean, na.rm=TRUE)
HD9       <- aggregate(raster(paste0(dir, "HD9.tif")),      fact=30, fun=mean, na.rm=TRUE)
wc7       <- aggregate( raster("../data/bioclim/wc2.0_bio_5m_07.tif "),  fact=3, fun=mean, na.rm=TRUE)





writeRaster(Var, paste0(dir, 'agg_025/', 'Var_025.tif'), overwrite=TRUE)
writeRaster(HD7, paste0(dir, 'agg_025/', 'HD7_025.tif'), overwrite=TRUE)
writeRaster(HD9, paste0(dir, 'agg_025/', 'HD9_025.tif'), overwrite=TRUE)
writeRaster(wc7, paste0(dir, 'agg_025/', 'wc7_025.tif'), overwrite=TRUE)


