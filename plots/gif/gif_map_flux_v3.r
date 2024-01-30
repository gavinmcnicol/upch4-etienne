# /----------------------------------------------------------------------------#
#/    Get other plotting obj

# Get mapping theme
source("./plots/theme/theme_gif_map.r")

# /----------------------------------------------------------------------------#
#/    Get polygon of continent outline                                     -----
library(rworldmap)
data(coastsCoarse)
sPDF <- getMap()[getMap()$ADMIN!='Antarctica',]


# /----------------------------------------------------------------------------#
#/    Get predicted flux grid

flux <- brick('../output/results/grid/upch4_med_nmolm2sec.nc')# , varname="upch4")

lw_cut <- 10^-4     # define low-end cutoff

#flux[flux < 0] = lw_cut  # replace negative (sink) values
flux[flux < lw_cut] = lw_cut  # replace very low values

# Get date list
parseddates <- readRDS('../output/results/parsed_dates.rds')
# subset to list starting in 2000-01
parseddatessubset <- parseddates[241:length(parseddates)]


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------

bams_towers <- read.csv("../data/towers/BAMS_site_coordinates.csv")
xy <- bams_towers[,c(3,4)]   # creat coordinates
bams_towers <- data.frame(SpatialPointsDataFrame(coords = xy, data = bams_towers))

# /-----------------------------------------------------------------------------#
#/    Start animation & lopping                                             -----

ani.options("convert")
saveGIF({

# Loop time steps
# idx 121 starts at 2010;  idx 204 is end of 2016 (the overlap period with MERRA2)
# GCP models are for 2000-2013 (length 156 months)
# so middleground is 2010-2013
for (t in 73:204){ #length(names(flux))){
	
	print(paste0("plotting: ", t, "  out of  ", length(names(flux))))

	# /----------------------------------------------------------------------------#
	#/    Get predicted grids

	# reformat rasters  for graph in ggplot 
	flux_df <- as(flux[[t]], "SpatialPixelsDataFrame")
	flux_df <- as.data.frame(flux_df)
	names(flux_df) <- c("layer", "x", "y")

	
	m <- ggplot() +
		
		# background countries
	  	geom_polygon(data=sPDF, aes(long, lat, group=group), 
	            color=NA, fill='grey95') +
	  
		# Flux grid
		geom_tile(data=flux_df, aes(x=x, y=y, fill=layer)) +
		
		# Coastline
		geom_path(data=coastsCoarse, aes(long, lat, group=group), 
		          color='black', size=0.08) +
		
		# Tower sites
		geom_point(data=bams_towers, aes(Longitude, Latitude),
			color='black', fill= "green", shape=21,  size=0.4, stroke=0.1) +
		
		# Write title as month-day format
		ggtitle(substr(parseddatessubset[t], 1, 7)) + 
		#geom_text(aes(90, 0, label=substr(parseddates[t], 1, 7), size=4)) + 
		
		# Set scales (setting longitude can create tearing)
		#scale_x_continuous(limits=c(-180.1, 180.1))+
		scale_y_continuous(limits=c(-60, 90))+
		# scale_fill_distiller(palette='YlOrRd', direction=1, limits=c(0, 0.02), 
		# 					 breaks=c(0, 0.001, 0.005, 0.01, 0.02),
		# 					 #breaks=seq(0, 0.02, 0.002),
		# 					 labels=format_format(scientific = FALSE)) +

		scale_fill_gradient(low="#fffcba", high="#e80000", 
							trans="log", 
							breaks=c(10^-4, 10^-3, 10^-2),
							#labels=c(10^-5, 10^-4, 10^-3, 10^-2),
							labels=c(expression(10^{-4}),
							         expression(10^{-3}),
							         expression(10^{-2})),
							limits=c(lw_cut, 0.02)) +

		# Format colorbar
		guides(fill = guide_colorbar(nbin=10, raster=F, 
		                             barheight = 3.5, barwidth=0.5, 
		                             frame.colour=c("black"), frame.linewidth=0.2, 
		                             ticks.colour="black", ticks.linewidth = 0.15,  
		                             direction="vertical",
		                             title = expression(paste("Tg CH"[4]*" month"^-1)))) +
	  			
	  							
		coord_equal() +
		gif_map_theme +      
		theme(	legend.position= c(0.0, 0.5),
				plot.margin = unit( c(-2, -3, -2, 10) , "mm"))
	
	# /------------------------------------------------------------------------------
	#/  Make lineplot of global Tg month-1
	#source("./plots/lineplot_global_timeseries_wgcp.r")
	source("./plots/lineplot_global_timeseries.r")
	#source("./plots/lineplot_global_monthly_stack.r")
	

	# combine into same plot
	combined <- plot_grid(m, l,
							ncol=1, align="v", 
							rel_widths=c(1, 1), 
							rel_heights=c(2, 1))

	# plot combined 
	show(combined)
	

	}
},  movie.name = "/home/groups/robertj2/upch4/output/figures/ch4_upscaled_v0269.gif", 
	ani.width=2000, ani.height=1600, ani.res= 700, 
	interval = 0.2, loop=TRUE, clean=TRUE)
	# cmd.fun = if (.Platform$OS.type == "windows") shell else system)
