# Description: This function 

# /----------------------------------------------------------------------------#
#/   Function inputs: 
#		- flux: single raster mean of flux
#		- datmask: mask to exlude regions without wetlands; bc nmol data covers entire land surface
#		- outfile: string of output filename
mg_map <- function(flux, outfile){

	flux <- raster(flux) # Read flux raster

	# reformat rasters  for graph in ggplot 
	crs(flux) <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0' 
	flux_robin <- projectRaster(flux, crs=CRS('+proj=robin'), method='ngb', over=TRUE)
	flux_df <- as(flux_robin, 'SpatialPixelsDataFrame')
	flux_df <- as.data.frame(flux_df)
	names(flux_df) <- c('layer', 'x', 'y')


	#  Cut values into discrete ranges, then beautify the labels  
	my_breaks = c(0, 0.5, 1, 2, 5, 10, 15, 20, 30, 40, 50, 250)
	flux_df$layer_cut <- cut(flux_df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)

	# replace the categories strings to make them nicer in the legend
	flux_df$layer_cut <- gsub('\\(|\\]', '', flux_df$layer_cut)
	flux_df$layer_cut <- gsub('\\)|\\[', '', flux_df$layer_cut)
	flux_df$layer_cut <- gsub('\\,', ' to ', flux_df$layer_cut)
	flux_df <- flux_df %>% mutate(layer_cut=ifelse(layer_cut=='50 to 250', '50+', layer_cut))

	# ~~~ set legend order ----------
	legend_order <- rev(c('0 to 0.5', '0.5 to 1', '1 to 2',  '2 to 5', '5 to 10', '10 to 15', '15 to 20', 
						   '20 to 30', '30 to 40', '40 to 50','50+'))
	flux_df$layer_cut <- factor(flux_df$layer_cut, levels = legend_order)


	# /----------------------------------------------------------------------------#
	#/     Get tower locations                                               -------
	towers_robin <- get.towers.robin.df()


	# Color palette replicating Saunois 2020
	my_palette <- c(sequential_hcl(10, palette = 'YlOrRd'), 'grey90')


	# Make map
	robinmap <- ggplot() +
		
		# Background countries; grey in-fill  sPDF_robin_df;  countries_robin_df
	  	# geom_polygon(data=countriesCoarse_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +
	  
		# Flux grid
		geom_tile(data=flux_df, aes(x=x, y=y, fill=layer_cut)) +
		
		# Coastline
		geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
		
		# Outline
		geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +

		# Towers
		geom_point(data=towers_robin, aes(LON.1, LAT.1), color='black', fill= 'black', shape=21,  size=0.5, stroke=0.1) +
		
		scale_fill_manual(values = my_palette ) +
		# labs(fill = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1))) +
		coord_equal() +
		guides(fill = guide_legend(override.aes = list(size = 0.3),
								   title = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1)))) +
	
		gif_map_theme +
		theme(	legend.position=  c(0.01, 0.55),
				plot.margin = unit(c(1, -2, 1, 20), 'mm'))


	# save figure
	ggsave(outfile,
		   robinmap,
	       width=180, height=70, dpi=300, units='mm') #type = 'cairo-png')
	dev.off()

	}




#'/home/groups/robertj2/upch4/output/figures/ch4_mean_v200_g_m2_day_saunois2020legend_robin.png', 
# # /----------------------------------------------------------------------------
# #/ GET UNWEIGHTED AS MASK 
# med_stack <- brick('../output/results/grids/v02/rf_med_ch4_monthly_2001_2018.tif')
# datmask <- med_stack[[1]]

# # /----------------------------------------------------------------------------#
# #/    Get predicted flux grid
# flux <- raster('../output/results/grids/v02/rf_mean_ch4_2001_2018_mg_m2_day.tif')

	# labs(fill = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1))) +
		# guides(fill = guide_colorbar(#nbin=10, #raster=F, 
                             # barheight = 3.5, barwidth=0.5, 
                             # frame.colour=c("black"), frame.linewidth=0.2, 
                             # ticks.colour="black", ticks.linewidth = 0.15,  
                             # direction="vertical",
                             # title = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1)))) +
# m <- ggplot() +
	
# 	# background countries
#   	geom_polygon(data=sPDF, aes(long, lat, group=group), 
#             color=NA, fill='grey95') +
  
# 	# Flux grid
# 	geom_tile(data=flux_df, aes(x=x, y=y, fill=layer_cut)) +
	
# 	# Coastline
# 	geom_path(data=coastsCoarse, aes(long, lat, group=group), 
# 	          color='black', size=0.08) +
	
# 	# Tower sites
# 	geom_point(data=bams_towers, aes(LON.1, LAT.1), #aes(Longitude, Latitude),
# 		color='black', fill= 'black', shape=21,  size=0.5, stroke=0.1) +
	
# 	# Write title as month-day format
# 	# ggtitle(substr(mymonths[t])) + 
# 	# ggtitle(mymonths[t]) + 
# 	#geom_text(aes(90, 0, label=substr(parseddates[t], 1, 7), size=4)) + 
	
# 	# Set scales (setting longitude can create tearing)
# 	#scale_x_continuous(limits=c(-180.1, 180.1))+
# 	scale_y_continuous(limits=c(-60, 90))+
# 	# scale_fill_distiller(palette='YlOrRd', direction=1, limits=c(0, 0.02), 
# 	# 					 breaks=c(0, 0.001, 0.005, 0.01, 0.02),
# 	# 					 #breaks=seq(0, 0.02, 0.002),
# 	# 					 labels=format_format(scientific = FALSE)) +

# 	scale_fill_manual(values = my_palette) +

# 	# scale_fill_gradientn(colors= rev(sequential_hcl(10, palette = 'YlOrRd')), 
# 	# 					trans='log', 
# 	# 					breaks=c(10^-1, 10^0, 10^1, 10^2),
# 	# 					#labels=c(10^-5, 10^-4, 10^-3, 10^-2),
# 	# 					labels=c(expression(10^{-1}),
# 	# 					         expression(10^{0}),
# 	# 					         expression(10^{1}),
# 	# 					         expression(10^{2})),
# 	# 					limits=c(lw_cut, 10^{2})) +


# 	# Format colorbar
# 	# guides(fill = guide_colorbar(nbin=10, raster=F, 
# 	#                              barheight = 3.5, barwidth=0.5, 
# 	#                              frame.colour=c('black'), frame.linewidth=0.2, 
# 	#                              ticks.colour='black', ticks.linewidth = 0.15,  
# 	#                              direction='vertical',
# 	#                              title = expression(paste('mg(CH'[4]*') m'^-2*' day'^-1)))) +
  				

# 	coord_equal() +
# 	gif_map_theme +      
# 	theme(	legend.position= c(0.01, 0.35),
# 			plot.margin = unit(c(1, -3, 1, 7), 'mm'))

# ggsave('/home/groups/robertj2/upch4/output/figures/ch4_mean_v200_g_m2_day_saunois2020legend.png', m,
#        width=120, height=60, dpi=400, units='mm') #type = 'cairo-png')
# dev.off()



