
#########################################################

constituency <- dist_glob %>% 
				dplyr::select(min_dist, min_dist_di, wet_area, closest_tower, x, y) %>%
				group_by(closest_tower) %>%
				summarize(wet_area_1000km2 = sum(wet_area, na.rm=T)/1000,
						  mean_dist_di = mean(min_dist_di, na.rm=T),
						  stdev_dist_di = sd(min_dist_di, na.rm=T)) %>%
				ungroup() %>%
				mutate(uppersd_dist_di = mean_dist_di + (stdev_dist_di/2),
					   lowersd_dist_di = mean_dist_di - (stdev_dist_di/2))


# /--------------------------------------------------------------------
#/
const_scatter <- ggplot(constituency) +
	geom_point(aes(x=wet_area_1000km2, y=mean_dist_di), size=0.9) +
	geom_errorbar(aes(x=wet_area_1000km2, ymin=lowersd_dist_di, ymax=uppersd_dist_di), width=0.3) +

	# add labels
	geom_text_repel(data= subset(constituency, wet_area_1000km2>50 | mean_dist_di>0.8),
	              aes(label=closest_tower, x=wet_area_1000km2, y=mean_dist_di), 
	              size = 2, 
	              colour='blue', 
	              segment.size = 0.25, 
	              segment.color='blue',
	              force = 5,
	              box.padding = unit(0.2, 'lines'),
	              point.padding = unit(0.2, 'lines')) +

	xlab('Constituency wetland area (1000 km2)') +
	ylab('Dissimilarity index') +
	line_plot_theme +
	theme(panel.border = element_rect(color = "black", fill = NA, size = 0.5))



# save figure
ggsave('../output/figures/representativeness/constituency_scatterplot_nosalt.png', const_scatter,
       width=120, height=100, dpi=300, units='mm') #type = 'cairo-png')
dev.off()


# Filter to big constituencies for map
constituency_sel <- constituency %>% filter(wet_area_1000km2 > 180)


# /------------------------------------------------------------------------
#/  Make map
constituency_robinmap <- 
	ggplot() +
	
	# countries background & outline
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90', color='white', size=0.08) +

	# Coastline
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey70', size=0.1) +

	# Flux grid
	geom_tile(data=subset(dist_glob, closest_tower %in% constituency_sel$closest_tower), 
			aes(x=x, y=y, fill=closest_tower)) +
	
	# Coastline
	# geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
	
	# Outline
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +

	# Towers
	geom_point(data=towers_robin, aes(LON.1, LAT.1), color='black', fill= 'black', shape=21,  size=0.5, stroke=0.1) +

	# scale_fill_continuous(low="white", high="red", limits=c(0,2), na.value = "red") +
	# scale_fill_manual(values = my_palette ) +
	# labs(fill = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1))) +
	coord_equal() +
	# guides(fill = guide_legend(override.aes = list(size = 0.3),
	# 						   title = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1)))) +
	gif_map_theme +
	theme(	legend.position=  c(0.01, 0.55),
		plot.margin = unit(c(1, -2, 1, 20), 'mm'))


# save figure
ggsave('../output/figures/representativeness/tower_constituency_map_1percfw_v2_nosalt2.png', constituency_robinmap,
       width=180, height=70, dpi=300, units='mm') #type = 'cairo-png')
dev.off()



# # set global extent to plot
# com_ext <- extent(-180, 180,  -56, 85)

# # Append robin proj coordinates
# dist_glob <- bind_cols(dist_glob, vars_msk_robin_df[,c('x','y')])

# # # Get coordinates from the tower data
# coords <- cbind(dist_glob$x, dist_glob$y)

# # # Make spatial objects
# dist_pts <- SpatialPointsDataFrame(coords, dist_glob[,c(49:53)])
#  r <- rasterFromXYZ(dist_pts[, c("x", "y", "min_dist")])


# flux <- raster(flux)
# datmask <- stack(datmask)[[1]]

# flux <- mask(flux, datmask)

# reformat rasters  for graph in ggplot 
# crs(flux) <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0' 
# flux_robin <- projectRaster(flux, crs=CRS('+proj=robin'), method='ngb', over=TRUE)
# flux_df <- as(flux_robin, 'SpatialPixelsDataFrame')
# flux_df <- as.data.frame(flux_df)
# names(flux_df) <- c('layer', 'x', 'y')


# #  Cut values into discrete ranges, then beautify the labels  
# my_breaks = c(0, 0.5, 1, 2, 5, 10, 15, 20, 30, 40, 50, 150)
# flux_df$layer_cut <- cut(flux_df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)

# # replace the categories stings to make them nicer in the legend
# flux_df$layer_cut <- gsub('\\(|\\]', '', flux_df$layer_cut)
# flux_df$layer_cut <- gsub('\\)|\\[', '', flux_df$layer_cut)
# flux_df$layer_cut <- gsub('\\,', ' to ', flux_df$layer_cut)
# flux_df <- flux_df %>% mutate(layer_cut=ifelse(layer_cut=='50 to 150', '50+', layer_cut))

# # ~~~ set legend order ----------
# legend_order <- rev(c('0 to 0.5', '0.5 to 1', '1 to 2',  '2 to 5', '5 to 10', '10 to 15', '15 to 20', 
# 					   '20 to 30', '30 to 40', '40 to 50','50+'))
# flux_df$layer_cut <- factor(flux_df$layer_cut, levels = legend_order)