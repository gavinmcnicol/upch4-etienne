
# /----------------------------------------------------------------------------#
#/ GIEMSv2; reprojected in WGS84; Originally 288 months, 24 years (1992-2015) 
#  Subset to 2000-2015
giems2_aw <- rast('../../Chap3_wetland_loss/output/results/natwet/preswet/giems2_aw_v3.tif')[[97:288]] #[[109:288]]

# Get pixel area
pixarea <- cellSize(giems2_aw, mask=FALSE) / 10^6

# Convert Aw back to Fw
giems2_fw <- giems2_aw / pixarea

giems2_fw[giems2_fw>1] <- 1 # Set ceiling value of 1 

# /----------------------------------------------------------------------------#
#/   Compute GIEMSv2 yearly max                            -------------
# Make group label list; labels rasters from same timestep together
groupn = function(n,m){rep(1:m,rep(n/m,m))}

nlay <- length(names(giems2_fw))

# Make list of group labels
timestep_grp = groupn(nlay, nlay/12 )

f = function(x){tapply(x, timestep_grp, max, na.rm=T)}

# Calculate annual maximum
giems2_fw_mamax <- app(giems2_fw, fun=f)
# giems2_fw_mamax <- mean(giems2_fw_mamax, na.rm=T)

giems2_fw_mamax[giems2_fw_mamax>1] <- 1 # Set ceiling value of 1
giems2_fw_mamax[!is.finite(giems2_fw_mamax)] <- NA # 1


# /----------------------------------------------------------------------------#
#/   Get Correction layers (fmax)
caff <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v2/ArcticCouncil_fraction_025deg.nc')
cifor <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/cifor_wetlands_area_025deg_frac.nc')
glwd <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/GLWD_wetlands_025deg_frac.nc')
glwd <- crop(glwd, ext(-180, 180, 40, 60)) # Crop GLWD to only temperate latitudes outside of CIFOR & NCSCD
glwd <- extend(glwd, ext(-180, 180, -90, 90)) #, value=NA)

#/  Assemble three correction factor inputs into a single layer
corr_fmax <- c(caff, cifor, glwd)
corr_fmax <- max(corr_fmax, na.rm=T)
# corr_fmax[corr_fmax>1] <- 1

# /----------------------------------------------------------------------------#
#/  CORRECTION FACTOR
# Calculate fw correction factor; a factor for the long term max
# Apply 0 to pixels where giems_max > fwmax
# fwcorr <- overlay(corr_fmax, giems2_fw_mamax, fun = function(x, y) {z <- x/y; z[z<1] <- 1; z})
# fwcorr <- lapp(c(corr_fmax, giems2_fw_mamax), fun = function(x, y) {z <- x/y; z[z<1] <- 1; z})


fwcorr <- corr_fmax / giems2_fw_mamax
fwcorr[fwcorr<1] <- 1
fwcorr[is.na(fwcorr)] <- 1
fwcorr[!is.finite(fwcorr)] <- NA # 1
# fwcorr[fwcorr>20] <- 20  # Set ceiling of scaling factor

# plot(fwcorr[[7]])
# hist(fwcorr)


# /----------------------------------------------------------------------------#
#/  APPLY CORRECTION FACTOR

# apply Fmax correction factor; producing corrected annual maximum
giems2_fw_mamax_corr <- giems2_fw_mamax * fwcorr
giems2_fw_mamax_corr[is.na(giems2_fw_mamax_corr)] <- 0

### Get seasonal scalar 
# repeat layers
giems2_fw_mamax_rep <- giems2_fw_mamax[[timestep_grp]]
# Get monthly scalar; fraction of that year's maximum
giems2_fw_monthscalar = giems2_fw / giems2_fw_mamax_rep

# Apply seasonal scalar to each year
giems2_fw_mamax_corr_rep <- giems2_fw_mamax_corr[[timestep_grp]]
giems2_fw_corr <- giems2_fw_mamax_corr_rep * giems2_fw_monthscalar

