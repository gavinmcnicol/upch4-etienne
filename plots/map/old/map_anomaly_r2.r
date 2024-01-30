# Aggregate low flux map to 1deg
low_flux_mask_1 <- aggregate(low_flux_mask, fact=4, na.rm=T)


# Get CArbon tracker anomaly grid
ct_r2_df <- 
    raster('../output/anomaly_r2/upch4_ct_anomaly_r2.tif') %>% 
    # Apply mask
    mask(., low_flux_mask_1) %>% 
    WGSraster2dfROBIN(.) %>% 
    as_tibble()

# Rename layer
names(ct_r2_df) <- c('x','y','layer')


#  Cut values into discrete ranges, then beautify the labels
# my_breaks = c(0, 1, 5, 10, 20, 50, 100, 500)
# my_breaks = seq(0, 1, .10)
# 
# ct_r2_df$layer_cut <- cut(ct_r2_df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)
# 
# # replace the categories strings to make them nicer in the legend
# ct_r2_df$layer_cut <- gsub('\\(|\\]', '', ct_r2_df$layer_cut)
# ct_r2_df$layer_cut <- gsub('\\)|\\[', '', ct_r2_df$layer_cut)
# ct_r2_df$layer_cut <- gsub('\\,', ' to ', ct_r2_df$layer_cut)
# # ct_r2_df <- ct_r2_df %>% mutate(layer_cut=ifelse(layer_cut=='50 to 250', '50+', layer_cut))
# 
# # ~~~ set legend order ----------
# legend_order <- rev(c('0 to 0.1', '0.1 to 0.2', '0.2 to 0.3', '0.3 to 0.4', '0.4 to 0.5', '0.5 to 0.6', 
#                       '0.6 to 0.7', '0.7 to 0.8', '0.8 to 0.9', '0.9 to 1'))
# ct_r2_df$layer_cut <- factor(ct_r2_df$layer_cut, levels = legend_order)


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------
# towers_robin <- get.towers.robin.df()


# Color palette replicating Saunois 2020
my_palette <- sequential_hcl(10, palette = 'Purples') #'PuBuGn')

# Make map
ct_r2_map <- 
    
    ggplot() +
	# Background countries; grey in-fill  sPDF_robin_df;  countries_robin_df
  	# geom_polygon(data=countriesCoarse_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +
  
	# Flux grid
	geom_tile(data=ct_r2_df, aes(x=x, y=y, fill=layer)) +
	
	# Coastline
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
	
	# Outline
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
    coord_equal() +

	# scale_fill_manual(values = my_palette ) +
    # scale_fill_gradientn(colors=c('#d6b0ff', '#4d00a1')) +

	# guides(fill = guide_legend(override.aes = list(size = 0.3),
	# 						   title = "Pearson's R2")) +

    scale_fill_gradient(low='#f7d9ff', high='#640080',
                        breaks=c(0, .25, .50, .75, 1),
                        limits=c(0, 1)) +
    #
    guides(fill = guide_colorbar(nbin=10, raster=F,
                                 barheight = 7, barwidth=.4,
                                 frame.colour=c('black'), frame.linewidth=0.5,
                                 ticks.colour='black',  direction='vertical',
                                 title = expression(paste("Pearson's R2")))) +
    
    
	gif_map_theme +
	theme(	legend.position=  c(0.01, 0.55),
			plot.margin = unit(c(1, -2, 1, 20), 'mm'))


ct_r2_map


#///////////////////////////////////////////////////////////////////


# set output diregcpory
gcp_r2 = raster('../output/anomaly_r2/upch4_gcp_anomaly_r2.tif')
gcp_r2 <- mask(gcp_r2, low_flux_mask_1)
gcp_r2_df <- WGSraster2dfROBIN(gcp_r2)
names(gcp_r2_df) <- c('x','y','layer')



#  Cut values into discrete ranges, then beautify the labels
# # my_breaks = c(0, 1, 5, 10, 20, 50, 100, 500)
# my_breaks = seq(0, 1, .10)
# 
# gcp_r2_df$layer_cut <- cut(gcp_r2_df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)
# 
# # replace the categories strings to make them nicer in the legend
# gcp_r2_df$layer_cut <- gsub('\\(|\\]', '', gcp_r2_df$layer_cut)
# gcp_r2_df$layer_cut <- gsub('\\)|\\[', '', gcp_r2_df$layer_cut)
# gcp_r2_df$layer_cut <- gsub('\\,', ' to ', gcp_r2_df$layer_cut)
# # gcp_r2_df <- gcp_r2_df %>% mutate(layer_cut=ifelse(layer_cut=='50 to 250', '50+', layer_cut))
# 
# # ~~~ set legend order ----------
# legend_order <- rev(c('0 to 0.1', '0.1 to 0.2', '0.2 to 0.3', '0.3 to 0.4', '0.4 to 0.5', '0.5 to 0.6', 
#                       '0.6 to 0.7', '0.7 to 0.8', '0.8 to 0.9', '0.9 to 1'))
# gcp_r2_df$layer_cut <- factor(gcp_r2_df$layer_cut, levels = legend_order)


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------
# towers_robin <- get.towers.robin.df()


