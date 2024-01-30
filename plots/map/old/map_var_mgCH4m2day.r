
# set output directory
od = '../output/for_map/'
# Run mapping function; this was a functionbc of multiple members
flux_var= paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_var_msk.tif')
# Read flux_var raster
flux_var <- raster(flux_var)

# Calculate sd from var (var =  sd^2)
flux_var <- sqrt(flux_var)

## Apply mask
flux_var <- 
    mask(flux_var, low_flux_mask) %>% 
    WGSraster2dfROBIN(.)


# reformat rasters  for graph in ggplot 


# names(flux_mean_df) <- c( 'x', 'y','layer')
# 

# #  Cut values into discrete ranges, then beautify the labels  
# my_breaks = c(0, 1, 2, 5, 10, 20, 50, 250)
# flux_var_df$layer_cut <- cut(flux_var_df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)
# 
# # replace the categories strings to make them nicer in the legend
# flux_var_df$layer_cut <- gsub('\\(|\\]', '', flux_var_df$layer_cut)
# flux_var_df$layer_cut <- gsub('\\)|\\[', '', flux_var_df$layer_cut)
# flux_var_df$layer_cut <- gsub('\\,', ' to ', flux_var_df$layer_cut)
# flux_var_df <- flux_var_df %>% mutate(layer_cut=ifelse(layer_cut=='50 to 250', '50+', layer_cut))
# 
# # ~~~ set legend order ----------
# legend_order <- rev(c('0 to 1', '1 to 2', '2 to 5', '5 to 10', '10 to 20', '20 to 50', '50+'))
# flux_var_df$layer_cut <- factor(flux_var_df$layer_cut, levels = legend_order)


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------
# towers_robin <- get.towers.robin.df()


# Color palette replicating Saunois 2020
# my_palette <- c(sequential_hcl(10, palette = 'PuBu'), 'grey90')
my_palette <- sequential_hcl(7, palette = 'PuBu')


# Make map
robin_flux_var_map <- ggplot() +
	
	# Background countries; grey in-fill  sPDF_robin_df;  countries_robin_df
  	# geom_polygon(data=countriesCoarse_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +
  
	# flux_var grid
	geom_tile(data=flux_var_df, aes(x=x, y=y, fill=layer)) +
	
	# Coastline
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
	
	# Outline
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +

	# Towers
	# geom_point(data=towers_robin, aes(LON.1, LAT.1), color='black', fill= 'black', shape=21,  size=0.5, stroke=0.1) +
	
	# scale_fill_manual(values = my_palette ) +
	# labs(fill = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1))) +
	coord_equal() +
	# guides(fill = guide_legend(override.aes = list(size = 0.3),
							   # title = 'Standard deviation of flux'))+ #expression(paste("mg(CH"[4]*") m"^-1*" day"^-1)))) +

    scale_fill_gradient(low='#f7d9ff', high='#640080',
                        # breaks=c(0, .25, .20),
                        limits=c(0, 30)) +
    #
    guides(fill = guide_colorbar(nbin=10, raster=F,
                                 barheight = 7, barwidth=.4,
                                 frame.colour=c('black'), frame.linewidth=0.5,
                                 ticks.colour='black',  direction='vertical',
                                 title = 'Coefficient of variation (%)')) +
    
	gif_map_theme +
	theme(	legend.position=  c(0.01, 0.55),
			plot.margin = unit(c(1, -2, 1, 20), 'mm'))

robin_flux_var_map

