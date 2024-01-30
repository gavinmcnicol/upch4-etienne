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

flux <- brick("../output/results/grids/v02/rf_mean_ch4_monthly_2001_2018_nmol_m2_day_monthly_composite.tif")

lw_cut <- 10^0     # define low-end cutoff

#flux[flux < 0] = lw_cut  # replace negative (sink) values
flux[flux < lw_cut] = lw_cut  # replace very low values

# month(c(1,2,3))

# # Get date list
# parseddates <- readRDS('../output/results/parsed_dates.rds')
# # subset to list starting in 2000-01
# parseddatessubset <- parseddates[241:length(parseddates)]


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------

# bams_towers <- read.csv("../data/towers/BAMS_site_coordinates.csv")
bams_towers <- read.csv("../data/towers/db_v2_site_metadata_Feb2020.csv")  %>% 

    filter(IGBP %in% c("WET", 'WSA', "CRO - Rice")) %>%
    filter(ID != "--*") %>%
    filter(ID != "--") %>%
    filter(ID != "--**") %>%
    filter(YR_START != "--") %>%
    filter(YR_END != "--")

# xy <- bams_towers[,c(3,4)]   # creat coordinates
xy <- bams_towers[,c(5,6)]   # creat coordinates
bams_towers <- data.frame(SpatialPointsDataFrame(coords = xy, data = bams_towers))

# /-----------------------------------------------------------------------------#
#/    Start animation & lopping                                             -----

mymonths <- c("Jan","Feb","Mar",
              "Apr","May","Jun",
              "Jul","Aug","Sep",
              "Oct","Nov","Dec")


ani.options("convert")
saveGIF({

# Loop time steps
# idx 121 starts at 2010;  idx 204 is end of 2016 (the overlap period with MERRA2)
# GCP models are for 2000-2013 (length 156 months)
# so middleground is 2010-2013
# 73:204
for (t in seq(1,12)){ #length(names(flux))){
	
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
		geom_point(data=bams_towers, aes(LON.1, LAT.1), #aes(Longitude, Latitude),
			color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
		
		# Write title as month-day format
		# ggtitle(substr(mymonths[t])) + 
		ggtitle(mymonths[t]) + 
		#geom_text(aes(90, 0, label=substr(parseddates[t], 1, 7), size=4)) + 
		
		# Set scales (setting longitude can create tearing)
		#scale_x_continuous(limits=c(-180.1, 180.1))+
		scale_y_continuous(limits=c(-60, 90))+
		# scale_fill_distiller(palette='YlOrRd', direction=1, limits=c(0, 0.02), 
		# 					 breaks=c(0, 0.001, 0.005, 0.01, 0.02),
		# 					 #breaks=seq(0, 0.02, 0.002),
		# 					 labels=format_format(scientific = FALSE)) +


		scale_fill_gradientn(colors= rev(sequential_hcl(10, palette = 'ag_Sunset')),
							trans="log", 
							breaks=c(10^0, 10^1, 10^2, 230),
							#labels=c(10^-5, 10^-4, 10^-3, 10^-2),
							labels=c(expression(10^{0}),
							         expression(10^{1}),
							         expression(10^{2}),
							         expression(230)),
							limits=c(lw_cut, 230)) +

		# expression(10^{-2})
		# Format colorbar
		guides(fill = guide_colorbar(nbin=10, raster=F, 
		                             barheight = 3.5, barwidth=0.5, 
		                             frame.colour=c("black"), frame.linewidth=0.2, 
		                             ticks.colour="black", ticks.linewidth = 0.15,  
		                             direction="vertical",
		                             title = expression(paste("nmol(CH"[4]*") m"^-2*" sec"^-1)))) +
	  				
		coord_equal() +
		gif_map_theme +      
		theme(	legend.position= c(0.01, 0.35),
				plot.margin = unit( c(1, -3, 1, 7) , "mm"))

	# plot combined 
	show(m)

	}
},  movie.name = "/home/groups/robertj2/upch4/output/figures/monthly_ch4_compositech4_v200_nmol_m2_sec_v2.gif", 
	ani.width=1600, ani.height=900, ani.res= 400, 
	interval = 0.4, loop=TRUE, clean=TRUE)
	# cmd.fun = if (.Platform$OS.type == "windows") shell else system)




# /------------------------------------------------------------------------------
#/  Make lineplot of global Tg month-1
#source("./plots/lineplot_global_timeseries_wgcp.r")
# source("./plots/lineplot_global_timeseries.r")
# #source("./plots/lineplot_global_monthly_stack.r")

# # combine into same plot
# combined <- plot_grid(m, l,
# 						ncol=1, align="v", 
# 						rel_widths=c(1, 1), 
# 						rel_heights=c(2, 1))

