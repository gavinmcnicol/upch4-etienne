# /----------------------------------------------------------------------------#
#/    Get other plotting obj

#  Cut values into discrete ranges, then beautify the labels  
# my_breaks = c(0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 30)
my_breaks = c(0, 0.2, 0.4, 0.6, .8, 1, 30)
dist_glob$min_dist_di_cut <- cut(dist_glob$min_dist_di, breaks=my_breaks, right=FALSE, dig.lab=10)

# replace the categories stings to make them nicer in the legend
dist_glob$min_dist_di_cut <- gsub('\\(|\\]', '', dist_glob$min_dist_di_cut)
dist_glob$min_dist_di_cut <- gsub('\\)|\\[', '', dist_glob$min_dist_di_cut)
dist_glob$min_dist_di_cut <- gsub('\\,', ' to ', dist_glob$min_dist_di_cut)
dist_glob <- dist_glob %>% mutate(min_dist_di_cut=ifelse(min_dist_di_cut=='1 to 30', '1+', min_dist_di_cut))

# ~~~ set legend order ----------
# legend_order <- rev(c('0 to 0.25', '0.25 to 0.5', '0.5 to 0.75', '0.75 to 1', '3+'))
legend_order <- rev(c('0 to 0.2', '0.2 to 0.4', '0.4 to 0.6', '0.6 to 0.8', '0.8 to 1', '1+'))
dist_glob$min_dist_di_cut <- factor(dist_glob$min_dist_di_cut, levels = legend_order)


# Set color palette
my_palette <- c( sequential_hcl(8, palette = 'YlOrRd'))
my_palette <- my_palette[1:6]

# Set color palette
# my_palette <- c( sequential_hcl(12, palette = 'Inferno'))
# my_palette <- my_palette[seq(1, 12, 2)]


# /-----------------------------------------------------------------------------------------#
#/ Make map
dist_map_robin <- ggplot() +
	
	# countries background & outline
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90', color='white', size=0.08) +
	# Coastline
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey70', size=0.1) +
	# DI grid
	# geom_tile(data=subset(dist_glob, !is.na(min_dist_di_cut)), aes(x=x, y=y, fill=min_dist_di_cut)) +
	geom_tile(data=dist_glob, aes(x=x, y=y, fill=min_dist_di_cut)) +

	# Coastline
	# geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
	# Bounding box Outline
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color="black", size=0.08) +
	# Towers
	geom_point(data=towers_robin_df, aes(coords.x1, coords.x2), color='black', fill= 'white', shape=21,  size=0.9, stroke=0.35) +
	# scale_fill_continuous(low="white", high="red", limits=c(0,2), na.value = "red") +
	scale_fill_manual(values = my_palette) +
	labs(fill="Dissimilarity\nscore") +
	gif_map_theme +
	theme(legend.position=  c(0.05, 0.5),
		  plot.margin = unit(c(1, -2, 1, 20), 'mm'))


# save figure
if (1) {
	ggsave('../output/figures/representativeness/min_dist_map_5percfw_4preds_v4_hidpi.png', dist_map_robin,
	       width=180, height=70, dpi=800, units='mm') #type = 'cairo-png')
	dev.off()}


# /---------------------------------------------------------------------------------
#/  HISTORGRAM?
h <- ggplot(subset(dist_glob, min_dist_di<3)) +
	 geom_histogram(aes(x=min_dist_di), bins=50) +
	 xlab('Dissimilary index')


# save figure
ggsave('../output/figures/representativeness/min_dist_hist_5percfw_v4_NOV2020.png', h,
       width=80, height=70, dpi=300, units='mm') #type = 'cairo-png')
dev.off()



# /--------------------------------------------------------------------------------
#/  PREP FOR CONSTITUENCY MAP
constituency <- dist_glob %>% 
				dplyr::select(min_dist, min_dist_di, closest_tower, wet_area, x, y) %>%
				group_by(closest_tower) %>%
				summarize(area_1000km2 = sum(wet_area, na.rm=T)/1000,
						  mean_dist_di = mean(min_dist_di, na.rm=T),
						  std_dist_di = sd(min_dist_di, na.rm=T),) %>%
				ungroup()

constituency_filt <- constituency %>% filter(area_1000km2>200)

# filter pixels to those inside
dist_glob_filt <- dist_glob %>% filter(closest_tower %in% constituency_filt$closest_tower)

selected_towers <- towers_robin_df %>% filter(SITE_ID %in% constituency_filt$closest_tower)


#-------------------------------------------------------------------------------------
# Make constituency map
consti_map_robin <- ggplot() +

	# countries background & outline
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90', color='white', size=0.08) +
	# Coastline
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey70', size=0.1) +
	# Flux grid
	geom_tile(data=subset(dist_glob_filt, !is.na(min_dist_di_cut)), aes(x=x, y=y, fill=closest_tower)) +
	# Outline
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
	# All Towers
	geom_point(data=towers_robin_df, aes(coords.x1, coords.x2), color='black', fill= 'white', shape=21,  size=0.9, stroke=0.35) +
	# Towers with large constituencies
	geom_point(data=selected_towers, aes(coords.x1, coords.x2, fill=SITE_ID), color='black', shape=21,  size=2.6, stroke=0.45) +
	# coord_equal() +
	labs(fill="Tower\nConstituency") +
	guides(shape="none") +
	gif_map_theme +
	theme(legend.position= c(0.05, 0.5),
		  plot.margin  = unit(c(1, -2, 1, 20), 'mm'))


# /-------------------------------------------------------------
#/ CONVERT DIST BACK TO WGS84 LATITUDES
dist_glob_robin_coords <- cbind(dist_glob$x, dist_glob$y)

