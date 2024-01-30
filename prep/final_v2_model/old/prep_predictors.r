
# 1  Latent heat (FLUX)		FLUXCOM	Monthly 	2000 - 2013		On Sherlock. Need to be stacked (from annual .nc); resample to 0.25deg; Convert from MJ m^2 to W m-2 (if needed)	LE.RS_METEO.EBC-ALL.MLM-ALL.METEO-ALL.720_360.monthly.2005.nc
# 3  Bioclimatic temperature seasonality	60		Static	On Sherlock.	wc7
# 4	 Annual range in soil water content (MET)	39		Yearly 2000-2018	1 km resolution; Gavin will upload	soilwaterR
# 5	 Simple ratio water index (RS)	18	MODIS	Monthly ~2002-2018	Zutao will prepare MODIS at 0.25degree; Gavin will look at snow cover threshold;  	
# 6	 Ecosystem respiration	14	FLUXCOM	2000 - 2013	On Sherlock. Need to be stacked (from annual .nc); resample to 0.25deg; Convert from MJ m^2 to W m-2 (if needed)	TER.RF.CRUNCEPv6.monthly.2013.nc
# 7	 Spatial dissimilarity in greenness	10		static	On Sherlock.	Diss
# 8	 Enhanced veg. Index w/ 24 day lag	10	MODIS	Monthly ~2002-2018	Zutao will prepare MODIS at 0.25degree; if NDSI > 0, assign quantile(0.05) of product;  Zutao will upload the lagged predictor stack	
# 9	 Soil grids organic carbon content	9		Static	Need to upload	sgrids_oc
# 10 Leaf area index w/ 24 day lead	8	MODIS	Monthly ~2001-2018	Zutao will prepare MODIS at 0.25degree; if NDSI > 0, assign quantile(0.05) of product;;  Zutao will upload the lagged predictor stack	
# 11 Land surface water index w/ 16 day lag	8	MODIS	Monthly ~2001-2018	Zutao will prepare MODIS at 0.25degree; if NDSI > 0, assign quantile(0.05) of product;;  Zutao will upload the lagged predictor stack	
# 12 Land surface water index w/ 8 day lag	8	MODIS	Monthly ~2001-2018	Zutao will prepare MODIS at 0.25degree; if NDSI > 0, assign quantile(0.05) of product;;  Zutao will upload the lagged predictor stack	
# 13 Seasonality in actual ET w/ 60 day lag	1	Yearly 2000-2018	1 km resolution; Gavin will upload	aetS_LAG60


# /--------------------------------------------------------------------------
#/  PREP FLUXCOM GRIDS

prep_fluxcom_pred <- function(f_pattern) {

	# list all LE files in directory
	fl <- list.files(path = ".", pattern = f_pattern)
	out_brick <- stack()  	# create empty brick

	# Read the NC files into Brick
	for (f in fl){

		print(f)
		in_temp <- stack(f) 		# read in stack
		in_temp <- disaggregate(in_temp , fact=2, method='')
		out_brick <- stack(out_brick, in_temp) 		# Add grids to output stack 
		}
	return(out_brick)
	}


# WD
setwd('../data/predictors/all/')
# Set extent
com_ext <- extent(-180, 180, -56, 85)

# Available 2001-2013
# LE (original units: MJ m-2 d-1)  -->  convert to joules m-2 sec-1  ==  W m-2
# Convert it to Joules (*10^6)  then from day to second  /60*60*24
LE_stack <- prep_fluxcom_pred('LE.RS_METEO.EBC-ALL.MLM-ALL.METEO-ALL.720_360.monthly')
LE_stack <- LE_stack * 1e6 / (60*60*24)
writeRaster(LE_stack, './agg_025/LE_fluxcom.tif', options=c('TFW=YES'))


# Reco  ( orignal units: gC m-2 day-1 )   convert to nmolCO2 m-2 sec-1
# 44.01 g/mol CO2
Reco_stack <- prep_fluxcom_pred('TER.RF.CRUNCEPv6.monthly')
Reco_stack <- Reco_stack / 44.01 * 1e+9 / (60*60*24)
# Reco_stack <- Reco_stack[[13:168]]         # Exclude year 2000
writeRaster(Reco_stack, './agg_025/Reco_fluxcom.tif', options=c('TFW=YES'))


# SoilGrids organic content - static
sgrids_oc <- raster('OCDENS_M_sl2_250m_ll.tif') %>% crop(com_ext)
extent(sgrids_oc) <- com_ext
sgrids_oc <- aggregate(sgrids_oc, fact=120, fun=mean, na.rm=TRUE)
writeRaster(sgrids_oc, './agg_025/sgrids_oc_025.tif')


# Spatial dissimilarity in greenness
soilwaterR <- raster("soilwaterR.nc")
soilwaterR <- aggregate(soilwaterR, fact=30, fun=mean, na.rm=TRUE)
writeRaster(soilwaterR, './agg_025/soilwaterR_025.tif')


# Spatial dissimilarity in greenness
Diss <- raster("Dissimilarity_01_05_1km_uint32.tif")
Diss <- aggregate(Diss, fact=30, fun=mean, na.rm=TRUE)
writeRaster(Diss, './agg_025/Diss_025.tif')

# WC7 - Bioclimatic temperature seasonality
wc7 <- aggregate( raster("../generic/wc7.tif"),  fact=30, fun=mean, na.rm=TRUE)
writeRaster(wc7, './agg_025/wc7_025.tif')


# aetS_LAG60 - Seasonality in actual ET w/ 60 day lag  1 Yearly 2000-2018  1 km resolution; Gavin will upload  
aetS_LAG60 <- stack("aetS_LAG60.nc")
aetS_LAG60_agg <- aggregate(aetS_LAG60, fact=6, fun=mean, na.rm=TRUE)
writeRaster(aetS_LAG60_agg, './agg_025/aetS_LAG60.tif', options=c('TFW=YES'))

