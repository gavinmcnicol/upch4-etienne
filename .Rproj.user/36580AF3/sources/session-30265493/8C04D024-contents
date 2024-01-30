
# /----------------------------------------------------------------------------#
#/ GIEMSv2; reprojected in WGS84; 288 months ; 24 years (1992-2015) 
giems2_aw <- rast('../../Chap3_wetland_loss/output/results/natwet/preswet/giems2_aw_v3.tif')[[109:288]]
# giems2_awmax <- max(giems2, na.rm=T)

# Get pixel area
pixarea <- cellSize(giems2_aw, mask=FALSE) / 10^6

# Convert back to fraction
giems2_fw <- giems2_aw / pixarea

# /----------------------------------------------------------------------------#
#/   Compute GIEMSv2 MAMAX                                         -------------
# Make group label list; labels rasters from same timestep together
groupn = function(n,m){rep(1:m,rep(n/m,m))}

nlay <- length(names(giems2_fw))

# Make list of group labels
timestep_grp = groupn(nlay, nlay/12 )

f = function(x){tapply(x, timestep_grp, max, na.rm=T)}

# Calculate annual maximum
giems2_fw_mamax <- app(giems2_fw, fun=f)
giems2_fw_mamax <- mean(giems2_fw_mamax, na.rm=T)
giems2_fw_mamax[giems2_fw_mamax>1] <- 1
giems2_fw_mamax[!is.finite(giems2_fw_mamax)] <- 1

# /----------------------------------------------------------------------------#
#/   Get Correction layers (fmax)
ncscd <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/NCSCD_fraction_025deg.nc')
cifor <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/cifor_wetlands_area_025deg_frac.nc')
glwd <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/GLWD_wetlands_025deg_frac.nc')
glwd <- crop(glwd, extent(-180, 180, 40, 60)) # Crop GLWD to only temperate latitudes outside of CIFOR & NCSCD
glwd <- extend(glwd, extent(-180, 180, -90, 90)) #, value=NA)

#/  Assemble three correction factor inputs into a single layer
corr_fmax <- c(ncscd, cifor, glwd)
corr_fmax <- max(corr_fmax, na.rm=T)


# /----------------------------------------------------------------------------#
#/  CORRECTION FACTOR
# Calculate fw correction factor; a factor for the long term max
# Apply 0 to pixels where giems_max > fwmax
# fwcorr <- overlay(corr_fmax, giems2_fw_mamax, fun = function(x, y) {z <- x/y; z[z<1] <- 1; z})
fwcorr <- lapp(c(corr_fmax, giems2_fw_mamax), fun = function(x, y) {z <- x/y; z[z<1] <- 1; z})
fwcorr[is.na(fwcorr)] <- 1
fwcorr[!is.finite(fwcorr)] <- 1
# fwcorr[fwcorr>20] <- 20  # Set ceiling of scaling factor

plot(fwcorr)
hist(fwcorr)

# /----------------------------------------------------------------------------#
#/  Get static correction layer

# RICE COVERAGE  - 12 months
mirca <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/MIRCA_monthly_irrigated_rice_area_025deg_frac.nc')

# COASTLINE WATER - STATIC
MODIS_coast <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/wad2m_corr_layers_v1/MODIS_coastal_mask_0.25deg.nc')

# JRC water cover 2000-01-01 and 2019-01-10; 240 months
# using this monthly GSW cover would remove both inland and ocean water so it could become the sole water mask (and replace the step with MOD44W).  
# If you prefer using JRC only inland, then I would landmask the JRC before aggregating to exclude ocean water. 
jrc <- rast('../data/jrc_agg_inundperc_combined_oceanfix.tif')[[13:192]]


# /----------------------------------------------------------------------------#
#/ Loop through each monthly layer...

# Prep output 
giems2_corr <- rast()


for (i in seq(1, nlyr(giems2_aw))){
    
    print(i) # Print index
    
    # Subset layer, convert to fraction, then apply correction factor 
    temp <- (giems2_aw[[i]] / pixarea)
    
    # Apply correction factor
    temp <- temp * fwcorr 

    # Get Month position from modulo for MIRCA months
    month <- c(12, seq(1, 12), 12)
    m <- month[(i %% 12)+1]

    # Subtract the correction layers: MIRCA & JRC month
    # no longer use MODIS_coast bc it is included in JRC now
    temp <- temp - mirca[[m]] - jrc[[i]]
    
    # Force within 0-1 range
    temp[temp<0] <- 0
    temp[temp>1] <- 1
    
    # Convert back to area
    temp <- temp * pixarea
    
    # Stack grid with other one
    giems2_corr <- c(giems2_corr, temp)
    
    }

# Save to file
names(giems2_corr) <- paste0('X', seq(1, nlyr(giems2_corr)))
writeRaster(giems2_corr, '../output/giems2_corr_v1_2023a.tif')

# /----------------------------------------------------------------------------#
#/    OFFSET. 
# Calculate fw correction factor; an offset for the long term max
# Apply 0 to pixels where giems_max > fwmax
# fwcorr <- overlay(fmax, giems2_fmax, fun = function(x, y) {z <- x-y; z[z<0] <- 0; z})
# fwcorr[is.na(fwcorr)] <- 0
# temp <- temp + fwcorr