# Force within 0-1 range
# giems2_fw_corr[giems2_fw_corr<0] <- 0
# giems2_fw_corr[!is.finite(giems2_fw_corr)] <- 1
# giems2_fw_corr[giems2_fw_corr>1] <- 1



# /----------------------------------------------------------------------------#
#/  Get static correction layer

# RICE COVERAGE  - 12 months
mirca <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/MIRCA_monthly_irrigated_rice_area_025deg_frac.nc')
# Repeat annual MIRCA cycle
mirca <- rep(mirca, 16)
# COASTLINE WATER - STATIC
#2. Note: SWAMPS already has ocean removed (in early/late versions), and so we use the MODIS ocean to remove ocean from JRC prior to agregating JRC
MODIS_coast <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/MODIS_coastal_mask_0.25deg.nc')
# in V2 openwater is combination of GRWL and HydroLAKES
openwater <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v2/Global_GRWL_HydroLakes_025deg_WGS84_fraction.nc')#[[13:192]]


# /----------------------------------------------------------------------------#
#/   Apply subtractions
# No longer subtracting MODIS ocean because Prigent 2019 says coastal contamination is no longer a problem.
# - MODIS_coast
giems2_fw_corr_final <- giems2_fw_corr - mirca  - openwater

# Force within 0-1 range
giems2_fw_corr_final[giems2_fw_corr_final<0] <- 0


# /----------------------------------------------------------------------------#
#/    Save to file
library(lubridate)

names(giems2_fw_corr_final) <- paste0('X', seq(ymd('2000-01-15'), ymd('2015-12-15'), by='1 month'))
#seq(1, nlyr(giems2_fw_corr_final)))
writeRaster(giems2_fw_corr_final, '../output/giems2_corr_v2_july2023.tif', overwrite=T)



writeCDF(giems2_fw_corr_final, '../output/giems2_corr_v2_july2023.nc', 'Fw', 
         longname="wetland fraction", unit="", compression=9, overwrite=T)