# Color palette replicating Saunois 2020
my_palette <- sequential_hcl(10, palette = 'PuBuGn')

# Make map
gcp_r2_map <- 
    
    ggplot() +
    # Background countries; grey in-fill  sPDF_robin_df;  countries_robin_df
    # geom_polygon(data=countriesCoarse_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +
    
    # Flux grid
    geom_tile(data=gcp_r2_df, aes(x=x, y=y, fill=layer)) +
    
    # Coastline
    geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
    
    # Outline
    geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
    
    # Towers
    # geom_point(data=towers_robin, aes(LON.1, LAT.1), color='black', fill= 'black', shape=21,  size=0.5, stroke=0.1) +
    
    # scale_fill_manual(values = my_palette ) +
    # labs(fill = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1))) +
    coord_equal() +
    
    scale_fill_gradient(low='#f7d9ff', high='#640080',
                        breaks=c(0, .25, .40),
                        limits=c(0, .4)) +
    #
    guides(fill = guide_colorbar(nbin=10, raster=F,
                                 barheight = 7, barwidth=.4,
                                 frame.colour=c('black'), frame.linewidth=0.5,
                                 ticks.colour='black',  direction='vertical',
                                 title = expression(paste("Pearson's R2")))) +

    gif_map_theme +
    theme(	legend.position=  c(0.01, 0.55),
           plot.margin = unit(c(1, -2, 1, 20), 'mm'))

gcp_r2_map





#///////////////////////////////////////////////////////////////////


# set output direwcory
wc_r2 = raster('../output/anomaly_r2/upch4_wc_anomaly_r2.tif')
wc_r2 <- mask(wc_r2, low_flux_mask_1)
wc_r2_df <- WGSraster2dfROBIN(wc_r2)
names(wc_r2_df) <- c('x','y','layer')



#  Cut values into discrete ranges, then beautify the labels
# my_breaks = c(0, 1, 5, 10, 20, 50, 100, 500)
my_breaks = seq(0, 1, .10)

wc_r2_df$layer_cut <- cut(wc_r2_df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)

# replace the categories strings to make them nicer in the legend
wc_r2_df$layer_cut <- gsub('\\(|\\]', '', wc_r2_df$layer_cut)
wc_r2_df$layer_cut <- gsub('\\)|\\[', '', wc_r2_df$layer_cut)
wc_r2_df$layer_cut <- gsub('\\,', ' to ', wc_r2_df$layer_cut)
# wc_r2_df <- wc_r2_df %>% mutate(layer_cut=ifelse(layer_cut=='50 to 250', '50+', layer_cut))

# ~~~ set legend order ----------
legend_order <- rev(c('0 to 0.1', '0.1 to 0.2', '0.2 to 0.3', '0.3 to 0.4', '0.4 to 0.5', '0.5 to 0.6', 
                      '0.6 to 0.7', '0.7 to 0.8', '0.8 to 0.9', '0.9 to 1'))
wc_r2_df$layer_cut <- factor(wc_r2_df$layer_cut, levels = legend_order)


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------
# towers_robin <- get.towers.robin.df()


# Color palette replicating Saunois 2020
my_palette <- sequential_hcl(10, palette = 'PuBuGn')

# Make map
wc_r2_map <- 
    
    ggplot() +
    # Background countries; grey in-fill  sPDF_robin_df;  countries_robin_df
    # geom_polygon(data=countriesCoarse_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +
    
    # Flux grid
    geom_tile(data=wc_r2_df, aes(x=x, y=y, fill=layer_cut)) +
    
    # Coastline
    geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
    
    # Outline
    geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
    
    # Towers
    # geom_point(data=towers_robin, aes(LON.1, LAT.1), color='black', fill= 'black', shape=21,  size=0.5, stroke=0.1) +
    
    scale_fill_manual(values = my_palette ) +
    # labs(fill = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1))) +
    coord_equal() +
    guides(fill = guide_legend(override.aes = list(size = 0.3),
                               title = "Pearson's R2"))+ #expression(paste("mg(CH"[4]*") m"^-1*" day"^-1)))) +
    
    gif_map_theme +
    theme(	legend.position=  c(0.01, 0.55),
           plot.margin = unit(c(1, -2, 1, 20), 'mm'))

wc_r2_map


library(ggpubr)
d <- ggarrange(gcp_r2_map, 
               wc_r2_map,
               ct_r2_map,
               ncol=1, labels = c('A', 'B', 'C'),
               align='h')


ggsave('../output/figures/anomaly_r2_map_v04_3panels.png',
       d, width=180, height=240, dpi=300, units='mm')
dev.off()

