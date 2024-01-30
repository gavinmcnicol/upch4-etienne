
# /----------------------------------------------------------------------------#
#/ GIEMSv2; reprojected in WGS84; 288 months ; 24 years (1992-2015) 
giems2_aw <- stack('../../Chap3_holocene_global_wetland_loss/output/results/natwet/preswet/giems2_aw_v3.tif')[[109:288]]
# giems2_awmax <- max(giems2, na.rm=T)

# Get pixel area
pixarea <- area(giems2)

# Get maximum fraction
giems2_fmax <- max( giems2_aw / pixarea, na.rm=T)


# /----------------------------------------------------------
#/ Correction layers (fmax)
ncscd <- stack('../../Chap3_holocene_global_wetland_loss/data/natwet/wad2m_corr_layers/NCSCD_fraction_025deg.nc')
cifor <- stack('../../Chap3_holocene_global_wetland_loss/data/natwet/wad2m_corr_layers/cifor_wetlands_area_025deg_frac.nc')
glwd <- stack('../../Chap3_holocene_global_wetland_loss/data/natwet/wad2m_corr_layers/GLWD_wetlands_025deg_frac.nc')
glwd <- crop(glwd, extent(-180, 180, 40, 60)) # Crop GLWD to only temperate latitudes outside of CIFOR & NCSCD
glwd <- raster::extend(glwd, extent(-180, 180, -90, 90), value=NA)

# /----------------------------------------------------------------------------#
#/  Assemble three correction factor inputs into a single layer
fmax <- stack(ncscd, cifor, glwd)
fmax <- max(fmax, na.rm=T)



# OFFSET
# Calculate fw correction factor; an offset for the long term max
# Apply 0 to pixels where giems_max > fwmax
fwcorr <- overlay(fmax, giems2_fmax, fun = function(x, y) {z <- x-y; z[z<0] <- 0; z})
fwcorr[is.na(fwcorr)] <- 0


# FACTOR
# Calculate fw correction factor; a factor for the long term max
# Apply 0 to pixels where giems_max > fwmax
fwcorr <- overlay(fmax, giems2_fmax, fun = function(x, y) {z <- x/y; z[z<1] <- 1; z})
fwcorr[is.na(fwcorr)] <- 1
fwcorr[!is.finite(fwcorr)] <- 1
fwcorr[fwcorr>10] <- 10

plot(fwcorr)
hist(fwcorr)

# /----------------------------------------------------------------------------#
#/  Get static correction layer

# RICE COVERAGE  - 12 months
mirca <- stack('../../Chap3_holocene_global_wetland_loss/data/natwet/wad2m_corr_layers/MIRCA_monthly_irrigated_rice_area_025deg_frac.nc')

# COASTLINE WATER - STATIC
MODIS_coast <- stack('../../Chap3_holocene_global_wetland_loss/data/natwet/wad2m_corr_layers/MODIS_coastal_mask_0.25deg.nc')

# JRC water cover 2000-01-01 and 2019-01-10; 240 months
# using this monthly GSW cover would remove both inland and ocean water so it could become the sole water mask (and replace the step with MOD44W).  If you prefer using JRC only inland, then I would landmask the JRC before aggregating to exclude ocean water. 
jrc <- stack('../data/jrc_agg_inundperc_combined_oceanfix.tif')[[13:192]]


# /----------------------------------------------------------------------------#
#/ Loop through each monthly layer...

# Make output stack
giems2_corr <- stack()


for (i in seq(1, nlayers(giems2_aw))){
    
    print(i) # Print index
    
    # Subset layer, convert to fraction, then apply correction factor 
    temp <- (giems2_aw[[i]] / area)
    
    
    # temp <- temp + fwcorr
    temp <- temp * fwcorr
    temp[temp>1] <- 1   # Cap at 1

    month <- c(12, seq(1, 12), 12) # make numeric list for MIRCA months
    m <- month[(i %% 12)+1]

    # Subtract the correction layers: MIRCA & JRC month
    # no longer use MODIS_coast bc it is included in JRC now
    temp <- temp - mirca[[m]] - jrc[[i]]
    temp[temp<0] <- 0
    
    # Convert back to area
    temp <- temp * area   
    
    # Stack grid with other one
    giems2_corr <- stack(giems2_corr, temp)
    
    }

# Save to file
names(giems2_corr) <- paste0('X', seq(1, nlayers(giems2_corr)))
writeRaster(giems2_corr, '../output/giems2_corr.tif')


# /----------------------------------------------------------------------------#
#/ Calculate sum
giems2_aw_na <- stack('../../Chap3_holocene_global_wetland_loss/output/results/natwet/preswet/giems2_aw_v3_na.tif')[[109:288]]

orig_sums <- as.data.frame(cellStats(giems2_aw_na, sum, na.rm=T))
corr_sums <- as.data.frame(cellStats(giems2_corr, sum, na.rm=T))

corr_sums <- corr_sums %>% mutate(time= row.names(.)) %>% as_tibble()
names(corr_sums) <- c('area','time') 
corr_sums <- corr_sums %>% mutate(time=as.numeric(time))
corr_sums$source <- 'GIEMS2 - corrected'

# Process original GIEMS sum
orig_sums <- orig_sums %>% mutate(time= row.names(.)) %>% as_tibble()
names(orig_sums) <- c('area','time') 
orig_sums <-  orig_sums %>%  mutate(time=seq(1, nrow(orig_sums)))
orig_sums$source <- 'GIEMS2 - original'


wad2m <- stack('../../Chap3_holocene_global_wetland_loss/data/natwet/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc')# [[109:121]]#[[109:288]]
wad2m <- wad2m * area
wad2m_sums <- as.data.frame(cellStats(wad2m[[1:180]], sum, na.rm=T))


wad2m_sums <- wad2m_sums %>%  mutate(time= row.names(.)) %>% as_tibble()
names(wad2m_sums) <- c('area','time') 
wad2m_sums <- wad2m_sums %>%  mutate(time=seq(1, nrow(wad2m_sums)))
wad2m_sums$source <- 'WAD2M'


comb_sums <- bind_rows(corr_sums, orig_sums, wad2m_sums)

dates <- seq(as.Date("2001-01-01"), as.Date("2015-12-01"), by="months")
# dates <- date_trans()

# /----------------------------------------------------------------------------#
#/ Make lineplot
ggplot(comb_sums) +
    geom_line(aes(x=time, y=area/10^6, color=source), size=.4) +
    # geom_point(aes(x=time, y=area/10^6, color=source), size=.5) +
    scale_y_continuous(limits=c(0, 6), expand=c(0, 0) ) +
    scale_x_continuous(expand=c(0, 0)) + #, labels=as.Date.character(dates)) +
    scale_color_brewer(palette='Set2') +
    xlab('Months since 2001/01/01') + ylab('Monthly wetland area (Mkm2)') +
    theme_bw() +
    theme(legend.position = 'top',
          legend.title = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(color='grey90', size=0.1))

ggsave('../output/figures/giems2_corr_Aw_lineplot_comparison.png',
       width=180, height=100, dpi=300, units='mm')
dev.off()



# 
r <- as.data.frame(fwcorr) %>% as_tibble()
ggplot(r) + geom_histogram(aes(x=layer), bins=50)


# 
r <- as.data.frame(temp) %>% as_tibble()
ggplot(r) + geom_histogram(aes(x=layer), bins=50)