### Make spatial objects
dist_glob_robin_pts <- SpatialPointsDataFrame(dist_glob_robin_coords, dist_glob)
crs(dist_glob_robin_pts) =  CRS('+proj=robin')

dist_glob_wgs84_pts = spTransform(dist_glob_robin_pts, CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'))
dist_glob_wgs84_df = data.frame(dist_glob_wgs84_pts)


my_breaks = seq(-60, 90, 10)
med_pts <- seq(-55, 85, 10)
dist_glob_wgs84_df$coords.x2_cut <- cut(dist_glob_wgs84_df$coords.x2, breaks=my_breaks, right=FALSE, dig.lab=10, labels=med_pts)

# 
dist_glob_wgs84_df_sum <- dist_glob_wgs84_df %>%
					 group_by(min_dist_di_cut, coords.x2_cut) %>%
					 summarize(area_1000km2 = sum(wet_area, na.rm=T)/1000)


# /-------------------------------------------------------------------
#/  LATITUDINAL BARPLOT PLOT
latplot <- ggplot(dist_glob_wgs84_df_sum) +
		   geom_bar(aes(x=coords.x2_cut, y=area_1000km2, fill=min_dist_di_cut), stat='identity', position='stack') +
		   coord_flip() +
		   scale_fill_manual(values = my_palette) +
		   labs(fill="Dissimilarity\nscore") +
		   scale_y_continuous(expand=c(0,0)) +
		   xlab('Latitude') + ylab('Wetland area (x1000 km2)') +
		   line_plot_theme +
		   theme(legend.position='none')

# save figure
ggsave('../output/figures/representativeness/latplot_v4_NOV2020.png', latplot,
       width=180, height=130, dpi=300, units='mm') #type = 'cairo-png')
dev.off()



#------------------------------------------------------------------------
# library(gghalves)
dist_glob_wa <- left_join(dist_glob, constituency, by='closest_tower')

const_sc <- ggplot() +
	geom_point(data=constituency, aes(x=area_1000km2, y=mean_dist_di), size=0.3) +
	geom_errorbar(data=constituency, aes(x=area_1000km2, ymin=mean_dist_di-std_dist_di, ymax=mean_dist_di+std_dist_di),
		size=0.15, width=0)+
	
	# add labels
	geom_text_repel(data= subset(constituency, closest_tower %in% constituency_filt$closest_tower),
									aes(label=closest_tower, x=area_1000km2, y=mean_dist_di+std_dist_di), 
									size = 1.8, 
									colour='blue', 
									segment.size = 0.25, 
									segment.color='blue',
									force = 5,
									box.padding = unit(0.4, 'lines'),
									point.padding = unit(0.4, 'lines')) +

	xlab('Wetland area') + ylab('Dissimilarity score') +
	line_plot_theme +
	coord_cartesian(ylim=c(0, 1))

# save figure
ggsave('../output/figures/representativeness/const_sc_v4_NOV2020.png', const_sc,
       width=180, height=130, dpi=300, units='mm') #type = 'cairo-png')
dev.off()



# /-----------------------------------------------------------------------------
#/ arrange plots grob into layout 
# library(ggpubr)  # CANT INSTALL FOR SOME REASON

dist_map_robin   <- dist_map_robin   + theme(plot.margin=unit(c(-4, -15, -4, 9), "mm"))
consti_map_robin <- consti_map_robin + theme(plot.margin=unit(c(-4, -15, -4, 9), "mm"))

latplot  <- latplot  + theme(plot.margin=unit(c(3, 0.5, 5, -35), "mm"))
const_sc <- const_sc + theme(plot.margin=unit(c(5, 0.5, 4, -35), "mm"))

library(gridExtra)
p <- plot_grid(dist_map_robin, latplot, 
			   consti_map_robin, const_sc, 
          ncol=2, 
          labels = c("A", "B", "C", "D"),
          rel_widths=c(2.1, 1),
          align="hv")

# save figure
ggsave('../output/figures/representativeness/maps_ab_v24_NOV2020.pdf', p,
       width=180, height=135, dpi=300, units='mm') #type = 'cairo-png')
dev.off()





# geom_half_violin(data=dist_glob_wa, aes(x= area_1000km2, y=min_dist_di, fill=closest_tower))
# scale_y_continuous(limits=c(0,2))

# guides(fill = guide_colorbar(title = "Dissimilarity\nscore")) +
# labs(fill = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1))) +
# coord_equal() +
# guides(fill = guide_legend(override.aes = list(size = 0.3),
# 						   title = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1)))) +


# set tight margins so plots are close side-by-side
# Dimensions of each margin: t, r, b, l     (To remember order, think trouble).
# arealossmap <- arealossmap + theme(plot.margin=unit(c(-40, -3, -60, -3), "mm"))
# drivermap   <- drivermap   + theme(plot.margin=unit(c(-60, -3, -40, -3), "mm"))

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



# Color palette replicating Saunois 2020
# my_palette <- c(sequential_hcl(5, palette = 'YlOrRd'), 'grey90')
# my_palette <- c( sequential_hcl(3, palette = 'YlOrRd') ,  sequential_hcl(4, palette = 'Blues'))


# Background countries; grey in-fill  sPDF_robin_df;  countries_robin_df
# geom_polygon(data=coastsCoarse_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +

# save figure
# ggsave('../output/figures/representativeness/tower_constituency_map_5percfw_4pers_v2.png', consti_map_robin,
#        width=180, height=70, dpi=300, units='mm') #type = 'cairo-png')
# dev.off()

# # Coastline
# geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
