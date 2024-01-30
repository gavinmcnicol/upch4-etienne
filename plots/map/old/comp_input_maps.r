# /-------------------------------------------------
#/  Reformat to: robinson df 
gcp1_df <- WGSraster2dfROBIN(gcp1)
ct1_df  <- WGSraster2dfROBIN(ct1)
wc1_df  <- WGSraster2dfROBIN(wc1)


# /-----------------------------------------------------------#
#/  Convert to Saunois factor scale; for color ramp
gcp1_df <- To.Saunois2020.Scale(gcp1_df)
ct1_df  <- To.Saunois2020.Scale(ct1_df)
wc1_df  <- To.Saunois2020.Scale(wc1_df)


# /----------------------------------------------------------------------------#
#/    Get predicted grids
# my_palette <- c(sequential_hcl(10, palette = "YlOrRd"), 'grey90')
my_palette <- c(sequential_hcl(11, palette = "YlOrRd"), 'grey90')


#--------------------------------------------------------------------------------
gcp_map <- 
	ggplot() +
	
	# add background country polygons
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +

	# Flux grid
	geom_tile(data=gcp1_df, aes(x=x, y=y, fill=layer_cut)) +
	
	# add outline of background countries
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
	
	# Add outline bounding box
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color="black", size=0.2) +
	
	# Tower sites
	# geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
	# theme_raster_map() +
	
	scale_y_continuous(limits=c(-6600000, 8953595)) +
	# scale_y_continuous(limits=c(-60, 90))+

	# scale_fill_gradient2(	low = scales::muted("blue"),
	# 						mid = "grey90",
	# 						high = scales::muted("red"),
	# 						na.value = "white",
	# 						midpoint = 0) +
	scale_fill_manual(values = my_palette) +

	labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)')  +
	coord_equal() +
	gif_map_theme +      
	theme(	legend.position= c(0.03, 0.5),
			plot.margin = unit(c(1, -3, 1, 8), "mm"))

ggsave("../output/figures/diff_map/gcp_map_mgCH4m2day_v2.png", 
	   gcp_map, width=180, height=80, dpi=300, units="mm", )
dev.off()



#--------------------------------------------------------------------------------
wc_map <- 
	ggplot() +
	
	# add background country polygons
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +

	# Flux grid
	geom_tile(data=wc1_df, aes(x=x, y=y, fill=layer_cut)) +
	
	# add outline of background countries
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
	
	# Add outline bounding box
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color="black", size=0.2) +
	
	# Tower sites
	# geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
	# theme_raster_map() +
	
	scale_y_continuous(limits=c(-6600000, 8953595)) +
	scale_fill_manual(values = my_palette) +

	labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)')  +
	coord_equal() +
	gif_map_theme +      
	theme(	legend.position= c(0.03, 0.5),
			plot.margin = unit(c(1, -3, 1, 8), "mm"))

ggsave("../output/figures/diff_map/wc_map_mgCH4m2day.png", 
	   wc_map, width=180, height=80, dpi=300, units="mm")
dev.off()




#--------------------------------------------------------------------------------
ct_map <- 
	ggplot() +
	
	# add background country polygons
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +

	# Flux grid
	geom_tile(data=ct1_df, aes(x=x, y=y, fill=layer_cut)) +
	
	# add outline of background countries
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
	
	# Add outline bounding box
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color="black", size=0.2) +
	
	# Tower sites
	# geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
	# theme_raster_map() +
	
	scale_y_continuous(limits=c(-6600000, 8953595)) +
	scale_fill_manual(values = my_palette) +

	labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)')  +
	coord_equal() +
	gif_map_theme +      
	theme(	legend.position= c(0.03, 0.5),
			plot.margin = unit(c(1, -3, 1, 8), "mm"))

ggsave("../output/figures/diff_map/ct_map_mgCH4m2day.png", 
	   ct_map, width=180, height=80, dpi=300, units="mm")
dev.off()

