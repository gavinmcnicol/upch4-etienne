
# /----------------------------------------------------------------------------#
#/    Get other plotting obj

# Get mapping theme
source("./plots/theme/theme_gif_map.r")

# Get country polygons; used for background now
source("./plots/get_country_bbox_shp_for_ggplot_map.r")


# /----------------------------------------------------------------------------#
#/    get polygon of continent outline                                     -----
library(rworldmap)
data(coastsCoarse)
coastsCoarse_df <- fortify(coastsCoarse)
coastsCoarse_df <- arrange(coastsCoarse_df, id)


# /----------------------------------------------------------------------------#
#/    Get predicted flux grid

flux <- brick('../output/results/grid/upch4_med_nmolm2sec.nc')# , varname="upch4")
# replace negative (sink) values
flux[flux < 0] = NA

# Get date list
parseddates <- readRDS('../output/results/parsed_dates.rds')


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------

bams_towers <- read.csv("../data/towers/BAMS_site_coordinates.csv")
xy <- bams_towers[,c(3,4)]

bams_towers <- data.frame(SpatialPointsDataFrame(coords = xy, data = bams_towers))
# proj4string = crs(flux)))



# /-----------------------------------------------------------------------------#
#/    Start animation & lopping                                             -----

ani.options("convert")
saveGIF({

# Loop time steps
for (t in 1:(length(names(flux)))){
	
	# /----------------------------------------------------------------------------#
	#/    Get predicted grids

	# reformat rasters  for graph in ggplot 
	flux_df <- as(flux[[t]], "SpatialPixelsDataFrame")
	flux_df <- as.data.frame(flux_df)
	names(flux_df) <- c("layer", "x", "y")

	m <- ggplot() +
		
		# background countries
		geom_polygon(data=countries_df, aes(long, lat, group=group), fill="grey90") +
		
		# Flux grid
		geom_tile(data=flux_df, aes(x=x, y=y, fill=layer)) +
		
		# Coastline
		geom_path(data=coastsCoarse_df, aes(long, lat, group=group), color='black', size=0.07) +
		
		# Tower sites
		geom_point(data=bams_towers, aes(Longitude, Latitude), 
							 color='black', fill= "green", shape=21,  size=0.4, stroke=0.1) +
		
		# Write title as month-day format
		ggtitle(substr(parseddates[t], 1, 7)) + 
		#geom_text(aes(90, 0, label=substr(parseddates[t], 1, 7), size=4)) + 
		

		scale_x_continuous(limits=c(-180, 180))+
		scale_y_continuous(limits=c(-60, 90))+
		# scale_fill_distiller(palette='YlOrRd', direction=1, limits=c(0, 0.02), 
		# 					 breaks=c(0, 0.001, 0.005, 0.01, 0.02),
		# 					 #breaks=seq(0, 0.02, 0.002),
		# 					 labels=format_format(scientific = FALSE)) +

		scale_fill_gradient(low="#fffcba", high="#ad0000", 
							 trans="log", 
							 breaks=c(10^-20, 0.001, 0.005, 0.01, 0.03), 
							 labels=c(0, 0.001, 0.005, 0.01, 0.03),
							 limits=c(10^-20, 0.03)) +

			
		# big.mark = " ", decimal.mark = ",", 
		# scale_color_gradient(trans="log", breaks=c(0, 10^-3, 10^-2, 10^-1, 10^0), labels=brks2, guide="legend")
		
		guides(fill = guide_colorbar(nbin=8, raster=F, barwidth=15, frame.colour=c("black"),
							 						frame.linewidth=1, ticks.colour="black",  direction="horizontal",
							 						title = expression(paste("Tg CH"[4]*" month"^-1)))) +
		#guides(shape = guide_legend(override.aes = list(size = 10))) +
		
		coord_equal() +
		gif_map_theme +      
		theme(	legend.position="bottom", #c(0.15, 0.3),
				plot.margin = unit( c(-2, -3, -2, -3) , "mm"))
	
	# /------------------------------------------------------------------------------
	#/ make lineplot
	#source("./plots/lineplot_global_timeseries.r")
	source("./plots/lineplot_global_monthly_stack.r")
	
	# combine into same plot
	combined <- plot_grid(	m, l, 
							ncol=1, align="v", 
							rel_widths=c(1, 1), 
							rel_heights=c(1.7, 1))
	
	show(combined)
	
			
	}
},  movie.name = "/home/groups/robertj2/upch4/output/figures/ch4_upscaled_v025962.gif", 
		ani.width=2500, ani.height=2000, ani.res= 800, 
		interval = 0.24, loop=TRUE, clean=TRUE)




# # convert to discontinuous 
# my_breaks = seq(0,400,50)
# flux$layer <- cut(flux$layer, breaks = my_breaks, dig.lab=10)
# 
# # replace the categories stings to make them nicer in the legend
# flux$layer <- gsub("\\(|\\]", "", flux$layer)
# flux$layer <- gsub("\\,", "-", flux$layer)

