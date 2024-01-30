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

flux <- brick("../output/results/grids/v02/rf_mean_ch4_monthly_composite_2001_2018_mg_m2_day.tif")

lw_cut <- 10^-1     # define low-end cutoff

#flux[flux < 0] = lw_cut  # replace negative (sink) values
flux[flux < lw_cut] = lw_cut  # replace very low values

# month(c(1,2,3))

# # Get date list
# parseddates <- readRDS('../output/results/parsed_dates.rds')
# # subset to list starting in 2000-01
# parseddatessubset <- parseddates[241:length(parseddates)]

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
	  	geom_histogram(data=flux_df, aes(x=layer, fill=layer), bins=10) +

		ggtitle(mymonths[t]) +

		scale_x_log10(limits=c(lw_cut, 10^{2}), expand=c(0,0)) +
		scale_y_log10(limits=c(0.01, 40000), expand=c(0,0)) +
	

		xlab('') +

		scale_fill_gradient(low="#fffcba", high="#e80000", 
							trans="log", 
							breaks=c(10^-1, 10^0, 10^1, 10^2),
							#labels=c(10^-5, 10^-4, 10^-3, 10^-2),
							labels=c(expression(10^{-1}),
							         expression(10^{0}),
							         expression(10^{1}),
							         expression(10^{2})),
							limits=c(lw_cut, 10^{2})) +

		# expression(10^{-2})
		# Format colorbar
		guides(fill = guide_colorbar(nbin=10, raster=F, 
		                             barheight = 3.5, barwidth=0.5, 
		                             frame.colour=c("black"), frame.linewidth=0.2, 
		                             ticks.colour="black", ticks.linewidth = 0.15,  
		                             direction="vertical",
		                             title = expression(paste("mg(CH"[4]*") m"^-1*" day"^-1))))
	  				
		# coord_equal() +
		# gif_map_theme       
		# theme(	legend.position= c(0.1, 0.35),
		# 		plot.margin = unit( c(1, -3, 1, -2) , "mm"))
	
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

	# plot combined 
	show(m)

	}
},movie.name = "/home/groups/robertj2/upch4/output/figures/distrib_compositech4_v200_mg_m2_day.gif", 
  ani.width=1000, ani.height=1000, ani.res= 250, interval = 0.4, loop=TRUE, clean=TRUE)
	# cmd.fun = if (.Platform$OS.type == "windows") shell else system)