# 
# #May 2018 (rerun Feb 2019)
# #Update (10/06/2021) by Zhen: We use the GRWL&Hydrolakes to replace
# #This script creates the merged SWAMPS + inventory product
# #Logic is to compare maximum wetland extent from SWAMPS with the inventory, assuming inventory == max wetland extent
# #Problem is that max wetland extent from SWAMPS is sensitive to length of time, etc.
# #SWAMPS maximum wetland extent is highly uncertain, show in paper diff from yearmean vs yearmax, yearmean screws up rice mask stats
# #We assume that if SWAMPS has surface water and inventory doesnt, then we go with SWAMPS
# #Issues
# #1. SWAMPS has missing swaths from 1992 to 1999
# #2. Note: SWAMPS already has ocean removed (in early/late versions), and so we use the MODIS ocean to remove ocean from JRC prior to agregating JRC
# #3. Problem with freeze/thaw high latitude artificial line
# #4. SWAMPS has a lot of wetlands in Sahel, which CIFOR doesn't have
# #5. SWAMPS picks up ag in S America, E Russia, India, Sahel, yearmax is issue for this
# #6. Uncorrected global Fwmax (using mean) is 9.9 Mkm, and 4.9 Mkm for tropics -
# 
# #Set paths to the inputs
# fdirWORKDIR="/Users/zzhang88/Data/WetlandMaps/workdir/"
# fdirSWAMPS="/Users/zzhang88/Data/WetlandMaps/SWAMPS/"
# fdirCIFOR="/Users/zzhang88/Data/WetlandMaps/CIFOR/"
# #We use the new map from Arctic council map, Hugelius et al., 2020 for Arctic wetlands and peatlands for > 23N region. (no mineral wetlands for 38-60)
# 
# #In Version 1.0 we use NCSCD overlapped with GLWD and CIFOR
# #fdirNCSCD="/mnt/lustrefs/store/benjamin.poulter/BenResearch/GCP-CH4/data/NCSCD/"
# #In Version 2.0 we replace NCSCD with Arctic council map
# fdirNCSCD="/Users/zzhang88/Data/WetlandMaps/CAFF_wetland_maps_for_review/"
# 
# fdirGLWD="/Users/zzhang88/Data/WetlandMaps/GLWD-level3/"
# #In Version 1.0 we use GSW for inland water mask
# #fdirGSW="/mnt/lustrefs/store/benjamin.poulter/BenResearch/GCP-CH4/data/InlandWaters/JRC/"
# #In Version 2.0 we use GRWL&Hydrolakes for inland water mask
# fdirGRWL_HYDRO="/Users/zzhang88/Data/WetlandMaps/Inland_water/"
# fdirMIRCA="/Users/zzhang88/Data/Croplands/MIRCA2000/"
# fdirLPJ="/mnt/lustrefs/store/benjamin.poulter/BenResearch/GCP-CH4/data/lpj/"
# fdirSMAP="/mnt/lustrefs/store/benjamin.poulter/poulterlab/Wetlands/SMAP/"
# fdirPRIGENT="/mnt/lustrefs/store/benjamin.poulter/BenResearch/GCP-CH4/data/prigent/"
# fdirCOORD="/Users/zzhang88/Research/data/input/grid/"
# 
# #Convert SWAMPS from percentage to fraction
# cdo divc,100 $fdirSWAMPS/"swamps_v3_1992-2020_monmean.nc" $fdirWORKDIR/"swamps_v3_1992-2020_monmean_frac.nc"
# 
# #Link to files
# fwSWAMPS=$fdirWORKDIR/"swamps_v3_1992-2020_monmean_frac.nc"
# wetlandsCIFOR=$fdirCIFOR/"cifor_wetlands_area_025deg_frac.nc"
# #wetlandsNCSCD=$fdirNCSCD/"NCSCD_fraction_025deg.nc"
# wetlandsNCSCD=$fdirNCSCD/"ArcticCouncil_fraction_025deg.nc"
# wetlandsGLWD=$fdirGLWD/"GLWD_wetlands_025deg_frac.nc"
# #inlandwatersGSW=$fdirGSW/"Global_JRC_025deg_WGS84_fraction_noocean.nc"
# inlandwatersGSW=$fdirGRWL_HYDRO/"Global_GRWL_HydroLakes_025deg_WGS84_fraction.nc"
# riceMIRCA=$fdirMIRCA/"MIRCA_monthly_irrigated_rice_area_025deg_frac.nc"
# wetlandsLPJ=$fdirLPJ/"LPJ_MERRA2_wetfrac_1992-2016.nc"
# wetlandsSMAP=$fdirSMAP/"SMAP_Fw_025deg.nc"
# wetlandsPRIG=$fdirPRIGENT/"prigent9307_05d_norice.nc"
# 
# #A. Calculate maximum wetland area based on SWAMPS (this includes lakes, excludes ocean)
# # Multi-year monthly maximum
# cdo ymonmax $fwSWAMPS $fdirWORKDIR/"swamps_v3_1992-2020_ymonmax.nc"
# # Yearly maximum
# cdo yearmax $fdirWORKDIR/"swamps_v3_1992-2020_ymonmax.nc" $fdirWORKDIR/"swamps_v3_1992-2020_yearmax.nc"
# 
# #B. Create maximum wetland area based on Inventories with no lakes (based on CIFOR, NCSCD and GLWD definitions)
# cdo setctomiss,0 $wetlandsCIFOR $fdirWORKDIR/"cifor_tmp.nc"
# cdo setctomiss,0 $wetlandsNCSCD $fdirWORKDIR/"ncscd_tmp.nc"
# cdo setctomiss,0 $wetlandsGLWD $fdirWORKDIR/"glwd_tmp.nc"
# 
# #Merge CIFOR and NCSCD (no overlap with each other)
# cdo max $fdirWORKDIR/"cifor_tmp.nc" $fdirWORKDIR/"ncscd_tmp.nc" $fdirWORKDIR/"inventory_merge1.nc"
# cdo setmisstoc,0 $fdirWORKDIR/"inventory_merge1.nc" $fdirWORKDIR/"inventory_merge1_mask6.nc"
# 
# #Now merge GLWD where no overlap for CIFOR and NCSCD exists (prioritize CIFOR and NCSCD over GLWD)
# cdo lec,1 $fdirWORKDIR/"inventory_merge1.nc" $fdirWORKDIR/"inventory_merge1_mask1.nc"
# cdo setmisstoc,0 $fdirWORKDIR/"inventory_merge1_mask1.nc" $fdirWORKDIR/"inventory_merge1_mask2.nc"
# cdo setctomiss,1 $fdirWORKDIR/"inventory_merge1_mask2.nc" $fdirWORKDIR/"inventory_merge1_mask3.nc"
# cdo add $fdirWORKDIR/"inventory_merge1_mask3.nc" $fdirWORKDIR/"glwd_tmp.nc" $fdirWORKDIR/"inventory_merge1_mask4.nc"
# cdo setmisstoc,0 $fdirWORKDIR/"inventory_merge1_mask4.nc" $fdirWORKDIR/"inventory_merge1_mask5.nc"
# cdo add $fdirWORKDIR/"inventory_merge1_mask5.nc" $fdirWORKDIR/"inventory_merge1_mask6.nc" $fdirWORKDIR/"inventory_merge1_mask7.nc"
# cdo setctomiss,0 $fdirWORKDIR/"inventory_merge1_mask7.nc" $fdirWORKDIR/"inventory_merge_final.nc"
# 
# #C. Degrade and resample SWAMPS to spread out seasonal cycle to adjacent grid cells
# #cdo remapbil,$fdirCOORD/grid-2degrees.txt $fwSWAMPS $fdirWORKDIR/"swamps_v3_1992-2020_monmean_2deg.nc"
# #cdo remapnn,$fdirCOORD/grid-025degrees.txt $fdirWORKDIR/"swamps_v3_1992-2020_monmean_2deg.nc" $fdirWORKDIR/"swamps_v3_1992-2020_monmean_025deg.nc"
# 
# #D. Correct the SWAMPS Fwmax to match the inventory Fwmax
# cdo div $fdirWORKDIR/"inventory_merge_final.nc" $fdirWORKDIR/"swamps_v3_1992-2020_yearmax.nc" $fdirWORKDIR/"swamps-inv_cf.nc"
# # gec = greater equal constant
# cdo gec,1 $fdirWORKDIR/"swamps-inv_cf.nc" $fdirWORKDIR/"swamps-inv_cf_v1.nc"
# # multiply
# cdo mul $fdirWORKDIR/"swamps-inv_cf.nc" $fdirWORKDIR/"swamps-inv_cf_v1.nc" $fdirWORKDIR/"swamps-inv_cf_v2.nc"
# # setctomiss = Set ocean to missing values
# cdo setctomiss,0 $fdirWORKDIR/"swamps-inv_cf_v2.nc" $fdirWORKDIR/"swamps-inv_cf_v3.nc"
# # Set missing value to constant
# cdo setmisstoc,1 $fdirWORKDIR/"swamps-inv_cf_v3.nc" $fdirWORKDIR/"swamps-inv_corrFactor.nc"
# cdo mul $fdirWORKDIR/"swamps_v3_1992-2020_yearmax.nc" $fdirWORKDIR/"swamps-inv_corrFactor.nc" $fdirWORKDIR/"swamps_v3_1992-2020_yearmax_corr.nc"
# 
# #E. Re-impose the seasonal cycle range relative to the corrected Fwmax
# #Calculate the seasonal cycle scalar first
# cdo div $fwSWAMPS $fdirWORKDIR/"swamps_v3_1992-2020_yearmax.nc" $fdirWORKDIR/"swamps_v3_1992-2020_seasonal_scalar.nc"
# cdo mul $fdirWORKDIR/"swamps_v3_1992-2020_yearmax_corr.nc" $fdirWORKDIR/"swamps_v3_1992-2020_seasonal_scalar.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_wetlandlakes.nc"
# 
# #F. Remove rice and corrected inland waters from the time series
# cdo settaxis,2000-01-16,12:00:00,1mon $riceMIRCA $fdirWORKDIR/"mirca_tmp1.nc"
# cdo yearmax $riceMIRCA $fdirWORKDIR/"mirca_tmp2.nc"
# cdo add $inlandwatersGSW $fdirWORKDIR/"mirca_tmp2.nc" $fdirWORKDIR/"nonwetlands.nc"
# cdo sub $fdirWORKDIR/"swamps_v3_1992-2020_cor_wetlandlakes.nc" $fdirWORKDIR/"nonwetlands.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_v2.nc"
# cdo gec,0 $fdirWORKDIR/"swamps_v3_1992-2020_cor_v2.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_v3.nc"
# cdo mul $fdirWORKDIR/"swamps_v3_1992-2020_cor_v3.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_v2.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_025.nc"
# # 
# # #G. Calculate new max Fw to compare with original
# # cdo ymonmax $fdirWORKDIR/"swamps_v3_1992-2020_cor_025.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_025deg_ymonmax.nc"
# # cdo yearmax $fdirWORKDIR/"swamps_v3_1992-2020_cor_025deg_ymonmax.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_025deg_yearmax.nc"
# # cdo sub $fdirWORKDIR/"swamps_v3_1992-2020_cor_025deg_yearmax.nc" $fdirWORKDIR/"swamps_v3_1992-2020_yearmax.nc" $fdirWORKDIR/"swamps_v3_1992-2020_yearmax_diff.nc"
# # cdo yearmax $fdirWORKDIR/"swamps_v3_1992-2020_cor_025.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_025_eachyearmax.nc"
# # 
# # #H. Create 0.5 degree version and remove years with incomplete monthly swaths
# # cdo remapbil,$fdirCOORD/cru_05deg $fdirWORKDIR/"swamps_v3_1992-2020_cor_025.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_05deg.nc"
# # cdo ymonmax $fdirWORKDIR/"swamps_v3_1992-2020_cor_05deg.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_05deg_ymonmax.nc"
# # cdo yearmax $fdirWORKDIR/"swamps_v3_1992-2020_cor_05deg_ymonmax.nc" $fdirWORKDIR/"swamps_v3_1992-2020_cor_05deg_yearmax.nc"
# 
# #I. Compare with LPJ wetlands
# #cdo ymonmax $wetlandsLPJ $fdirWORKDIR/"lpj_ymonmax.nc"
# #cdo yearmax $fdirWORKDIR/"lpj_ymonmax.nc" $fdirWORKDIR/"lpj_yearmax.nc"
# #cdo sub $fdirWORKDIR/"swamps_v3_1992-2020_cor_05deg_yearmax.nc" $fdirWORKDIR/"lpj_yearmax.nc" $fdirWORKDIR/"swamps_lpj_yearmax_diff.nc"
# 
# #J. Compare with SMAP - kimball
# #cdo ymonmax $wetlandsSMAP $fdirWORKDIR/"smap_ymonmax.nc"
# #cdo yearmax $fdirWORKDIR/"smap_ymonmax.nc" $fdirWORKDIR/"smap_yearmax.nc"
# 
# #K. Compare with Prigent
# #cdo ymonmax $wetlandsPRIG $fdirWORKDIR/"prigent_ymonmax.nc"
# #cdo yearmax $fdirWORKDIR/"prigent_ymonmax.nc" $fdirWORKDIR/"prigent_yearmax.nc"
# #cdo sub $fdirWORKDIR/"swamps_v3_1992-2020_cor_05deg_yearmax.nc" $fdirWORKDIR/"prigent_yearmax.nc" $fdirWORKDIR/"swamps_prigent_yearmax_diff.nc"
# 
# #L. Compare with Inventory
# #cdo sub $fdirWORKDIR/"swamps_v3_1992-2020_cor_025deg_yearmax.nc" $fdirWORKDIR/"inventory_merge_final.nc" $fdirWORKDIR/"swamps_inv_diff.nc"
# 
# #M. Use climatology for filling 1992-1997 missing swaths - DOESNT WORK
# # cdo selyear,2000/2020 $fdirWORKDIR/"swamps_v3_1992-2020_cor_025.nc" $fdirWORKDIR/"swamps_v3_2000-2020_cor_025.nc"
# # cdo selyear,1992/1999 $fdirWORKDIR/"swamps_v3_1992-2020_cor_025.nc" $fdirWORKDIR/"swamps_v3_1992-1999_cor_025.nc"
# 
# #cdo ymonmean $fdirWORKDIR/"swamps_v3_2000-2020_cor_025.nc" $fdirWORKDIR/"swamps_v3_2000-2020_cor_025_ymonmean.nc"
# #cdo gec,0 $fdirWORKDIR/"swamps_v3_1992-1999_cor_025.nc" $fdirWORKDIR/"tmp1.nc"
# #cdo setmisstoc,0 $fdirWORKDIR/"tmp1.nc" $fdirWORKDIR/"tmp2.nc"
# #cdo setctomiss,1 $fdirWORKDIR/"tmp2.nc" $fdirWORKDIR/"tmp3.nc"
# #cdo add $fdirWORKDIR/"swamps_v3_2000-2020_cor_025_ymonmean.nc" $fdirWORKDIR/"tmp3.nc" $fdirWORKDIR/"tmp4.nc"
# #cdo setmisstoc,0 $fdirWORKDIR/"tmp4.nc" $fdirWORKDIR/"tmp5.nc"
# #cdo setmisstoc,0 $fdirWORKDIR/"swamps_v3_1992-1999_cor_025.nc" $fdirWORKDIR/"tmp6.nc"
# #cdo add $fdirWORKDIR/"tmp6.nc" $fdirWORKDIR/"tmp5.nc" $fdirWORKDIR/"tmp7.nc"
# #cdo mergetime $fdirWORKDIR/"tmp7.nc" $fdirWORKDIR/"swamps_v3_2000-2020_cor_025.nc" $fdirWORKDIR/"tmp8.nc"
# 
# #Clean up file history for distribution to group
# # ncatted -h -a ,global,d,, $fdirWORKDIR/"swamps_v3_2000-2020_cor_025.nc" $fdirWORKDIR/"gcp-ch4_wetlands_2000-2020_025deg.nc"
# # ncatted -h -a history,global,c,c,"Project: Global Carbon Project CH4 v2\n" $fdirWORKDIR/"gcp-ch4_wetlands_2000-2020_025deg.nc"
# # ncatted -h -a history,global,a,c,"Created by: benjamin.poulter@nasa.gov\n" $fdirWORKDIR/"gcp-ch4_wetlands_2000-2020_025deg.nc"
# # 
# # cdo remapbil,$fdirCOORD/cru_05deg $fdirWORKDIR/"gcp-ch4_wetlands_2000-2020_025deg.nc" $fdirWORKDIR/"gcp-ch4_wetlands_2000-2020_05deg.nc"
# 
# #
# #cdo selyear,2000/2017 gcp-ch4_wetlands_2000-2020_05deg.nc gcp-ch4_wetlands_2000-2017_05deg.nc
